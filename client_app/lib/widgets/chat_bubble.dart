import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isStreaming;

  const ChatBubble({super.key, required this.message, this.isStreaming = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.acidMint : theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: theme.dividerColor),
        ),
        child: message.content.isEmpty && isStreaming
            ? const _TypingIndicator()
            : Text(
                message.content,
                style: TextStyle(
                  color: isUser ? AppColors.accentText : theme.colorScheme.onSurface,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final delay = i * 0.2;
              final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
              final opacity = (value < 0.5) ? value * 2 : (1 - value) * 2;
              return Opacity(
                opacity: 0.3 + (opacity * 0.7),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}