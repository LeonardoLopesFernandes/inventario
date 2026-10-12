import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícone do Inventário atravessa a tela em loop (sai pela direita,
/// reaparece pela esquerda e volta ao centro); ao chegar no centro o
/// texto "Inventário Rotativo" aparece.
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
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _dx(double t) {
    if (t < 0.35) return 0.8 * (t / 0.35);
    if (t < 0.45) return -0.8;
    if (t < 0.8) return -0.8 + 0.8 * ((t - 0.45) / 0.35);
    return 0.0;
  }

  double _textOpacity(double t) {
    if (t < 0.72) return 0.0;
    if (t > 0.84) return 1.0;
    return (t - 0.72) / 0.12;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        final w = MediaQuery.of(context).size.width;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(_dx(t) * w, 0),
              child: SvgPicture.asset(
                'assets/drawables/ic_inventario_branco.svg',
                width: 84,
                height: 84,
              ),
            ),
            Opacity(
              opacity: _textOpacity(t),
              child: const Text(
                'Inventário Rotativo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
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
