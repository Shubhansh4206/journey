import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_agent_service.dart';
import '../utils/colors.dart';

class GeminiAgentChatScreen extends StatefulWidget {
  const GeminiAgentChatScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GeminiAgentChatScreen(),
      ),
    );
  }

  @override
  State<GeminiAgentChatScreen> createState() => _GeminiAgentChatScreenState();
}

class _GeminiAgentChatScreenState extends State<GeminiAgentChatScreen> {
  final GeminiAgentService _agentService = GeminiAgentService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      final hasText = _inputController.text.trim().isNotEmpty;
      if (hasText != _hasInput) {
        setState(() => _hasInput = hasText);
      }
    });

    // Auto-scroll to bottom after initial frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage([String? customPrompt]) {
    final prompt = customPrompt ?? _inputController.text;
    if (prompt.trim().isEmpty) return;

    _inputController.clear();
    _agentService.sendUserMessage(prompt);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _showApiKeyDialog() {
    final textController = TextEditingController(
      text: _agentService.activeApiKey ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.key_rounded, color: AppColors.primaryDarkBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Gemini API Key',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your API key is automatically loaded from the .env file (GEMINI_API_KEY). You can also override or test it directly here:',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.mediumGrey),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Get a free key from Google AI Studio: aistudio.google.com/app/apikey\n(Valid keys begin with AIzaSy...)',
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.mediumGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newKey = textController.text.trim();
              if (newKey.isNotEmpty) {
                _agentService.setRuntimeApiKey(newKey);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gemini API Key updated!')),
                );
              }
              Navigator.pop(ctx);
            },
            child: Text('Save Key', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Warning banner if key is missing
            if (!_agentService.isConfigured) _buildMissingKeyBanner(),

            // Chat messages list
            Expanded(
              child: ValueListenableBuilder<List<AgentChatMessage>>(
                valueListenable: _agentService.messagesNotifier,
                builder: (context, messages, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _buildMessageItem(msg);
                    },
                  );
                },
              ),
            ),

            // Thinking / Typing indicator
            ValueListenableBuilder<bool>(
              valueListenable: _agentService.isBusyNotifier,
              builder: (context, isBusy, _) {
                if (!isBusy) return const SizedBox.shrink();
                return _buildThinkingIndicator();
              },
            ),

            // Bottom Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.nearBlack, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Text(
        'Ask AI',
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.nearBlack,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Configure API Key',
          icon: const Icon(Icons.key_outlined, color: AppColors.nearBlack, size: 20),
          onPressed: _showApiKeyDialog,
        ),
        IconButton(
          tooltip: 'Clear Chat',
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.mediumGrey, size: 21),
          onPressed: () {
            _agentService.resetChat();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chat cleared')),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.border, height: 1),
      ),
    );
  }

  Widget _buildMissingKeyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFEF3C7),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Set GEMINI_API_KEY in .env or tap to configure credentials.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF92400E),
              ),
            ),
          ),
          TextButton(
            onPressed: _showApiKeyDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Enter Key',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB45309),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(AgentChatMessage message) {
    if (message.isUser) {
      return _buildUserBubble(message);
    } else {
      return _buildAiBubble(message);
    }
  }

  Widget _buildUserBubble(AgentChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 48),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble(AgentChatMessage message) {
    final isError = message.isError;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isError ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.error_outline_rounded : Icons.smart_toy_outlined,
                  color: isError ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isError ? const Color(0xFFFEF2F2) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isError ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownBody(
                        data: message.text,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isError ? const Color(0xFF991B1B) : AppColors.nearBlack,
                            height: 1.5,
                          ),
                          h1: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.nearBlack,
                          ),
                          h2: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.nearBlack,
                          ),
                          h3: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.nearBlack,
                          ),
                          strong: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: isError ? const Color(0xFF7F1D1D) : const Color(0xFF0F172A),
                          ),
                          listBullet: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.primaryDarkBlue,
                          ),
                          code: GoogleFonts.firaCode(
                            backgroundColor: const Color(0xFFF1F5F9),
                            fontSize: 12,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: message.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied response to clipboard'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.copy_rounded, size: 12, color: AppColors.mediumGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Copy',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.mediumGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Suggested quick prompts if present
          if (message.suggestedActions != null && message.suggestedActions!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestedActions!.map((prompt) {
                  return ActionChip(
                    label: Text(
                      prompt,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    onPressed: () => _sendMessage(prompt),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Thinking...',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.nearBlack),
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _hasInput ? () => _sendMessage() : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _hasInput ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: _hasInput ? Colors.white : AppColors.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
