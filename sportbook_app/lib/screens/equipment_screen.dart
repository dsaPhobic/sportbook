import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class EquipmentScreen extends StatefulWidget {
  final String reservationId;

  const EquipmentScreen({super.key, required this.reservationId});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  List<dynamic> _equipmentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    try {
      final response = await ApiService.get('/Equipment');
      if (response.statusCode == 200) {
        setState(() {
          _equipmentList = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addEquipment(String equipmentId, int quantity) async {
    final response = await ApiService.post('/Equipment/add', {
      'reservationId': widget.reservationId,
      'equipmentId': equipmentId,
      'quantity': quantity,
    });

    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipment rented successfully!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        _loadEquipment();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body.isNotEmpty
                ? response.body
                : 'Failed to rent equipment.'),
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
      appBar: AppBar(title: const Text('Rent Equipment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _equipmentList.isEmpty
              ? const Center(
                  child: Text('No equipment available for rent.',
                      style: TextStyle(color: Colors.grey, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _equipmentList.length,
                  itemBuilder: (context, index) {
                    final item = _equipmentList[index];
                    final equipmentId = (item['equipmentId'] ??
                            item['idOpreme'] ??
                            '')
                        .toString();
                    final name = (item['name'] ?? item['naziv'] ?? '').toString();
                    final rentalPrice =
                        item['rentalPrice'] ?? item['cijenaPosudbe'] ?? 0;
                    final available =
                        item['availableQuantity'] ?? item['kolicinaDostupna'] ?? 0;

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
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.sports_handball,
                                  color: Color(0xFF2E7D32)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$rentalPrice KM • In Stock: $available',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: available > 0
                                  ? () => _addEquipment(equipmentId, 1)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              child: const Text('Rent'),
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
class OpremaScreen extends EquipmentScreen {
  const OpremaScreen({super.key, required String idRezervacije})
      : super(reservationId: idRezervacije);
}
