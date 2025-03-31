import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/models/Production.dart';
import 'package:theatrical_plays/models/Movie.dart';

class ActorsService {
  static const String baseUrl = 'http://your-api-url.com'; // TODO: replace
  static const String token = 'your-jwt-token'; // TODO: secure this later

  // Fetches actor info by ID
  Future<Actor> getActorInfo(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/people/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return Actor.fromJson(data);
    } else {
      throw Exception('Failed to load actor info: ${response.statusCode}');
    }
  }

  // Fetches productions + roles
  Future<List<Production>> fetchProdsForActor(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/people/$id/productions?page=0&size=20'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data']['results'];
      return List<Production>.from(data.map((item) {
        final prod = item['production'];
        final role = item['role'] ?? '';
        return Production.fromJson(prod, role: role);
      }));
    } else {
      throw Exception('Failed to load productions: ${response.statusCode}');
    }
  }

  // Optional: Also return Movie list for UI
  Future<List<Movie>> fetchMoviesForActor(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/people/$id/productions?page=0&size=20'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data']['results'];
      return List<Movie>.from(data.map((item) {
        final prod = item['production'];
        return Movie.fromJson(prod);
      }));
    } else {
      throw Exception('Failed to load movies: ${response.statusCode}');
    }
  }
}
