import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AgentChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final List<String>? suggestedActions;

  AgentChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.suggestedActions,
  });
}

class GeminiAgentService {
  static final GeminiAgentService _instance = GeminiAgentService._internal();
  factory GeminiAgentService() => _instance;
  GeminiAgentService._internal() {
    _initService();
  }

  GenerativeModel? _model;
  ChatSession? _chatSession;
  String? _runtimeApiKey;

  final ValueNotifier<List<AgentChatMessage>> messagesNotifier =
      ValueNotifier<List<AgentChatMessage>>([]);
  final ValueNotifier<bool> isBusyNotifier = ValueNotifier<bool>(false);

  // Suggested prompt chips for immediate interaction
  final List<String> defaultSuggestions = const [
    'Plan a 3-day trip to Goa',
    'Weekend budget for Jaipur',
    'Best cafes and spots in Manali',
    'Packing checklist for travel',
  ];

  String? get activeApiKey {
    if (_runtimeApiKey != null && _runtimeApiKey!.trim().isNotEmpty) {
      return _runtimeApiKey!.trim();
    }
    String? envKey;
    try {
      if (dotenv.isInitialized) {
        envKey = dotenv.env['GEMINI_API_KEY'];
      }
    } catch (_) {}

    if (envKey != null &&
        envKey.trim().isNotEmpty &&
        envKey.trim() != 'YOUR_GEMINI_API_KEY' &&
        envKey.trim() != 'your-gemini-api-key-here') {
      return envKey.trim();
    }
    return null;
  }

  bool get isConfigured => activeApiKey != null && activeApiKey!.isNotEmpty;

  void setRuntimeApiKey(String key) {
    _runtimeApiKey = key.trim();
    _initService();
  }

  void _initService() {
    final key = activeApiKey;
    String modelName = 'gemini-1.5-flash';
    try {
      if (dotenv.isInitialized) {
        modelName = (dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash').trim();
      }
    } catch (_) {}

    if (key != null && key.isNotEmpty) {
      try {
        _model = GenerativeModel(
          model: modelName,
          apiKey: key,
          systemInstruction: Content.system(
            'You are an AI travel assistant in the Journey travel app.\n'
            'Help travelers with destination questions, day-by-day itineraries, budget estimates in Indian Rupees (₹), and practical travel advice.\n'
            'Keep answers clear, helpful, well-structured, and concise.',
          ),
        );
        _chatSession = _model!.startChat();
      } catch (e) {
        debugPrint('[GeminiAgentService] Error initializing model: $e');
      }
    } else {
      _model = null;
      _chatSession = null;
    }

    if (messagesNotifier.value.isEmpty) {
      _seedWelcomeMessage();
    }
  }

  void _seedWelcomeMessage() {
    final welcomeMsg = AgentChatMessage(
      id: 'welcome-${DateTime.now().millisecondsSinceEpoch}',
      text: 'Hi! Ask me anything about trip planning, destinations, itineraries, or budgets.',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: defaultSuggestions,
    );
    messagesNotifier.value = [welcomeMsg];
  }

  void resetChat() {
    _initService();
    _seedWelcomeMessage();
  }

  Future<void> sendUserMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = AgentChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    messagesNotifier.value = [...messagesNotifier.value, userMsg];

    if (!isConfigured) {
      final notConfiguredMsg = AgentChatMessage(
        id: 'ai-error-${DateTime.now().millisecondsSinceEpoch}',
        text: '⚠️ **Gemini API Key Required**\n\n'
            'To converse with Journey AI, please set your `GEMINI_API_KEY` in the `.env` file or enter it in the key settings above.\n\n'
            '👉 You can get a free API key at [Google AI Studio](https://aistudio.google.com).',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      messagesNotifier.value = [...messagesNotifier.value, notConfiguredMsg];
      return;
    }

    if (_chatSession == null) {
      _initService();
    }

    if (_chatSession == null) {
      final errorMsg = AgentChatMessage(
        id: 'ai-error-${DateTime.now().millisecondsSinceEpoch}',
        text: '❌ Could not initialize Gemini chat session. Please verify your API key and network connection.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      messagesNotifier.value = [...messagesNotifier.value, errorMsg];
      return;
    }

    isBusyNotifier.value = true;

    try {
      final response = await _chatSession!.sendMessage(
        Content.text(trimmed),
      );

      final replyText = response.text ?? 'I could not generate a response. Please try again!';

      final aiMsg = AgentChatMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      messagesNotifier.value = [...messagesNotifier.value, aiMsg];
    } catch (e) {
      debugPrint('[GeminiAgentService] Gemini Error: $e');
      final errorStr = e.toString();
      String errorMsgText;

      if (errorStr.contains('API key not valid') ||
          errorStr.contains('API_KEY_INVALID') ||
          errorStr.contains('400')) {
        errorMsgText = '⚠️ **Invalid Gemini API Key**\n\n'
            'Google rejected this API key. Official Gemini API keys from **Google AI Studio** start with `AIzaSy...` (39 characters).\n\n'
            '👉 **How to fix in 1 minute:**\n'
            '1. Open [Google AI Studio (aistudio.google.com/app/apikey)](https://aistudio.google.com/app/apikey)\n'
            '2. Click **Create API key** (it is free)\n'
            '3. Copy the key starting with `AIzaSy...` and paste it into `.env` (or tap the 🔑 key icon in the top right to paste it directly).';
      } else {
        errorMsgText =
            '⚠️ **Gemini Response Error**:\n\n$e\n\nPlease check your internet connection or verify that your `GEMINI_API_KEY` is active.';
      }

      final errorMsg = AgentChatMessage(
        id: 'ai-error-${DateTime.now().millisecondsSinceEpoch}',
        text: errorMsgText,
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      messagesNotifier.value = [...messagesNotifier.value, errorMsg];
    } finally {
      isBusyNotifier.value = false;
    }
  }
}
