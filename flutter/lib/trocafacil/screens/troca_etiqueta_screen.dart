import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../network/troca_session.dart';

/// Abre/renderiza o anexo (PDF da etiqueta/vale troca) da Troca Fácil em
/// WebView: https://trocafacil.americanas.io/etiqueta
///
/// A página usa o token da sessão (localStorage). Como o WebView abre "limpo",
/// injetamos o token do login da Troca Fácil no localStorage do site e
/// recarregamos, para a etiqueta renderizar autenticada.
class TrocaEtiquetaScreen extends StatefulWidget {
  /// Token (opcional) para autenticar a página; quando nulo usa o salvo.
  final String? token;
  const TrocaEtiquetaScreen({super.key, this.token});

  @override
  State<TrocaEtiquetaScreen> createState() => _TrocaEtiquetaScreenState();
}

class _TrocaEtiquetaScreenState extends State<TrocaEtiquetaScreen> {
  static const String _etiquetaUrl =
      'https://trocafacil.americanas.io/etiqueta';

  late final WebViewController _controller;
  bool _pronto = false;
  bool _injetou = false;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final troca = await TrocaSession.create();
    _token = widget.token ?? troca.getToken() ?? '';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) => _injetarToken(url),
      ));
    await _controller.loadRequest(Uri.parse(_etiquetaUrl));
    if (!mounted) return;
    setState(() => _pronto = true);
  }

  Future<void> _injetarToken(String url) async {
    if (_injetou || _token.isEmpty) return;
    if (!url.contains('trocafacil.americanas.io')) return;
    _injetou = true;
    final t = _token.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
    final js = "try{"
        "localStorage.setItem('newToken','$t');"
        "localStorage.setItem('token','$t');"
        "sessionStorage.setItem('newToken','$t');"
        "sessionStorage.setItem('token','$t');"
        "}catch(e){}";
    try {
      await _controller.runJavaScript(js);
    } catch (_) {}
    await _controller.loadRequest(Uri.parse(_etiquetaUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Etiqueta',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: _pronto
          ? WebViewWidget(controller: _controller)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
