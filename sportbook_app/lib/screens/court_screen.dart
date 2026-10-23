import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'court_details_screen.dart';

class CourtScreen extends StatefulWidget {
  const CourtScreen({super.key});

  @override
  State<CourtScreen> createState() => _CourtScreenState();
}

class _CourtScreenState extends State<CourtScreen> {
  List<dynamic> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    try {
      final response = await ApiService.get('/Court');
      if (response.statusCode == 200) {
        setState(() {
          final list = jsonDecode(response.body) as List;
          list.sort((a, b) {
            final nameA = (a['name'] ?? a['naziv'] ?? '').toString();
            final nameB = (b['name'] ?? b['naziv'] ?? '').toString();
            return nameA.compareTo(nameB);
          });
          _courts = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Courts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courts.isEmpty
              ? const Center(
                  child: Text('No courts available.',
                      style: TextStyle(color: Colors.grey, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _courts.length,
                  itemBuilder: (context, index) {
                    final court = _courts[index];
                    final name = court['name'] ?? court['naziv'] ?? '';
                    final surface = court['surfaceType'] ?? court['tipPodloge'] ?? '';
                    final rating = court['averageRating'] ?? court['prosjecnaOcjena'];
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
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.sports_tennis,
                              color: Color(0xFF2E7D32)),
                        ),
                        title: Text(name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(surface.isNotEmpty
                            ? (rating != null
                                ? '$surface • ★ ${rating.toStringAsFixed(1)}'
                                : surface)
                            : (rating != null ? '★ ${rating.toStringAsFixed(1)}' : '')),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourtDetailsScreen(court: court),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
