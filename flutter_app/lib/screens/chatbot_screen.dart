import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';

class _Message {
  final String text;
  final bool isUser;
  _Message({required this.text, required this.isUser});
}

class ChatbotScreen extends StatefulWidget {
  final String disease;
  const ChatbotScreen({super.key, required this.disease});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messages = <_Message>[];
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Initial greeting from AI
    _messages.add(_Message(
      text:
          'Hello! I\'m your DermaVision+ assistant. You have been diagnosed with **${widget.disease}**. '
          'Feel free to ask me any questions about your condition, symptoms, or treatment options.',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _controller.clear();
      _sending = true;
    });
    _scrollToBottom();

    try {
      final reply = await ApiService.chat(
          message: text,
          diseaseContext: widget.disease,
          language: LanguageService.language.value);
      setState(() => _messages.add(_Message(text: reply, isUser: false)));
    } catch (e) {
      setState(() => _messages.add(_Message(
            text: 'Sorry, I couldn\'t process your request. Please try again.',
            isUser: false,
          )));
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: const Color(0xFF1A1A2E)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Dermatology Assistant',
                style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            Text(widget.disease,
                style: const TextStyle(
                    color: Color(0xFF0B6E6E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (_, i) {
                if (_sending && i == _messages.length) {
                  return _typingIndicator();
                }
                return _bubble(_messages[i]);
              },
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _bubble(_Message msg) {
    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment:
            msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: msg.isUser
                ? const Color(0xFF0B6E6E)
                : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft:
                  Radius.circular(msg.isUser ? 18 : 4),
              bottomRight:
                  Radius.circular(msg.isUser ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              fontSize: 14,
              color:
                  msg.isUser ? Colors.white : const Color(0xFF1A1A2E),
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator() => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: const SizedBox(
            width: 40,
            child: LinearProgressIndicator(
              color: Color(0xFF0B6E6E),
              backgroundColor: Color(0xFFA8EDDC),
            ),
          ),
        ),
      );

  Widget _inputBar() => Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Ask about your condition...',
                  filled: true,
                  fillColor: Color(0xFFF0F4F8),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B6E6E), Color(0xFF1A9E9E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      );
}
