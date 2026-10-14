import 'package:flutter/material.dart';

/// Tela/widget de autenticação: ícone com efeito de pulso + brilho dinâmico.
class AuthLoader extends StatefulWidget {
  final String titulo;
  final String? subtitulo;

  const AuthLoader({
    super.key,
    this.titulo = 'Loja Mobile',
    this.subtitulo = 'Autenticando...',
  });

  @override
  State<AuthLoader> createState() => _AuthLoaderState();
}

class _AuthLoaderState extends State<AuthLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 6.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: _scale.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.35),
                        blurRadius: _glow.value,
                        spreadRadius: _glow.value / 3,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
              child: Image.asset(
                'assets/drawables/loja.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              widget.titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            if (widget.subtitulo != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitulo!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
            const SizedBox(height: 48),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
