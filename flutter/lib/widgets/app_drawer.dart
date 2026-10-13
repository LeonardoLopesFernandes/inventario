import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Menu lateral do app (Inventário Rotativo / Quebra de itens).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120,
            color: const Color(Constants.primaryRed),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(16),
            child: const Text('Minha Loja',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined,
                color: Color(Constants.invTextDark)),
            title: const Text('Inventário rotativo'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.report_gmailerrorred_outlined,
                color: Color(Constants.invTextDark)),
            title: const Text('Quebra de itens'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/quebra');
            },
          ),
        ],
      ),
    );
  }
}
