import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../../../../utils/network/retry.dart';

class EventService {
  static const baseUrl = "https://udbconnect.com/api";

  Future<List<EventModel>> fetchEvents(String token) async {
    final response = await retry(() async {
      return await http
          .get(
            Uri.parse("$baseUrl/events"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final List<dynamic> eventsJson = data['data'] ?? [];

      return eventsJson
          .map(
            (eventJson) =>
                EventModel.fromJson(eventJson as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception("Failed to fetch events: ${response.body}");
    }
  }
}
