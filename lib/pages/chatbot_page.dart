import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../services/chatbot_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<_DisplayMessage> _messages = [];
  int? _sessionId;
  List<ChatSession> _sessions = [];
  bool _isLoadingSessions = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoadingSessions = true);
    try {
      final sessions = await ChatbotService.getSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoadingSessions = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSessions = false);
    }
  }

  Future<void> _openSession(ChatSession session) async {
    setState(() {
      _sessionId = session.id;
      _messages.clear();
    });
    Navigator.pop(context);

    try {
      final msgs = await ChatbotService.getMessages(session.id);
      if (mounted) {
        setState(() {
          for (var msg in msgs) {
            _messages.add(_DisplayMessage(
                role: msg.role, text: msg.text, sources: msg.sources));
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load session: $e')));
      }
    }
  }

  Future<void> _deleteSession(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('Delete Chat', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this conversation?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.purpleAccent)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ChatbotService.deleteSession(id);
      if (mounted) {
        if (_sessionId == id) {
          setState(() {
            _sessionId = null;
            _messages.clear();
          });
        }
        _loadSessions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete session: $e')));
      }
    }
  }

  Future<void> _initSession() async {
    try {
      final id = await ChatbotService.createSession();
      if (mounted) {
        setState(() {
          _sessionId = id;
        });
        _loadSessions(); // Refresh list to show newly created session
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to initialize chat: $e')));
      }
    }
  }

  String? _streamingText;
  List<String> _streamingSources = [];
  bool _isStreaming = false;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isStreaming) return;

    if (_sessionId == null) {
      await _initSession();
      if (_sessionId == null) return; // failed to create
    }

    _controller.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(_DisplayMessage(role: 'user', text: text));
      _streamingText = '';
      _streamingSources = [];
      _isStreaming = true;
    });
    _scrollToBottom();

    final String userText = text;

    try {
      await for (final event in ChatbotService.sendMessageStream(
        sessionId: _sessionId!,
        message: userText,
      )) {
        switch (event) {
          case ChatStreamSources(:final sources):
            setState(() => _streamingSources = sources);

          case ChatStreamChunk(:final text):
            setState(() => _streamingText = (_streamingText ?? '') + text);
            _scrollToBottom();

          case ChatStreamDone():
            final answer = _streamingText ?? '';
            setState(() {
              _messages.add(_DisplayMessage(
                role: 'model',
                text: answer,
                sources: List.from(_streamingSources),
              ));
              _streamingText = null;
              _streamingSources = [];
              _isStreaming = false;
            });

          case ChatStreamError(:final message):
            setState(() {
              _messages.add(_DisplayMessage(role: 'error', text: message));
              _streamingText = null;
              _isStreaming = false;
            });
        }
      }
    } catch (e) {
      setState(() {
        _messages.add(_DisplayMessage(
            role: 'error', text: e.toString().replaceFirst('Exception: ', '')));
        _streamingText = null;
        _isStreaming = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasStreamingBubble = _streamingText != null;
    final showTypingDot = _isStreaming && !hasStreamingBubble;

    final itemCount = _messages.length +
        (hasStreamingBubble ? 1 : 0) +
        (showTypingDot ? 1 : 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      endDrawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.purple.shade600,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Assistant',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  _isStreaming ? 'Generating…' : 'Automotive & Electronics',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_isStreaming
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (showTypingDot && index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      if (hasStreamingBubble && index == _messages.length) {
                        return _buildModelBubble(
                          _streamingText!,
                          sources: _streamingSources,
                          isStreaming: true,
                        );
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E2E),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.purple.shade900),
            child: const Center(
              child: Text(
                'Chat History',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline,
                color: Colors.purpleAccent),
            title:
                const Text('New Chat', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _sessionId = null;
              });
            },
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: _isLoadingSessions
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.purple))
                : ListView.builder(
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline,
                            color: Colors.white70, size: 20),
                        title: Text(
                          session.title.isEmpty ? 'New Chat' : session.title,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: _sessionId == session.id,
                        selectedTileColor:
                            Colors.purple.shade900.withValues(alpha: 0.5),
                        onTap: () => _openSession(session),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white38, size: 20),
                          onPressed: () => _deleteSession(session.id),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.shade900.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy_outlined,
                  size: 48, color: Colors.purple.shade300),
            ),
            const SizedBox(height: 16),
            const Text('AI Assistant',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Ask me anything about\nautomotive vehicles or electronics.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                    label: '🎮  Tell me about the PS5',
                    onTap: () {
                      _controller.text = 'Tell me about the PS5';
                      _send();
                    }),
                _SuggestionChip(
                    label: '🚗  Mitsubishi Lancer Evo?',
                    onTap: () {
                      _controller.text =
                          'What is the Mitsubishi Lancer Evo?';
                      _send();
                    }),
                _SuggestionChip(
                    label: '💻  MacBook Pro features',
                    onTap: () {
                      _controller.text =
                          'What are the features of the MacBook Pro?';
                      _send();
                    }),
                _SuggestionChip(
                    label: '✈️  Tell me about the Boeing 737',
                    onTap: () {
                      _controller.text = 'Tell me about the Boeing 737';
                      _send();
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_DisplayMessage msg) {
    if (msg.role == 'user') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.purple.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(msg.text,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.45)),
            ),
          ],
        ),
      );
    }

    if (msg.role == 'error') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.shade900.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade800),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(msg.text,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }

    return _buildModelBubble(msg.text, sources: msg.sources);
  }

  Widget _buildModelBubble(
    String text, {
    List<String>? sources,
    bool isStreaming = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.88),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: text.isEmpty && isStreaming ? ' ' : text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.5),
                    strong: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    h1: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    h2: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    h3: TextStyle(
                        color: Colors.purple.shade200,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    listBullet: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                    code: const TextStyle(
                        color: Colors.greenAccent,
                        backgroundColor: Color(0xFF0D1117),
                        fontFamily: 'monospace',
                        fontSize: 13),
                    blockquoteDecoration: BoxDecoration(
                      color: Colors.purple.shade900.withValues(alpha: 0.3),
                      border: Border(
                          left: BorderSide(
                              color: Colors.purple.shade400, width: 3)),
                    ),
                  ),
                ),
                if (isStreaming)
                  _BlinkingCursor(),
              ],
            ),
          ),

          if (sources != null && sources.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 4),
              child: GestureDetector(
                onTap: () => _showSources(context, sources),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade900.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.purple.shade700, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories_outlined,
                          size: 11, color: Colors.purple.shade300),
                      const SizedBox(width: 5),
                      Text(
                        '${sources.length} source${sources.length > 1 ? 's' : ''}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.purple.shade300),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _PulsingDot(delay: i * 200)),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask about a car, phone, laptop…',
                hintStyle: const TextStyle(
                    color: Colors.white38, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFF0F0F1A),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isStreaming
                    ? Colors.purple.shade900
                    : Colors.purple.shade600,
                shape: BoxShape.circle,
              ),
              child: _isStreaming
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white38),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showSources(BuildContext context, List<String> sources) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.source_outlined,
                  color: Colors.purple.shade300, size: 18),
              const SizedBox(width: 8),
              const Text('Sources used',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 14),
            ...sources.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Icon(Icons.article_outlined,
                        size: 14, color: Colors.purple.shade200),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(s,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13))),
                  ]),
                )),
          ],
        ),
      ),
    );
  }
}

class _DisplayMessage {
  final String role;
  final String text;
  final List<String>? sources;

  _DisplayMessage({required this.role, required this.text, this.sources});
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple.shade900.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.shade700, width: 1),
        ),
        child: Text(label,
            style: TextStyle(color: Colors.purple.shade200, fontSize: 12)),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        width: 2,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.purple.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final int delay;
  const _PulsingDot({required this.delay});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.purple.shade300,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
