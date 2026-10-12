import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Tela de leitura de EAN. Por enquanto, entrada manual do código
/// (a câmera será ligada quando adicionarmos o pacote de barcode).
/// Retorna o EAN digitado via Navigator.pop.
class ScannerEANScreen extends StatefulWidget {
  const ScannerEANScreen({super.key});

  @override
  State<ScannerEANScreen> createState() => _ScannerEANScreenState();
}

class _ScannerEANScreenState extends State<ScannerEANScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(Constants.invTextDark)),
        title: const Text('Leitura de EAN',
            style: TextStyle(
                color: Color(Constants.invTextDark),
                fontWeight: FontWeight.w500,
                fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code_scanner,
                        size: 120, color: Color(Constants.invTextSecondary)),
                    const SizedBox(height: 16),
                    const Text(
                      'Câmera indisponível nesta versão',
                      style: TextStyle(
                          color: Color(Constants.invTextSecondary),
                          fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
                      decoration: const InputDecoration(
                        labelText: 'Digitar o código EAN',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(Constants.primaryRed),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () =>
                    Navigator.of(context).pop(_controller.text.trim()),
                child: const Text('Confirmar EAN',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
