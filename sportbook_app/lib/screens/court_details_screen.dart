import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'time_slot_screen.dart';

class CourtDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> court;

  const CourtDetailsScreen({super.key, required this.court});

  @override
  State<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen> {
  List<dynamic> _reviews = [];
  Map<String, dynamic>? _courtDetails;
  bool _isLoading = true;

  String get _courtId =>
      (widget.court['courtId'] ?? widget.court['idTerena']).toString();

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadReviews();
  }

  Future<void> _loadDetails() async {
    try {
      final response = await ApiService.get('/Court/$_courtId');
      if (response.statusCode == 200) {
        setState(() => _courtDetails = jsonDecode(response.body));
      }
    } catch (_) {}
  }

  Future<void> _loadReviews() async {
    try {
      final response = await ApiService.get('/Review/court/$_courtId');
      if (response.statusCode == 200) {
        setState(() {
          _reviews = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final court = _courtDetails ?? widget.court;
    final courtName = (court['name'] ?? court['naziv'] ?? '').toString();
    final surface = (court['surfaceType'] ?? court['tipPodloge'] ?? 'N/A').toString();
    final capacity = court['playerCapacity'] ?? court['kapacitetIgraca'] ?? 0;
    final isIndoor = court['isIndoor'] ?? court['jeUnutarnji'] ?? false;
    final workingHoursList = court['workingHours'] ?? court['radnaVremena'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: Text(courtName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(courtName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _infoRow(Icons.layers, 'Surface', surface),
                  _infoRow(Icons.people, 'Capacity', '$capacity players'),
                  _infoRow(Icons.home, 'Type', isIndoor ? 'Indoor' : 'Outdoor'),
                  if (workingHoursList != null && workingHoursList is List) ...[
                    const SizedBox(height: 12),
                    const Text('Working Hours:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...(List.from(workingHoursList)
                          ..sort((a, b) {
                            final daVal = a['dayOfWeek'] ?? a['danUSedmici'] ?? 0;
                            final dbVal = b['dayOfWeek'] ?? b['danUSedmici'] ?? 0;
                            int da = daVal == 0 ? 7 : daVal;
                            int db = dbVal == 0 ? 7 : dbVal;
                            return da.compareTo(db);
                          }))
                        .map((wh) {
                      const days = [
                        'Sun',
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat'
                      ];
                      final dayIdx = wh['dayOfWeek'] ?? wh['danUSedmici'] ?? 0;
                      final start = (wh['startTime'] ?? wh['pocetakRada'] ?? '')
                          .toString();
                      final end = (wh['endTime'] ?? wh['krajRada'] ?? '')
                          .toString();
                      final startFormatted =
                          start.length >= 5 ? start.substring(0, 5) : start;
                      final endFormatted =
                          end.length >= 5 ? end.substring(0, 5) : end;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 16, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 8),
                            Text(
                                '${days[dayIdx % 7]}: $startFormatted - $endFormatted'),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimeSlotScreen(
                      courtId: _courtId,
                      courtName: courtName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book a Time Slot',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 24),
            const Text('Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                            child: Text('No reviews for this court yet.',
                                style: TextStyle(color: Colors.grey))),
                      )
                    : Column(
                        children: _reviews.map((rec) {
                          final rating = rec['rating'] ?? rec['ocjena'] ?? 5;
                          final comment = (rec['comment'] ?? rec['komentar'] ?? '')
                              .toString();
                          final userName = rec['reservation']?['user']?['firstName'] ??
                              rec['rezervacija']?['korisnik']?['ime'] ??
                              'Anonymous';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8)
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                      5,
                                      (i) => Icon(
                                            i < rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 20,
                                          )),
                                ),
                                if (comment.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(comment),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
