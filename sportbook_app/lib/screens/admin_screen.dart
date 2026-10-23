import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'qr_scanner_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> _reservations = [];
  List<dynamic> _courts = [];
  bool _isLoading = true;
  final _qrController = TextEditingController();
  String? _qrMessage;
  String? _selectedCourtId;
  DateTime _selectedDate = DateTime.now();
  String? _generateMessage;
  final _reasonController = TextEditingController();
  DateTime _blockStart = DateTime.now();
  DateTime _blockEnd = DateTime.now().add(const Duration(hours: 2));
  String? _blockMessage;

  @override
  void initState() {
    super.initState();
    _loadReservations();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    try {
      final response = await ApiService.get('/Court');
      if (response.statusCode == 200) {
        setState(() => _courts = jsonDecode(response.body));
      }
    } catch (_) {}
  }

  Future<void> _loadReservations() async {
    try {
      final response = await ApiService.get('/Admin/reservations');
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

  Future<void> _scanQR() async {
    final response = await ApiService.post('/Admin/scan', {
      'codeValue': _qrController.text.trim(),
    });
    if (response.statusCode == 200) {
      setState(() => _qrMessage = 'QR code scanned successfully!');
      _loadReservations();
    } else {
      setState(() => _qrMessage = '❌ ${response.body}');
    }
  }

  Future<void> _generateTimeSlots() async {
    if (_selectedCourtId == null) {
      setState(() => _generateMessage = 'Please select a court!');
      return;
    }
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final response = await ApiService.post('/TimeSlot/generate', {
      'courtId': _selectedCourtId,
      'date': dateStr,
    });
    if (response.statusCode == 200) {
      final body = response.body;
      if (body.contains('already exist') || body.contains('već postoje')) {
        setState(
            () => _generateMessage = 'Time slots already exist for this day!');
      } else {
        setState(
            () => _generateMessage = 'Time slots generated successfully!');
      }
    } else {
      setState(() => _generateMessage = '❌ ${response.body}');
    }
  }

  Future<void> _blockCourt() async {
    if (_selectedCourtId == null) {
      setState(() => _blockMessage = 'Please select a court!');
      return;
    }
    final adminId = await ApiService.getUserId();
    if (adminId == null) {
      setState(() => _blockMessage = 'Admin session not found.');
      return;
    }

    final response = await ApiService.post('/Admin/block', {
      'courtId': _selectedCourtId,
      'adminId': adminId,
      'blockStart': _blockStart.toIso8601String(),
      'blockEnd': _blockEnd.toIso8601String(),
      'reason': _reasonController.text.trim(),
    });
    if (response.statusCode == 200) {
      setState(() => _blockMessage = 'Court blocked successfully!');
    } else {
      setState(() => _blockMessage = '❌ ${response.body}');
    }
  }

  Future<DateTime?> _showDateTimePicker(
      BuildContext context, DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _section(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Admin Panel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _section(
              'Scan QR Code',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _qrController,
                    decoration: const InputDecoration(
                      labelText: 'QR Code Value',
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _scanQR,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Verify Code'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const QRScannerScreen()),
                          ),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Use Camera'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  if (_qrMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(_qrMessage!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
            _section(
              'Generate Time Slots',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Court'),
                    items: _courts.map<DropdownMenuItem<String>>((court) {
                      final courtId = (court['courtId'] ??
                              court['idTerena'] ??
                              '')
                          .toString();
                      final courtName =
                          (court['name'] ?? court['naziv'] ?? '').toString();
                      return DropdownMenuItem<String>(
                        value: courtId,
                        child: Text(courtName),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCourtId = value),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF2E7D32), size: 18),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _pickDate,
                        child: Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                          style: const TextStyle(
                              color: Color(0xFF2E7D32), fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _generateTimeSlots,
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Generate Slots'),
                  ),
                  if (_generateMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(_generateMessage!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
            _section(
              'Block Court',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Court'),
                    items: _courts.map<DropdownMenuItem<String>>((court) {
                      final courtId = (court['courtId'] ??
                              court['idTerena'] ??
                              '')
                          .toString();
                      final courtName =
                          (court['name'] ?? court['naziv'] ?? '').toString();
                      return DropdownMenuItem<String>(
                        value: courtId,
                        child: Text(courtName),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCourtId = value),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reasonController,
                    decoration:
                        const InputDecoration(labelText: 'Reason for block'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Start: '),
                      TextButton(
                        onPressed: () async {
                          final picked = await _showDateTimePicker(
                              context, _blockStart);
                          if (picked != null) {
                            setState(() => _blockStart = picked);
                          }
                        },
                        child: Text(
                          '${_blockStart.day.toString().padLeft(2, '0')}/${_blockStart.month.toString().padLeft(2, '0')}/${_blockStart.year} ${_blockStart.hour.toString().padLeft(2, '0')}:${_blockStart.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('End: '),
                      TextButton(
                        onPressed: () async {
                          final picked =
                              await _showDateTimePicker(context, _blockEnd);
                          if (picked != null) {
                            setState(() => _blockEnd = picked);
                          }
                        },
                        child: Text(
                          '${_blockEnd.day.toString().padLeft(2, '0')}/${_blockEnd.month.toString().padLeft(2, '0')}/${_blockEnd.year} ${_blockEnd.hour.toString().padLeft(2, '0')}:${_blockEnd.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _blockCourt,
                    icon: const Icon(Icons.block),
                    label: const Text('Block Court'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  if (_blockMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(_blockMessage!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
            _section(
              'All Reservations',
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reservations.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No reservations found.',
                                style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : Column(
                          children: _reservations.map((res) {
                            final status = (res['status'] ?? '').toString();
                            final isActive = status.toLowerCase() == 'active' ||
                                status.toLowerCase() == 'aktivna';
                            final userEmail = res['user']?['email'] ??
                                res['korisnik']?['email'] ??
                                'Unknown User';
                            final timeSlot = res['timeSlot'] ?? res['termin'];
                            final totalPrice =
                                res['totalPrice'] ?? res['ukupnaCijena'] ?? 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(userEmail,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        if (timeSlot != null)
                                          Text(
                                            '${timeSlot['date'] ?? timeSlot['datum']} • ${(timeSlot['startTime'] ?? timeSlot['pocetak'] ?? '').toString().substring(0, 5)}',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        Text('$totalPrice KM',
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
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
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}