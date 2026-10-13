import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Submenu da Quebra: Cadastrar/processar e Consultar.
class QuebrasMenuScreen extends StatelessWidget {
  const QuebrasMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(Constants.invTextDark)),
        title: const Text('Quebras',
            style: TextStyle(
                color: Color(Constants.invTextDark),
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _item(
            context,
            'Cadastrar e processar quebras',
            () => Navigator.of(context).pushNamed('/quebra'),
          ),
          const SizedBox(height: 16),
          _item(
            context,
            'Consultar quebras',
            () => Navigator.of(context).pushNamed('/quebra_consulta'),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String titulo, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titulo,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(Constants.invTextDark))),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
