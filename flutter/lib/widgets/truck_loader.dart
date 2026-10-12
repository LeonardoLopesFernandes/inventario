import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícone do Inventário girando suavemente (combina com "Inventário Rotativo"),
/// com um leve pulso de escala, e o texto fixo.
class TruckLoader extends StatefulWidget {
  final String? status;
  const TruckLoader({super.key, this.status});

  @override
  State<TruckLoader> createState() => _TruckLoaderState();
}

class _TruckLoaderState extends State<TruckLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        final angle = t * 2 * math.pi;
        final escala = 0.9 + 0.1 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: angle,
              child: Transform.scale(
                scale: escala,
                child: SvgPicture.asset(
                  'assets/drawables/ic_inventario_branco.svg',
                  width: 84,
                  height: 84,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Inventário Rotativo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            if (widget.status != null) ...[
              const SizedBox(height: 10),
              Text(
                widget.status!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        );
      },
    );
  }
}
