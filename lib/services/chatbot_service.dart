import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../auth/auth_service.dart';

class ChatMessage {
  final String role;
  final String text;
  final List<String>? sources;

  ChatMessage({required this.role, required this.text, this.sources});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      text: json['text'] as String,
      sources: json['sources'] != null
          ? (json['sources'] as List).cast<String>()
          : null,
    );
  }
}

class ChatSession {
  final String id;
  final String title;

  ChatSession({required this.id, required this.title});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }
}

sealed class ChatStreamEvent {}

class ChatStreamChunk extends ChatStreamEvent {
  final String text;
  ChatStreamChunk(this.text);
}

class ChatStreamSources extends ChatStreamEvent {
  final List<String> sources;
  ChatStreamSources(this.sources);
}

class ChatStreamDone extends ChatStreamEvent {}

class ChatStreamError extends ChatStreamEvent {
  final String message;
  ChatStreamError(this.message);
}

class ChatbotService {
  static final _authService = AuthService();

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not logged in');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<String> createSession() async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse(AppConfig.chatbotSessionsEndpoint),
      headers: headers,
      body: jsonEncode({'title': 'New Chat'}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'] as String;
    } else {
      throw Exception('Failed to create session: ${response.statusCode}');
    }
  }

  static Future<List<ChatMessage>> getMessages(String sessionId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.chatbotSessionsEndpoint}/$sessionId/messages'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch messages: ${response.statusCode}');
    }
  }

  static Future<List<ChatSession>> getSessions() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.chatbotSessionsEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ChatSession.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch sessions: ${response.statusCode}');
    }
  }

  static Future<void> deleteSession(String sessionId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('${AppConfig.chatbotSessionsEndpoint}/$sessionId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete session: ${response.statusCode}');
    }
  }

  static Future<({String answer, List<String> sources})> sendMessage({
    required String sessionId,
    required String message,
  }) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse(AppConfig.chatbotChatEndpoint(sessionId)),
      headers: headers,
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (
        answer: data['answer'] as String,
        sources: (data['sources'] as List).cast<String>(),
      );
    } else {
      final detail = jsonDecode(response.body)['detail'] ?? 'Unknown error';
      throw Exception('Chatbot error ${response.statusCode}: $detail');
    }
  }

  static Stream<ChatStreamEvent> sendMessageStream({
    required String sessionId,
    required String message,
  }) async* {
    final token = await _authService.getToken();
    if (token == null) {
      yield ChatStreamError('User not logged in');
      return;
    }

    final client = http.Client();
    try {
      final request = http.Request(
        'POST',
        Uri.parse(AppConfig.chatbotStreamEndpoint(sessionId)),
      );
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Authorization'] = 'Bearer $token';
      request.body = jsonEncode({'message': message});

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        yield ChatStreamError(
            'Server error ${streamedResponse.statusCode}: $body');
        return;
      }

      String buffer = '';

      await for (final bytes in streamedResponse.stream) {
        buffer += utf8.decode(bytes);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();

          Map<String, dynamic> event;
          try {
            event = jsonDecode(data) as Map<String, dynamic>;
          } catch (_) {
            continue;
          }

          switch (event['type']) {
            case 'sources':
              yield ChatStreamSources((event['sources'] as List).cast<String>());
            case 'chunk':
              yield ChatStreamChunk(event['text'] as String);
            case 'done':
              yield ChatStreamDone();
              return;
            case 'error':
              yield ChatStreamError(event['message'] as String);
              return;
          }
        }
      }
    } finally {
      client.close();
    }
  }
}
