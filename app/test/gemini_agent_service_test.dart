import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/gemini_agent_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeminiAgentService Tests', () {
    test('Initializes with default welcome message and suggestions', () {
      final service = GeminiAgentService();
      expect(service.messagesNotifier.value.isNotEmpty, isTrue);
      
      final firstMsg = service.messagesNotifier.value.first;
      expect(firstMsg.isUser, isFalse);
      expect(firstMsg.text, contains('Ask me anything'));
      expect(firstMsg.suggestedActions, isNotNull);
      expect(firstMsg.suggestedActions!.isNotEmpty, isTrue);
    });

    test('Identifies missing API key gracefully', () async {
      final service = GeminiAgentService();
      final initialCount = service.messagesNotifier.value.length;
      
      await service.sendUserMessage('Hello AI');
      
      // Should add the user message and an error/informational message explaining key is needed
      expect(service.messagesNotifier.value.length, initialCount + 2);
      final lastMsg = service.messagesNotifier.value.last;
      expect(lastMsg.isUser, isFalse);
      expect(lastMsg.isError, isTrue);
      expect(lastMsg.text, contains('Gemini API Key Required'));
    });
  });
}
