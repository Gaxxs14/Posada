import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

class AiConciergeScreen extends ConsumerStatefulWidget {
  const AiConciergeScreen({super.key});

  @override
  ConsumerState<AiConciergeScreen> createState() => _AiConciergeScreenState();
}

class _AiConciergeScreenState extends ConsumerState<AiConciergeScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '¡Hola! 🏖️ Soy tu Asistente Virtual de Posada Pro.\n¿En qué puedo ayudarte hoy? Puedo informarte sobre nuestras habitaciones, tours en lancha, desayunos, horarios de check-in o la tasa de cambio.',
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: ['Ver habitaciones', '¿Cuáles son los horarios de check-in?', 'Tours a los cayos', 'Tasa oficial BCV'],
    ),
  ];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/api/aiconcierge/ask',
        data: {'userMessage': trimmed},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final replyText = data['replyText'] ?? 'Disculpa, no entendí tu consulta.';
        final List<String> suggestions = (data['suggestedActions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              text: replyText,
              isUser: false,
              timestamp: DateTime.now(),
              suggestions: suggestions,
            ));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Lo siento, ocurrió un error al consultar el asistente. Intenta de nuevo.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryTeal.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppTheme.secondaryTeal, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Concierge Virtual IA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Posada Pro • Asistencia 24/7', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('El Concierge está escribiendo...', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ),

              // Input Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        decoration: const InputDecoration(
                          hintText: 'Pregunta sobre habitaciones, tours, wifi, comidas...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                      onPressed: () => _sendMessage(_inputController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 550),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: msg.isUser ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: msg.isUser ? const Radius.circular(0) : const Radius.circular(18),
                  bottomLeft: !msg.isUser ? const Radius.circular(0) : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.white : AppTheme.textDark,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

            // Quick suggestion chips
            if (!msg.isUser && msg.suggestions != null && msg.suggestions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: msg.suggestions!.map((s) {
                  return ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue)),
                    backgroundColor: AppTheme.primaryBlue.withAlpha(15),
                    side: BorderSide(color: AppTheme.primaryBlue.withAlpha(40)),
                    onPressed: () => _sendMessage(s),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  });
}
