import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/chatbot_service.dart';

class DisplayMessage {
  final String role;
  final String text;
  final List<String>? sources;

  DisplayMessage({required this.role, required this.text, this.sources});
}

class ChatbotController extends GetxController {
  final RxList<DisplayMessage> messages = <DisplayMessage>[].obs;
  final RxList<ChatSession> sessions = <ChatSession>[].obs;
  final Rx<int?> sessionId = Rx<int?>(null);
  final RxBool isLoadingSessions = false.obs;
  final RxBool isStreaming = false.obs;
  final Rx<String?> streamingText = Rx<String?>(null);
  final RxList<String> streamingSources = <String>[].obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadSessions() async {
    isLoadingSessions.value = true;
    try {
      final result = await ChatbotService.getSessions();
      sessions.assignAll(result);
    } catch (_) {
      // ignore session load errors
    } finally {
      isLoadingSessions.value = false;
    }
  }

  Future<void> openSession(ChatSession session) async {
    sessionId.value = session.id;
    messages.clear();
    Get.back(); // close drawer

    try {
      final msgs = await ChatbotService.getMessages(session.id);
      messages.assignAll(msgs
          .map((m) => DisplayMessage(role: m.role, text: m.text, sources: m.sources))
          .toList());
      scrollToBottom();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load session: $e',
          backgroundColor: const Color(0xFF1E1E2E),
          colorText: const Color(0xFFFF6B6B));
    }
  }

  Future<void> deleteSession(int id) async {
    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Delete Chat', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this conversation?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.purpleAccent)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ChatbotService.deleteSession(id);
      if (sessionId.value == id) {
        sessionId.value = null;
        messages.clear();
      }
      await loadSessions();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete session: $e',
          backgroundColor: const Color(0xFF1E1E2E),
          colorText: const Color(0xFFFF6B6B));
    }
  }

  Future<void> initSession() async {
    try {
      final id = await ChatbotService.createSession();
      sessionId.value = id;
      await loadSessions();
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize chat: $e',
          backgroundColor: const Color(0xFF1E1E2E),
          colorText: const Color(0xFFFF6B6B));
    }
  }

  Future<void> send() async {
    final text = textController.text.trim();
    if (text.isEmpty || isStreaming.value) return;

    if (sessionId.value == null) {
      await initSession();
      if (sessionId.value == null) return;
    }

    textController.clear();

    messages.add(DisplayMessage(role: 'user', text: text));
    streamingText.value = '';
    streamingSources.clear();
    isStreaming.value = true;
    scrollToBottom();

    try {
      await for (final event in ChatbotService.sendMessageStream(
        sessionId: sessionId.value!,
        message: text,
      )) {
        switch (event) {
          case ChatStreamSources(:final sources):
            streamingSources.assignAll(sources);

          case ChatStreamChunk(:final text):
            streamingText.value = (streamingText.value ?? '') + text;
            scrollToBottom();

          case ChatStreamDone():
            final answer = streamingText.value ?? '';
            messages.add(DisplayMessage(
              role: 'model',
              text: answer,
              sources: List.from(streamingSources),
            ));
            streamingText.value = null;
            streamingSources.clear();
            isStreaming.value = false;

          case ChatStreamError(:final message):
            messages.add(DisplayMessage(role: 'error', text: message));
            streamingText.value = null;
            isStreaming.value = false;
        }
      }
    } catch (e) {
      messages.add(DisplayMessage(
          role: 'error', text: e.toString().replaceFirst('Exception: ', '')));
      streamingText.value = null;
      isStreaming.value = false;
    }

    scrollToBottom();
  }

  void startNewChat() {
    messages.clear();
    sessionId.value = null;
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
