import 'package:flutter/material.dart';
import 'package:inventario/network/session_manager.dart';
import 'package:inventario/precificacao/utils/toast_utils.dart';
import '../models/cupom.dart';
import '../network/troca_api.dart';
import '../network/troca_session.dart';

/// Etapa 2/2 da Troca Fácil: dados do cupom (loja, PDV, cupom, data, motivo).
class RealizarTrocaEtapa2Screen extends StatefulWidget {
  const RealizarTrocaEtapa2Screen({super.key});

  @override
  State<RealizarTrocaEtapa2Screen> createState() =>
      _RealizarTrocaEtapa2ScreenState();
}

class _RealizarTrocaEtapa2ScreenState
    extends State<RealizarTrocaEtapa2Screen> {
  final TrocaApi _api = TrocaApi();

  final _loja = TextEditingController();
  final _pdv = TextEditingController();
  final _cupom = TextEditingController();
  DateTime? _dataCompra;
  String _motivo = 'Insatisfação';

  bool _carregando = false;
  bool _argsLidos = false;
  Map<String, dynamic> _cliente = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLidos) return;
    _argsLidos = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) _cliente = Map<String, dynamic>.from(args);
    _initLoja();
  }

  Future<void> _initLoja() async {
    final session = await SessionManager.create();
    final loja = session.getUserStore().replaceFirst(RegExp('^L'), '');
    if (!mounted) return;
    setState(() => _loja.text = loja);
  }

  @override
  void initState() {
    super.initState();
    for (final c in [_loja, _pdv, _cupom]) {
      c.addListener(_onChange);
    }
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _loja.dispose();
    _pdv.dispose();
    _cupom.dispose();
    super.dispose();
  }

  bool get _preenchido =>
      _loja.text.trim().isNotEmpty &&
      _pdv.text.trim().isNotEmpty &&
      _cupom.text.trim().isNotEmpty &&
      _dataCompra != null;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _compact(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}'
      '${d.month.toString().padLeft(2, '0')}'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickData() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataCompra ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _dataCompra = picked);
  }

  Future<void> _continuar() async {
    if (!_preenchido || _carregando) return;
    setState(() => _carregando = true);
    try {
      final cupom = await _api.getCupom(
        storeId: _loja.text.trim(),
        pdv: _pdv.text.trim(),
        data: _compact(_dataCompra!),
        cupom: _cupom.text.trim(),
        cause: _motivo == 'Defeito' ? 'DEFEITO' : 'INSATISFACAO',
      );
      if (!mounted) return;
      if (cupom.products.isEmpty) {
        ToastUtils.showInfo(context, 'Cupom não encontrado');
        return;
      }
      _abrirItens(cupom);
    } on TrocaApiException catch (e) {
      if (e.statusCode == 401) {
        final t = await TrocaSession.create();
        t.clear();
        if (!mounted) return;
        ToastUtils.showError(context, 'Sessão expirada. Faça login novamente.');
        return;
      }
      if (!mounted) return;
      ToastUtils.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      ToastUtils.showError(context, 'Erro ao buscar cupom');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _abrirItens(Cupom cupom) {
    Navigator.of(context).pushNamed('/troca_itens', arguments: {
      'cupom': cupom,
      'cliente': _cliente,
      'motivo': _motivo == 'Defeito' ? 'DEFEITO' : 'INSATISFACAO',
      'motivoLabel': _motivo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Realizar troca',
          style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      value: 1.0,
                      backgroundColor: Color(0xFFE0E0E0),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('2/2',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text('Dados da compra',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 16),
                _campoTexto(controller: _loja, hintText: 'Número da loja'),
                const SizedBox(height: 12),
                _campoTexto(controller: _pdv, hintText: 'Número do PDV'),
                const SizedBox(height: 12),
                _campoTexto(controller: _cupom, hintText: 'Número do cupom'),
                const SizedBox(height: 12),
                _campoData(),
                const SizedBox(height: 12),
                _campoMotivo(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (_preenchido && !_carregando) ? _continuar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: _carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Continuar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _campoData() {
    return GestureDetector(
      onTap: _pickData,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  _dataCompra == null
                      ? 'Data da compra'
                      : _fmt(_dataCompra!),
                  style: TextStyle(
                      color: _dataCompra == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                      fontSize: 15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.calendar_today_outlined,
                  color: Colors.grey.shade600, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoMotivo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _motivo,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: Colors.grey.shade600, size: 22),
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          items: const ['Insatisfação', 'Defeito']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _motivo = v);
          },
        ),
      ),
    );
  }
}
