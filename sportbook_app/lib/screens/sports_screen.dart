import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class SportsScreen extends StatefulWidget {
  const SportsScreen({super.key});

  @override
  State<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> {
  List<dynamic> _sports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSports();
  }

  Future<void> _loadSports() async {
    try {
      final response = await ApiService.get('/Court/sports');
      if (response.statusCode == 200) {
        setState(() {
          _sports = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Sports')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sports.isEmpty
              ? const Center(
                  child: Text('No sports available.',
                      style: TextStyle(color: Colors.grey, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sports.length,
                  itemBuilder: (context, index) {
                    final sport = _sports[index];
                    final name =
                        (sport['name'] ?? sport['naziv'] ?? '').toString();
                    final description = (sport['description'] ??
                            sport['opis'] ??
                            '')
                        .toString();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.sports,
                              color: Color(0xFF2E7D32)),
                        ),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: description.isNotEmpty
                            ? Text(description)
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}

// Backward compatibility alias
typedef SporToviScreen = SportsScreen;
