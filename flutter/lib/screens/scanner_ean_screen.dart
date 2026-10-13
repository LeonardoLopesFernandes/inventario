import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/constants.dart';

/// Leitura de EAN com a câmera do aparelho (mobile_scanner).
/// Ao detectar um código, retorna o valor via Navigator.pop.
class ScannerEANScreen extends StatefulWidget {
  const ScannerEANScreen({super.key});

  @override
  State<ScannerEANScreen> createState() => _ScannerEANScreenState();
}

class _ScannerEANScreenState extends State<ScannerEANScreen> {
  late final MobileScannerController _controller;
  bool _handled = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.itf14,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.qrCode,
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    String? code;
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && v.isNotEmpty) {
        code = v;
        break;
      }
    }
    if (code == null) return;
    _handled = true;
    Navigator.of(context).pop(code);
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      if (mounted) setState(() => _torchOn = !_torchOn);
    } catch (_) {}
  }

  Future<void> _digitarEan() async {
    final controller = TextEditingController();
    final ean = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Digitar o código EAN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'EAN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Confirmar')),
        ],
      ),
    );
    if (ean != null && ean.isNotEmpty && mounted) {
      Navigator.of(context).pop(ean);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(Constants.invTextDark)),
        title: const Text(
          'Leitura de EAN',
          style: TextStyle(
              color: Color(Constants.invTextDark),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Não foi possível acessar a câmera. Verifique a permissão nas configurações do app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          // Mira de leitura (cantos brancos)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 140,
                  child: Stack(children: _buildScannerCorners()),
                ),
              ),
            ),
          ),
          // Lanterna
          Positioned(
            bottom: 90,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
                  color: const Color(Constants.primaryRed),
                ),
                onPressed: _toggleTorch,
              ),
            ),
          ),
          // Digitar o código EAN
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: _digitarEan,
                child: const Text(
                  'Digitar o código EAN',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScannerCorners() {
    return [
      Positioned(top: 0, left: 0, child: _cornerBox(top: true, left: true)),
      Positioned(top: 0, right: 0, child: _cornerBox(top: true, left: false)),
      Positioned(bottom: 0, left: 0, child: _cornerBox(top: false, left: true)),
      Positioned(
          bottom: 0, right: 0, child: _cornerBox(top: false, left: false)),
    ];
  }

  Widget _cornerBox({required bool top, required bool left}) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          bottom: !top
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          left: left
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          right: !left
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}
