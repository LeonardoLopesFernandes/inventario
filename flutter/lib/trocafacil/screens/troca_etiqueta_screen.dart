import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../network/troca_session.dart';

/// Abre/ renderiza o anexo (PDF da etiqueta/vale troca) da Troca Fácil
/// em WebView: https://trocafacil.americanas.io/etiqueta
class TrocaEtiquetaScreen extends StatefulWidget {
  /// Token (opcional) para autenticar a página; quando nulo usa o salvo.
  final String? token;
  const TrocaEtiquetaScreen({super.key, this.token});

  @override
  State<TrocaEtiquetaScreen> createState() => _TrocaEtiquetaScreenState();
}

class _TrocaEtiquetaScreenState extends State<TrocaEtiquetaScreen> {
  late final WebViewController _controller;
  bool _pronto = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final troca = await TrocaSession.create();
    final token = widget.token ?? troca.getToken() ?? '';
    final base = Uri.parse('https://trocafacil.americanas.io/etiqueta');
    final uri = token.isEmpty
        ? base
        : base.replace(queryParameters: {'token': token});

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate());
    await _controller.loadRequest(uri);
    if (!mounted) return;
    setState(() => _pronto = true);
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
