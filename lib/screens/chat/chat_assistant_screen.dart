// lib/screens/chat/chat_assistant_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';

class ChatAssistantScreen extends StatefulWidget {
  const ChatAssistantScreen({super.key});

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  final _scrollController = ScrollController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Message initial de l'assistant
    _messages.add(
      ChatMessage(
        sender: MessageSender.assistant,
        content: "Bonjour! Je suis l'assistant IA des Archives Nationales. "
            "Je peux vous aider à analyser, comprendre et classifier vos documents. "
            "Comment puis-je vous aider aujourd'hui?",
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleFilePick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        setState(() {
          _messages.add(ChatMessage(
            sender: MessageSender.user,
            content: "Document envoyé : ${result.files.first.name}",
            timestamp: DateTime.now(),
            attachedFile: result.files.first,
          ));
          _isLoading = true;
        });

        // Simuler l'analyse du document
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _messages.add(ChatMessage(
            sender: MessageSender.assistant,
            content: """J'ai analysé votre document. Voici mes observations :
            
• Type de document : Correspondance administrative
• Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
• Service émetteur : Direction des ressources humaines
• Niveau de confidentialité : Standard
• DUA recommandée : 5 ans

Souhaitez-vous que je procède à l'archivage automatique avec ces paramètres ?""",
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });

        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la sélection du fichier')),
      );
    }
  }

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        sender: MessageSender.user,
        content: _messageController.text,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isLoading = true;
    });

    // Simuler une réponse de l'assistant
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(ChatMessage(
          sender: MessageSender.assistant,
          content: "Je vais vous aider à traiter cette demande. "
              "Pouvez-vous me donner plus de détails ou me fournir le document concerné ?",
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assistant, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistant IA',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Assistant virtuel pour la classification et la compréhension des documents',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Column(
        children: [
          // Zone des messages
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),

          // Indicateur de chargement
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                // Bouton d'upload
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _handleFilePick,
                  tooltip: 'Joindre un document',
                ),
                const SizedBox(width: 16),
                // Champ de texte
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Posez une question ou demandez une analyse...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 16),
                // Bouton d'envoi
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _messageController.text.trim().isEmpty
                      ? null
                      : _handleSendMessage,
                  color: AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isAssistant = message.sender == MessageSender.assistant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isAssistant ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAssistant) _buildAvatar(true),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAssistant ? Colors.white : AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isAssistant ? Colors.black87 : Colors.white,
                    ),
                  ),
                  // Attached file if any
                  if (message.attachedFile != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isAssistant
                            ? Colors.grey[100]
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.file_present,
                            size: 20,
                            color: isAssistant
                                ? AppTheme.primaryBlue
                                : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              message.attachedFile!.name,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isAssistant ? Colors.black87 : Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (!isAssistant) _buildAvatar(false),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isAssistant) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isAssistant
            ? AppTheme.primaryBlue.withOpacity(0.1)
            : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        isAssistant ? Icons.assistant : Icons.person,
        size: 16,
        color: isAssistant ? AppTheme.primaryBlue : Colors.grey[600],
      ),
    );
  }
}

enum MessageSender { user, assistant }

class ChatMessage {
  final MessageSender sender;
  final String content;
  final DateTime timestamp;
  final PlatformFile? attachedFile;

  ChatMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
    this.attachedFile,
  });
}
