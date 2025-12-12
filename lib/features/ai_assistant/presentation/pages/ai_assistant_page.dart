import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/constants/app_constants.dart';

/// AI Assistant Page with chat interface
class AiAssistantPage
    extends
        StatefulWidget {
  const AiAssistantPage({
    super.key,
  });

  @override
  State<
    AiAssistantPage
  >
  createState() => _AiAssistantPageState();
}

class _AiAssistantPageState
    extends
        State<
          AiAssistantPage
        > {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<
    Map<
      String,
      dynamic
    >
  >
  _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      {
        'role': 'assistant',
        'content': "Hi! I'm ShopRoute AI 🛒\n\nI can help you:\n• Find the best deals\n• Plan shopping routes\n• Recommend products\n• Compare stores\n\nWhat would you like help with today?",
        'timestamp': DateTime.now(),
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(
      () {
        _messages.add(
          {
            'role': 'user',
            'content': userMessage,
            'timestamp': DateTime.now(),
          },
        );
        _isTyping = true;
      },
    );

    _scrollToBottom();

    // Simulate AI response
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    if (!mounted) return;

    setState(
      () {
        _isTyping = false;
        _messages.add(
          {
            'role': 'assistant',
            'content': _generateResponse(
              userMessage,
            ),
            'timestamp': DateTime.now(),
            'hasRoute':
                userMessage.toLowerCase().contains(
                  'route',
                ) ||
                userMessage.toLowerCase().contains(
                  'milk',
                ) ||
                userMessage.toLowerCase().contains(
                  'bread',
                ),
          },
        );
      },
    );

    _scrollToBottom();
  }

  String _generateResponse(
    String message,
  ) {
    if (message.toLowerCase().contains(
          'milk',
        ) ||
        message.toLowerCase().contains(
          'bread',
        )) {
      return "I found the best route for your shopping! 🗺️\n\n"
          "**Stop 1: Fresh Mart** (1.2 km)\n"
          "• Milk - \$3.49\n"
          "• Bread - \$2.99\n\n"
          "**Stop 2: QuickShop** (2.1 km from Stop 1)\n"
          "• Eggs - \$4.99\n\n"
          "📍 Total Distance: 3.3 km\n"
          "⏱️ Estimated Time: 12 min\n"
          "💰 Total Savings: \$2.50";
    }

    if (message.toLowerCase().contains(
          'vegan',
        ) ||
        message.toLowerCase().contains(
          'protein',
        )) {
      return "Here are some great vegan protein options:\n\n"
          "🥜 **Organic Tofu** - \$3.99 at Fresh Mart\n"
          "🫘 **Black Beans** - \$1.49 at Value Store\n"
          "🥗 **Quinoa** - \$5.99 at Health Foods\n\n"
          "Would you like me to plan a route to these stores?";
    }

    return "I can help you with that! Let me search for the best options nearby.\n\n"
        "Would you like me to:\n"
        "1. Find the best prices\n"
        "2. Plan an optimized route\n"
        "3. Show nearby stores";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(
                8,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              'AI Assistant',
              style: AppTextStyles.titleLarge(),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(
                () {
                  _messages.clear();
                  _addWelcomeMessage();
                },
              );
            },
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick action chips
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppConstants.aiQuickActions.map(
                  (
                    action,
                  ) {
                    return GestureDetector(
                      onTap: () {
                        _messageController.text = action;
                        _sendMessage();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                          right: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(
                              0.3,
                            ),
                          ),
                        ),
                        child: Text(
                          action,
                          style: AppTextStyles.labelMedium(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(
                16,
              ),
              itemCount:
                  _messages.length +
                  (_isTyping
                      ? 1
                      : 0),
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    if (index ==
                            _messages.length &&
                        _isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(
                      _messages[index],
                    );
                  },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(
              16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.05,
                  ),
                  blurRadius: 10,
                  offset: const Offset(
                    0,
                    -4,
                  ),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Voice input
                    },
                    icon: const Icon(
                      Icons.mic_outlined,
                    ),
                    color: AppColors.textTertiaryLight,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            24,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted:
                          (
                            _,
                          ) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<
      String,
      dynamic
    >
    message,
  ) {
    final isUser =
        message['role'] ==
        'user';

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(
                    16,
                  ),
                  topRight: const Radius.circular(
                    16,
                  ),
                  bottomLeft: Radius.circular(
                    isUser
                        ? 16
                        : 4,
                  ),
                  bottomRight: Radius.circular(
                    isUser
                        ? 4
                        : 16,
                  ),
                ),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Text(
                message['content'],
                style: AppTextStyles.bodyMedium(
                  color: isUser
                      ? Colors.white
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          if (isUser)
            const SizedBox(
              width: 44,
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            padding: const EdgeInsets.all(
              16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(
                16,
              ),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(
                  0,
                ),
                _buildDot(
                  1,
                ),
                _buildDot(
                  2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(
    int index,
  ) {
    return TweenAnimationBuilder<
      double
    >(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: Duration(
        milliseconds:
            600 +
            index *
                200,
      ),
      builder:
          (
            context,
            value,
            child,
          ) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 3,
              ),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.textTertiaryLight.withOpacity(
                  0.3 +
                      0.7 *
                          value,
                ),
                shape: BoxShape.circle,
              ),
            );
          },
    );
  }
}
