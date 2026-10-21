import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Backend API base URL
  static const String baseUrl = 'http://localhost:5029/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> saveUser(String id, String name, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('name', name);
    await prefs.setString('role', role);
    // Backward compatibility aliases
    await prefs.setString('idKorisnika', id);
    await prefs.setString('ime', name);
    await prefs.setString('uloga', role);
  }

  // Alias for backward compatibility
  static Future<void> saveKorisnik(String id, String ime, String uloga) =>
      saveUser(id, ime, uloga);

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? prefs.getString('idKorisnika');
  }

  // Alias for backward compatibility
  static Future<String?> getIdKorisnika() => getUserId();

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? prefs.getString('uloga');
  }

  // Alias for backward compatibility
  static Future<String?> getUloga() => getRole();

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? prefs.getString('ime');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<http.Response> get(String endpoint) async {
    final token = await getToken();
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String endpoint) async {
    final token = await getToken();
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}