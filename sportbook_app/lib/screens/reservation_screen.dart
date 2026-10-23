import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'qr_screen.dart';

class ReservationScreen extends StatefulWidget {
  final String timeSlotId;
  final String startTime;
  final String endTime;
  final String price;

  const ReservationScreen({
    super.key,
    required this.timeSlotId,
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _noteController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _createReservation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await ApiService.getUserId();
      if (userId == null) {
        setState(() => _error = 'User session expired. Please log in again.');
        return;
      }

      final response = await ApiService.post('/Reservation', {
        'userId': userId,
        'timeSlotId': widget.timeSlotId,
        'note': _noteController.text.trim(),
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final qrCodeValue = data['qrCode']?['codeValue'] ??
            data['qrKod']?['kodVrijednost'] ??
            '';

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QRCodeScreen(codeValue: qrCodeValue),
            ),
          );
        }
      } else {
        setState(() => _error =
            response.body.isNotEmpty ? response.body : 'Reservation failed.');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Confirm Reservation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
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
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Slot Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Color(0xFF2E7D32), size: 20),
                      const SizedBox(width: 8),
                      Text('${widget.startTime} - ${widget.endTime}',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.payments,
                          color: Color(0xFF2E7D32), size: 20),
                      const SizedBox(width: 8),
                      Text('${widget.price} KM',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child:
                    Text(_error!, style: TextStyle(color: Colors.red.shade700)),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _createReservation,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18)),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Confirm Reservation',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
