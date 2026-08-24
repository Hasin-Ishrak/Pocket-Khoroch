import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message_model.dart';
import '../models/transaction_model.dart';
import '../repository/chat_repository.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final AiService _aiService;
  final ChatRepository _chatRepository;
  final _uuid = const Uuid();

  ChatProvider({
    required AiService aiService,
    required ChatRepository chatRepository,
  }) : _aiService = aiService,
       _chatRepository = chatRepository;

  List<ChatMessageModel> _messages = [];
  bool _isLoadingHistory = false;
  bool _isStreaming = false;
  String? _errorMessage;
  String? _userId;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isStreaming => _isStreaming;
  String? get errorMessage => _errorMessage;

  Future<void> initChat(
    String userId, {
    List<TransactionModel>? recentTransactions,
  }) async {
    _userId = userId;
    _isLoadingHistory = true;
    notifyListeners();

    try {
      _messages = await _chatRepository.fetchHistory(userId);
    } catch (_) {
      _messages = [];
    }

    _aiService.startSession(recentTransactions: recentTransactions);

    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (_userId == null || text.trim().isEmpty) return;

    final userMessage = ChatMessageModel(
      id: _uuid.v4(),
      userId: _userId!,
      role: 'user',
      content: text.trim(),
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();
    _chatRepository.saveMessage(userMessage); // fire and forget

    // Add a placeholder model message that we'll stream into
    final modelMessageId = _uuid.v4();
    final placeholder = ChatMessageModel(
      id: modelMessageId,
      userId: _userId!,
      role: 'model',
      content: '',
      timestamp: DateTime.now(),
    );
    _messages.add(placeholder);
    _isStreaming = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final buffer = StringBuffer();
      await for (final chunk in _aiService.sendMessageStream(text.trim())) {
        buffer.write(chunk);
        final index = _messages.indexWhere((m) => m.id == modelMessageId);
        if (index != -1) {
          _messages[index] = ChatMessageModel(
            id: modelMessageId,
            userId: _userId!,
            role: 'model',
            content: buffer.toString(),
            timestamp: placeholder.timestamp,
          );
          notifyListeners();
        }
      }

      final finalIndex = _messages.indexWhere((m) => m.id == modelMessageId);
      if (finalIndex != -1) {
        _chatRepository.saveMessage(
          _messages[finalIndex],
        ); // save completed response
      }
    } on InvalidApiKey {
      _errorMessage =
          'Gemini API key is invalid. Update tool/secrets.secrets.json and restart the app.';
      _messages.removeWhere((m) => m.id == modelMessageId);
    } on UnsupportedUserLocation {
      _errorMessage = 'The Gemini AI service is not available in this region.';
      _messages.removeWhere((m) => m.id == modelMessageId);
    } on GenerativeAIException catch (e) {
      _errorMessage = 'Gemini service error: ${e.message}';
      _messages.removeWhere((m) => m.id == modelMessageId);
    } catch (_) {
      _errorMessage =
          'Network error. Check your internet connection and try again.';
      _messages.removeWhere((m) => m.id == modelMessageId);
    } finally {
      _isStreaming = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    if (_userId == null) return;
    await _chatRepository.clearHistory(_userId!);
    _messages.clear();
    _aiService.startSession();
    notifyListeners();
  }
}
