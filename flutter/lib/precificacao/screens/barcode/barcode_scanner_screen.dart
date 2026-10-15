import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventario/precificacao/core/constants.dart';
import 'package:inventario/precificacao/core/lista_store.dart';
import 'package:inventario/precificacao/core/session_manager.dart';
import 'package:inventario/precificacao/core/theme.dart';
import 'package:inventario/precificacao/network/api_client.dart';
import 'package:inventario/precificacao/network/api_service.dart';
import 'package:inventario/precificacao/utils/beep.dart';
import 'package:inventario/precificacao/utils/log_helper.dart';
import 'package:inventario/precificacao/utils/price_tag_mapper.dart';
import 'package:inventario/precificacao/utils/session_expired_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  /// Modo contínuo (etiquetas): fica na câmera adicionando itens à lista.
  final bool continuo;

  const BarcodeScannerScreen({super.key, this.continuo = false});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late final MobileScannerController _controller;
  bool _popped = false;
  double _scaleStart = 1.0;
  double _currentZoom = 1.0;

  // ---- Modo contínuo ----
  static const int _debounceMs = 3000;
  ApiService? _api;
  String _storeId = Constants.defaultStore;
  String _today = '';
  bool _processing = false;
  String _lastCode = '';
  int _lastCodeTime = 0;
  int _lidas = 0;
  String _toastMsg = '';
  bool _toastErro = false;
  bool _mostrarToast = false;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    if (widget.continuo) {
      _api = ApiService(ApiClient.instance.getSlApiService());
      _storeId = SessionManager.instance?.getUserStore() ?? Constants.defaultStore;
      final d = DateTime.now();
      _today =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
  }

  void _onDetect(BarcodeCapture capture) {
    String? raw;
    for (final barcode in capture.barcodes) {
      final v = barcode.rawValue;
      if (v != null && v.isNotEmpty) {
        raw = v;
        break;
      }
    }
    if (raw == null) return;
    final codigo = _normalizar(raw);

    if (!widget.continuo) {
      if (_popped) return;
      _popped = true;
      Navigator.pop(context, codigo);
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    // Debounce: ignora o mesmo código por 3s e não processa em paralelo.
    if (_processing) return;
    if (codigo == _lastCode && now - _lastCodeTime < _debounceMs) return;
    _lastCode = codigo;
    _lastCodeTime = now;
    _processar(codigo);
  }

  /// Códigos que iniciam com "0" (ex.: EAN-13 de UPC-A) — ignora o(s) zero(s)
  /// inicial(is) e lê a partir do primeiro dígito diferente de zero.
  String _normalizar(String raw) {
    if (!raw.startsWith('0')) return raw;
    final semZeros = raw.replaceFirst(RegExp(r'^0+'), '');
    return semZeros.isEmpty ? raw : semZeros;
  }

  void _exibirToast(String msg, {bool erro = false}) {
    _toastTimer?.cancel();
    setState(() {
      _toastMsg = msg;
      _toastErro = erro;
      _mostrarToast = true;
    });
    _toastTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _mostrarToast = false);
    });
  }

  Future<void> _processar(String ean) async {
    final api = _api;
    if (api == null) return;
    setState(() => _processing = true);
    try {
      final resp = await api.getSingleLabelByEan(
        _storeId,
        ean: ean,
        startDate: _today,
      );
      if (!mounted) return;
      if (resp.items.isEmpty) {
        Beep.error();
        _exibirToast('Código não encontrado: $ean', erro: true);
        return;
      }
      final lista = await ListaStore.instance.getEtiquetas();
      for (final item in resp.items) {
        final idx = lista.indexWhere((t) => t.ean == item.ean);
        if (idx >= 0) {
          lista[idx].quantity += 1;
        } else {
          lista.add(singleToPriceTag(item));
        }
      }
      await ListaStore.instance.saveEtiquetas(lista);
      await ListaStore.instance.setColagem(ean);
      if (!mounted) return;
      _lidas++;
      Beep.success();
      _exibirToast('$_lidas ${_lidas == 1 ? 'etiqueta lida' : 'etiquetas lidas'}');
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        Beep.error();
        SessionExpiredHandler.handleSessionExpired(context);
        return;
      }
      Beep.error();
      _exibirToast('Erro de leitura: $ean', erro: true);
    } catch (e) {
      LogHelper.e('BarcodeScanner: erro na leitura contínua', e);
      Beep.error();
      _exibirToast('Erro de leitura: $ean', erro: true);
    } finally {
      _processing = false;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _scaleStart = _currentZoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final newZoom = (_scaleStart * details.scale).clamp(1.0, 8.0);
    if (newZoom != _currentZoom) {
      _currentZoom = newZoom;
      _controller.setZoomScale((_currentZoom - 1) / 7);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) Navigator.pop(context);
                });
                return const Center(
                  child: Text(
                    'Não foi possível acessar a câmera',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                child: Text(
                  widget.continuo
                      ? 'Escaneie os itens — volte para concluir'
                      : 'Aproxime a câmera do código (use a pinça para zoom)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (_currentZoom > 1.0)
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentZoom.toStringAsFixed(1)}x',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            if (widget.continuo)
              Positioned(
                bottom: 56,
                left: 16,
                right: 16,
                child: IgnorePointer(
                  ignoring: true,
                  child: AnimatedOpacity(
                    opacity: _mostrarToast ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _toastErro
                              ? const Color(0xFFD32F2F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _toastMsg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _toastErro
                                ? Colors.white
                                : const Color(0xFFD7193F),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
