import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'reservation_screen.dart';

class TimeSlotScreen extends StatefulWidget {
  final String courtId;
  final String courtName;

  const TimeSlotScreen({
    super.key,
    required this.courtId,
    required this.courtName,
  });

  @override
  State<TimeSlotScreen> createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
  List<dynamic> _timeSlots = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    setState(() {
      _isLoading = true;
      _timeSlots = [];
    });
    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final response =
          await ApiService.get('/TimeSlot/${widget.courtId}/$dateStr');
      if (response.statusCode == 200) {
        setState(() => _timeSlots = jsonDecode(response.body));
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadTimeSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: Text(widget.courtName)),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loadTimeSlots,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _timeSlots.isEmpty
                    ? const Center(
                        child: Text('No time slots available for this date.',
                            style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : ListView.builder(
                        key: ValueKey(_timeSlots.length),
                        padding: const EdgeInsets.all(16),
                        itemCount: _timeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = _timeSlots[index];
                          final slotId = (slot['timeSlotId'] ?? slot['idTermina']).toString();
                          final status = (slot['status'] ?? '').toString().toLowerCase();
                          final isAvailable = status == 'free' || status == 'slobodan';
                          final startRaw = (slot['startTime'] ?? slot['pocetak'] ?? '').toString();
                          final endRaw = (slot['endTime'] ?? slot['kraj'] ?? '').toString();
                          final start = startRaw.length >= 5 ? startRaw.substring(0, 5) : startRaw;
                          final end = endRaw.length >= 5 ? endRaw.substring(0, 5) : endRaw;
                          final price = (slot['price'] ?? slot['cijena'] ?? 0).toString();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.access_time,
                                  color: isAvailable
                                      ? const Color(0xFF2E7D32)
                                      : Colors.red,
                                ),
                              ),
                              title: Text(
                                '$start - $end',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text('$price KM',
                                  style: const TextStyle(color: Colors.grey)),
                              trailing: isAvailable
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ReservationScreen(
                                              timeSlotId: slotId,
                                              startTime: start,
                                              endTime: end,
                                              price: price,
                                            ),
                                          ),
                                        );
                                        _loadTimeSlots();
                                      },
                                      child: const Text('Book'),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Booked',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500)),
                                    ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
