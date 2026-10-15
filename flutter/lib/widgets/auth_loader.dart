import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:inventario/utils/app_version.dart';

/// Tela/widget de autenticação: anel girando (Lottie) ao redor do ícone,
/// título e rodapé com a versão do app.
class AuthLoader extends StatelessWidget {
  final String titulo;
  final String? subtitulo;

  /// Ícone exibido no centro do anel (padrão: loja.png).
  final String icone;

  /// Cor para pintar o ícone (ex.: branco, quando o ícone é transparente).
  final Color? iconeCor;

  const AuthLoader({
    super.key,
    this.titulo = 'Loja Mobile',
    this.subtitulo = 'Autenticando...',
    this.icone = 'assets/drawables/mobile.png',
    this.iconeCor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/loader_ring.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                  Image.asset(
                    icone,
                    width: 82,
                    height: 82,
                    color: iconeCor,
                    colorBlendMode: iconeCor == null ? null : BlendMode.srcIn,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitulo!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
            const SizedBox(height: 40),
            Text(
              'Versão $appVersion',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
