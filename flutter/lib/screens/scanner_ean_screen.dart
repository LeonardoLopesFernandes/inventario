import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Tela de leitura de EAN. A câmera real será ligada quando adicionarmos o
/// pacote de barcode; por ora, o código é digitado pelo botão inferior.
/// Retorna o EAN via Navigator.pop.
class ScannerEANScreen extends StatefulWidget {
  const ScannerEANScreen({super.key});

  @override
  State<ScannerEANScreen> createState() => _ScannerEANScreenState();
}

class _ScannerEANScreenState extends State<ScannerEANScreen> {
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
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(Constants.invTextDark), width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('IA',
                style: TextStyle(
                    color: Color(Constants.invTextDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.notifications_none,
                    color: Color(Constants.invTextDark)),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                      color: Color(Constants.primaryRed), shape: BoxShape.circle),
                  child: const Text('9',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Espaço reservado para a pré-visualização da câmera.
          Container(color: Colors.grey.shade400),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white24,
                border: Border.all(color: Colors.white38, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(children: _buildScannerCorners()),
            ),
          ),
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
                icon: const Icon(Icons.flashlight_on,
                    color: Color(Constants.primaryRed)),
                onPressed: () {},
              ),
            ),
          ),
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
                      color: Color(Constants.primaryRed),
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
      width: 24,
      height: 24,
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
