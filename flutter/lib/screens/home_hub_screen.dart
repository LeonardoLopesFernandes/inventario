import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Home: dois cards de acesso (Quebras e Inventário Rotativo).
class HomeHubScreen extends StatefulWidget {
  const HomeHubScreen({super.key});

  @override
  State<HomeHubScreen> createState() => _HomeHubScreenState();
}

class _HomeHubScreenState extends State<HomeHubScreen> {
  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Sair do aplicativo'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Não')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sim')),
        ],
      ),
    );
    if (sair == true && mounted) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('Minha Loja | Operações',
              style: TextStyle(
                  color: Color(Constants.invTextDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _card(
                    icon: 'assets/drawables/quebra.png',
                    title: 'Quebras',
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/quebra'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _card(
                    icon: 'assets/drawables/ir.png',
                    title: 'Inventário\nRotativo',
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/inventario'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({
    required String icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 72,
              child: Center(
                child: Image.asset(icon,
                    width: 64, height: 64, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(Constants.primaryRed),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onPressed,
                child: const Text('ACESSAR',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
