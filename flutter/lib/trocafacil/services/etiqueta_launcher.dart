import 'package:url_launcher/url_launcher.dart';

const String trocaEtiquetaUrl = 'https://trocafacil.americanas.io/etiqueta';

/// Abre a etiqueta/vale troca no navegador externo (Chrome), onde a página
/// renderiza a etiqueta e permite imprimir.
Future<bool> abrirEtiquetaTroca() async {
  final uri = Uri.parse(trocaEtiquetaUrl);
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
