import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../widgets/app_header_bar.dart';

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
  bool _sending = false;
  bool _greeted = false;

  String get _storageKey =>
      'chat_history_${AuthService().userId ?? 'guest'}_${widget.disease}';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Chat history is persisted locally on-device only (SharedPreferences),
  // keyed per user + disease. The backend is stateless and unaware of this —
  // each request still just carries the messages the client chooses to send.
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || !mounted) return;
    try {
      final saved = (jsonDecode(raw) as List)
          .map((e) => _Message(
                text: e['text'] as String,
                isUser: e['isUser'] as bool,
              ))
          .toList();
      if (saved.isNotEmpty) {
        setState(() {
          _messages
            ..clear()
            ..addAll(saved);
          _greeted = true;
        });
      }
    } catch (_) {
      // Corrupt/old cache format — ignore and fall back to a fresh greeting.
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = _messages.length > 100
        ? _messages.sublist(_messages.length - 100)
        : _messages;
    final encoded = jsonEncode(
        trimmed.map((m) => {'text': m.text, 'isUser': m.isUser}).toList());
    await prefs.setString(_storageKey, encoded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initial greeting from AI — added here (not initState) since it needs
    // AppLocalizations, which isn't safely available until dependencies
    // are resolved.
    if (!_greeted) {
      _greeted = true;
      _messages.add(_Message(
        text: AppLocalizations.of(context).chatGreeting(widget.disease),
        isUser: false,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    // Snapshot prior turns (excluding the opening greeting) so the backend
    // can include them as context and the bot "remembers" the conversation.
    final history = _messages
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _controller.clear();
      _sending = true;
    });

    try {
      final reply = await ApiService.chat(
          message: text,
          diseaseContext: widget.disease,
          language: LanguageService.language.value,
          history: history);
      setState(() => _messages.add(_Message(text: reply, isUser: false)));
    } catch (e) {
      setState(() => _messages.add(_Message(
            text: AppLocalizations.of(context).chatErrorMessage,
            isUser: false,
          )));
    } finally {
      if (mounted) setState(() => _sending = false);
      _saveHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: BrandedAppBar(
        title: l10n.aiDermatologyAssistantTitle,
        subtitle: widget.disease,
      ),
      body: Column(
        children: [
          Expanded(
            // reverse: true anchors the latest message to the bottom, right
            // above the input bar, so when the keyboard opens it only crops
            // the view from the top instead of pushing the last message
            // and input off-screen.
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (_, i) {
                if (_sending && i == 0) {
                  return _typingIndicator();
                }
                final msgIndex =
                    _messages.length - 1 - (i - (_sending ? 1 : 0));
                return _bubble(_messages[msgIndex]);
              },
            ),
          ),
          _inputBar(l10n),
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

  Widget _inputBar(AppLocalizations l10n) => Container(
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
                decoration: InputDecoration(
                  hintText: l10n.askAboutConditionHint,
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
