import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Home: cabeçalho vermelho + grade com 4 acessos.
class HomeHubScreen extends StatefulWidget {
  const HomeHubScreen({super.key});

  @override
  State<HomeHubScreen> createState() => _HomeHubScreenState();
}

class _HomeHubScreenState extends State<HomeHubScreen> {
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
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SvgPicture.asset(
                          'assets/drawables/logo_mloja.svg',
                          width: 32,
                          height: 32,
                        ),
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
                    _MenuCard(
                      iconAsset: 'assets/drawables/precificacao.png',
                      fallbackIcon: Icons.request_quote_outlined,
                      title: 'Precificação',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/precificacao'),
                    ),
                    _MenuCard(
                      iconAsset: 'assets/drawables/recebimento.png',
                      fallbackIcon: Icons.local_shipping_outlined,
                      title: 'Recebimento Centralizado',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/recebimento'),
                    ),
                    _MenuCard(
                      iconAsset: 'assets/drawables/inventario.png',
                      fallbackIcon: Icons.inventory_2_outlined,
                      title: 'Inventário',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/inventario'),
                    ),
                    _MenuCard(
                      iconAsset: 'assets/drawables/quebras.png',
                      fallbackIcon: Icons.broken_image_outlined,
                      title: 'Quebra',
                      onTap: () => Navigator.of(context).pushNamed('/quebras'),
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
  final VoidCallback onTap;

  const _MenuCard({
    required this.iconAsset,
    required this.fallbackIcon,
    required this.title,
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
                const Icon(Icons.star_border, color: Colors.grey, size: 22),
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
