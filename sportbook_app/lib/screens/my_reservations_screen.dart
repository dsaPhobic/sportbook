import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'equipment_screen.dart';
import 'review_screen.dart';
import 'qr_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final userId = await ApiService.getUserId();
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final response = await ApiService.get('/Reservation/user/$userId');
      if (response.statusCode == 200) {
        setState(() {
          _reservations = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelReservation(String reservationId) async {
    final response = await ApiService.put('/Reservation/$reservationId/cancel');
    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation successfully cancelled.'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
      _loadReservations();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body.isNotEmpty
                ? response.body
                : 'Failed to cancel reservation.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('My Reservations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? const Center(
                  child: Text('You have no reservations.',
                      style: TextStyle(color: Colors.grey, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final res = _reservations[index];
                    final reservationId = (res['reservationId'] ??
                            res['idRezervacije'] ??
                            '')
                        .toString();
                    final status = (res['status'] ?? '').toString();
                    final isActive = status.toLowerCase() == 'active' ||
                        status.toLowerCase() == 'aktivna';
                    final totalPrice =
                        res['totalPrice'] ?? res['ukupnaCijena'] ?? 0;
                    final note =
                        (res['note'] ?? res['napomena'] ?? '').toString();
                    final timeSlot = res['timeSlot'] ?? res['termin'];
                    final qrCode = res['qrCode'] ?? res['qrKod'];
                    final codeValue =
                        qrCode?['codeValue'] ?? qrCode?['kodVrijednost'];

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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF2E7D32)
                                            .withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isActive ? 'ACTIVE' : 'CANCELLED',
                                    style: TextStyle(
                                      color: isActive
                                          ? const Color(0xFF2E7D32)
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$totalPrice KM',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (timeSlot != null) ...[
                              if (timeSlot['courtName'] != null ||
                                  timeSlot['nazivTerena'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.sports_tennis,
                                          size: 16, color: Color(0xFF2E7D32)),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${timeSlot['courtName'] ?? timeSlot['nazivTerena']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 8),
                                  Text(
                                      '${timeSlot['date'] ?? timeSlot['datum']}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16, color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(timeSlot['startTime'] ?? timeSlot['pocetak'] ?? '').toString().substring(0, 5)} - ${(timeSlot['endTime'] ?? timeSlot['kraj'] ?? '').toString().substring(0, 5)}',
                                  ),
                                ],
                              ),
                            ],
                            if (note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.note,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(note,
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (codeValue != null &&
                                    codeValue.toString().isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => QRCodeScreen(
                                              codeValue: codeValue.toString()),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.qr_code, size: 16),
                                    label: const Text('QR Code'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                if (isActive) ...[
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _cancelReservation(reservationId),
                                    icon: const Icon(Icons.cancel, size: 16),
                                    label: const Text('Cancel'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EquipmentScreen(
                                              reservationId: reservationId),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.sports_handball,
                                        size: 16),
                                    label: const Text('Equipment'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReviewScreen(
                                              reservationId: reservationId),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.star, size: 16),
                                    label: const Text('Review'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// Backward compatibility alias
typedef MojeRezervacijeScreen = MyReservationsScreen;
