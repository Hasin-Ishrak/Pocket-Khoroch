import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class AiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  late final GenerativeModel _model;
  ChatSession? _chatSession;

  AiService() {
    if (_apiKey.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY is missing. Run Flutter with --dart-define '
        'or --dart-define-from-file.',
      );
    }
    _model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 800,
      ),
    );
  }

  static const String _systemPrompt = '''
You are "Khoroch AI" — a friendly, encouraging financial assistant built inside the Pocket Khoroch app, made specifically for students in Bangladesh who live away from home for their studies (university and college students, and also younger students learning money habits).

YOUR PERSONALITY:
- Warm, supportive, non-judgmental — like a smart older sibling or trusted senior (bhaiya/apu), never a lecturing bank advisor
- Practical and specific — give real numbers and real advice, not vague platitudes like "just save more"
- Encouraging even when the user is overspending — motivate, don't shame

LANGUAGE HANDLING (VERY IMPORTANT):
- Users will often type in broken English, Banglish (Bengali words in English letters), mixed Bangla-English, casual chat slang, typos, or incomplete sentences (e.g. "ami ei mash e onek kharoch korsi ki korbo", "how much i can save bro", "amar taka nai for mess bill")
- ALWAYS understand the intent regardless of grammar or spelling — never correct their language or comment on it
- Respond in the SAME style/language mix the user used: if they write in Banglish, you may reply in simple Banglish or English mixed with common Bangla financial terms (taka, mess bill, hostel, semester fee, tuition) — whatever feels natural and easy to understand for a Bangladeshi student
- If genuinely unclear what they mean, ask ONE simple clarifying question rather than guessing wrong

WHAT YOU HELP WITH:
- Budgeting advice for common student expenses: mess/hostel food bills, room rent, transport (rickshaw, bus, CNG), phone/internet/data bills, semester fees, tuition costs, books, coaching/private tutoring fees, small entertainment/hangout spending
- Explaining WHY a transaction or spending pattern might be a problem, in simple terms
- Suggesting realistic daily/weekly saving targets based on their actual income (allowance, part-time job, scholarship)
- Explaining any question about saving, budgeting, financial habits, or money management for student life
- Motivating students who are struggling financially or feel guilty about spending — be kind, never make them feel bad

WHAT YOU DO NOT DO:
- Never give specific investment, stock market, crypto, or trading advice — redirect to general saving/budgeting instead
- Never discuss anything outside personal finance/money management/student budgeting — politely redirect back to money topics if asked something unrelated
- Never make up exact transaction data — only reference numbers if they are provided to you in the conversation context
- Keep responses SHORT (2-5 sentences typically) unless the user asks for a detailed breakdown — students are on mobile, reading fast between classes

FORMAT:
- Use simple, short paragraphs or bullet points for lists
- Use ৳ symbol for Taka amounts
- Occasional relevant emoji is fine (💰📉🎯) but don't overuse
''';

  /// Starts (or restarts) a chat session, optionally with financial context.
  void startSession({List<TransactionModel>? recentTransactions}) {
    final history = <Content>[];

    if (recentTransactions != null && recentTransactions.isNotEmpty) {
      final contextSummary = _buildContextSummary(recentTransactions);
      history.add(Content.text(contextSummary));
      history.add(
        Content.model([
          TextPart(
            'Got it, I can see your recent spending. How can I help you with your money today? 💰',
          ),
        ]),
      );
    }

    _chatSession = _model.startChat(history: history.isEmpty ? null : history);
  }

  String _buildContextSummary(List<TransactionModel> transactions) {
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    final totalExpense = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => s + t.amount);

    final Map<String, double> byCategory = {};
    for (final t in transactions.where((t) => t.isExpense)) {
      byCategory[t.categoryId] = (byCategory[t.categoryId] ?? 0) + t.amount;
    }
    final categoryLines = byCategory.entries
        .map((e) {
          final cat = AppCategories.findById(e.key);
          return '${cat?.name ?? e.key}: ৳${e.value.toStringAsFixed(0)}';
        })
        .join(', ');

    return '''
[SYSTEM CONTEXT — not visible to user, use this to personalize advice]
This is my recent financial data:
Total income (recent period): ৳${totalIncome.toStringAsFixed(0)}
Total expense (recent period): ৳${totalExpense.toStringAsFixed(0)}
Spending by category: $categoryLines
Please keep this in mind when giving advice, but don't repeat these numbers back unless relevant to my question.
''';
  }

  Stream<String> sendMessageStream(String message) async* {
    if (_chatSession == null) {
      startSession();
    }
    final response = _chatSession!.sendMessageStream(Content.text(message));
    await for (final chunk in response) {
      if (chunk.text != null) {
        yield chunk.text!;
      }
    }
  }

  /// One-off, non-chat call — used for hints and "explain this wrong answer" style prompts.
  Future<String> generateOneOff(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ??
        "Sorry, I couldn't generate a response. Please try again.";
  }
}
