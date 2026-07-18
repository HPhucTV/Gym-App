import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerView extends StatefulWidget {
  final ValueChanged<String> onBarcodeDetected;
  final VoidCallback onClose;

  const BarcodeScannerView({
    super.key,
    required this.onBarcodeDetected,
    required this.onClose,
  });

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final MobileScannerController _controller = MobileScannerController();
  bool _detected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_detected) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final value = barcode.rawValue;
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    _detected = true;
                  });
                  HapticFeedback.mediumImpact();
                  widget.onBarcodeDetected(value);
                  break;
                }
              }
            },
          ),
          // Frame overlay matching Kotlin's Box border
          Center(
            child: Container(
              width: 280,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: const Color(0xFFF97316), // EnergyOrange
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Info text at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  "Đặt mã vạch vào khung hình để quét",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Close button at top start
          Positioned(
            top: 40,
            left: 16,
            child: ClipOval(
              child: Material(
                color: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
