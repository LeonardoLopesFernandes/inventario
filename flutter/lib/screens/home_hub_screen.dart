import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFavoritosKey = 'hubs_favoritos';

class _Hub {
  final String id;
  final String iconAsset;
  final IconData fallbackIcon;
  final String title;
  final String rota;

  const _Hub({
    required this.id,
    required this.iconAsset,
    required this.fallbackIcon,
    required this.title,
    required this.rota,
  });
}

const List<_Hub> _hubs = [
  _Hub(
    id: 'precificacao',
    iconAsset: 'assets/drawables/precificacao.png',
    fallbackIcon: Icons.request_quote_outlined,
    title: 'Precificação',
    rota: '/precificacao',
  ),
  _Hub(
    id: 'recebimento',
    iconAsset: 'assets/drawables/recebimento.png',
    fallbackIcon: Icons.local_shipping_outlined,
    title: 'Recebimento Centralizado',
    rota: '/recebimento',
  ),
  _Hub(
    id: 'inventario',
    iconAsset: 'assets/drawables/inventario.png',
    fallbackIcon: Icons.inventory_2_outlined,
    title: 'Inventário',
    rota: '/inventario',
  ),
  _Hub(
    id: 'quebra',
    iconAsset: 'assets/drawables/quebras.png',
    fallbackIcon: Icons.broken_image_outlined,
    title: 'Quebra',
    rota: '/quebras',
  ),
];

/// Home: cabeçalho vermelho + grade com 4 acessos.
class HomeHubScreen extends StatefulWidget {
  const HomeHubScreen({super.key});

  @override
  State<HomeHubScreen> createState() => _HomeHubScreenState();
}

class _HomeHubScreenState extends State<HomeHubScreen> {
  final Set<String> _favoritos = {};

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_kFavoritosKey) ?? [];
    if (!mounted) return;
    setState(() {
      _favoritos
        ..clear()
        ..addAll(favs);
    });
  }

  Future<void> _toggleFavorito(String id) async {
    setState(() {
      if (_favoritos.contains(id)) {
        _favoritos.remove(id);
      } else {
        _favoritos.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFavoritosKey, _favoritos.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset(
                      'assets/drawables/logo_mloja.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Minha Loja',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  for (final hub in _hubs)
                    _MenuCard(
                      iconAsset: hub.iconAsset,
                      fallbackIcon: hub.fallbackIcon,
                      title: hub.title,
                      favorito: _favoritos.contains(hub.id),
                      onFavoritar: () => _toggleFavorito(hub.id),
                      onTap: () => Navigator.of(context).pushNamed(hub.rota),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String iconAsset;
  final IconData fallbackIcon;
  final String title;
  final bool favorito;
  final VoidCallback onFavoritar;
  final VoidCallback onTap;

  const _MenuCard({
    required this.iconAsset,
    required this.fallbackIcon,
    required this.title,
    required this.favorito,
    required this.onFavoritar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  iconAsset,
                  width: 48,
                  height: 48,
                  errorBuilder: (_, __, ___) =>
                      Icon(fallbackIcon, color: const Color(0xFFD32F2F), size: 40),
                ),
                InkWell(
                  onTap: onFavoritar,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      favorito ? Icons.star : Icons.star_border,
                      color: favorito ? const Color(0xFFD32F2F) : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
