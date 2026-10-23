import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _scanned = false;
  String? _message;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue;
    if (code == null) return;

    setState(() => _scanned = true);

    final response = await ApiService.post('/Admin/scan', {
      'codeValue': code,
    });

    if (response.statusCode == 200) {
      setState(() => _message = 'QR code scanned successfully!');
    } else {
      setState(() => _message = '❌ Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _message != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(_message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            _scanned = false;
                            _message = null;
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Scan Again'),
                        ),
                      ],
                    ),
                  )
                : MobileScanner(onDetect: _onDetect),
          ),
        ],
      ),
    );
  }
}

// Backward compatibility alias
typedef QrScannerScreen = QRScannerScreen;