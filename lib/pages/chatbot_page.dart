import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import '../controllers/chatbot_controller.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatbotController controller = Get.find<ChatbotController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      endDrawer: _buildDrawer(controller),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161824),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                Obx(() => Text(
                      controller.isStreaming.value
                          ? 'Generating…'
                          : 'Personal Trainer',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white70),
                    )),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final hasStreamingBubble =
                  controller.streamingText.value != null;
              final showTypingDot =
                  controller.isStreaming.value && !hasStreamingBubble;
              final itemCount = controller.messages.length +
                  (hasStreamingBubble ? 1 : 0) +
                  (showTypingDot ? 1 : 0);

              if (controller.messages.isEmpty &&
                  !controller.isStreaming.value) {
                return _buildEmptyState(controller);
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 16),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (showTypingDot &&
                      index == controller.messages.length) {
                    return _buildTypingIndicator();
                  }
                  if (hasStreamingBubble &&
                      index == controller.messages.length) {
                    return _buildModelBubble(
                      context,
                      controller.streamingText.value!,
                      sources: controller.streamingSources,
                      isStreaming: true,
                    );
                  }
                  return _buildMessageBubble(
                      context, controller.messages[index]);
                },
              );
            }),
          ),
          _buildInputBar(context, controller),
        ],
      ),
    );
  }

  Widget _buildDrawer(ChatbotController controller) {
    return Drawer(
      backgroundColor: const Color(0xFF161824),
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
              Get.back();
              controller.startNewChat();
            },
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: Obx(() => controller.isLoadingSessions.value
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.purple))
                : ListView.builder(
                    itemCount: controller.sessions.length,
                    itemBuilder: (context, index) {
                      final session = controller.sessions[index];
                      return Obx(() => ListTile(
                            leading: const Icon(Icons.chat_bubble_outline,
                                color: Colors.white70, size: 20),
                            title: Text(
                              session.title.isEmpty
                                  ? 'New Chat'
                                  : session.title,
                              style:
                                  const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            selected: controller.sessionId.value == session.id,
                            selectedTileColor:
                                Colors.purple.shade900.withValues(alpha: 0.5),
                            onTap: () => controller.openSession(session),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.white38, size: 20),
                              onPressed: () =>
                                  controller.deleteSession(session.id),
                            ),
                          ));
                    },
                  )),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ChatbotController controller) {
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
              'Ask me anything about\nexercise form, routines, or diet.',
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
                    label: '💪  Proper push-up form',
                    onTap: () {
                      controller.textController.text =
                          'How do I maintain proper push-up form?';
                      controller.send();
                    }),
                _SuggestionChip(
                    label: '🥗  Post-workout meal?',
                    onTap: () {
                      controller.textController.text =
                          'What is a good post-workout meal?';
                      controller.send();
                    }),
                _SuggestionChip(
                    label: '🏃  Beginner cardio routine',
                    onTap: () {
                      controller.textController.text =
                          'Can you suggest a beginner cardio routine?';
                      controller.send();
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, DisplayMessage msg) {
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
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.purple.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade900.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 16),
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

    return _buildModelBubble(context, msg.text, sources: msg.sources);
  }

  Widget _buildModelBubble(
    BuildContext context,
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
              color: const Color(0xFF161824),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: const Color(0xFF262A3D)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
                if (isStreaming) _BlinkingCursor(),
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
          color: const Color(0xFF161824),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFF262A3D)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _PulsingDot(delay: i * 200)),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ChatbotController controller) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161824),
        border: Border(top: BorderSide(color: Color(0xFF262A3D))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask about workouts, diet, form…',
                hintStyle: const TextStyle(
                    color: Colors.white38, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFF0A0C10),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => controller.send(),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => GestureDetector(
                onTap: controller.send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: controller.isStreaming.value
                        ? Colors.purple.shade900
                        : Colors.purple.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: controller.isStreaming.value
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white38),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                ),
              )),
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

// ── Helper Widgets (kept as StatefulWidget — animation only) ──────

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
