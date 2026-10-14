import 'package:flutter/material.dart';
import 'package:inventario/precificacao/utils/toast_utils.dart';
import '../models/cupom.dart';
import '../network/troca_api.dart';

/// Produto selecionado para troca (item do cupom + quantidade desejada).
class ProdutoSelecionado {
  final CupomProduct produto;
  final int quantidade;
  ProdutoSelecionado(this.produto, this.quantidade);
}

/// Tela 1 — Seleção de produtos do cupom ("Detalhes do cupom").
class RealizarTrocaItensScreen extends StatefulWidget {
  const RealizarTrocaItensScreen({super.key});

  @override
  State<RealizarTrocaItensScreen> createState() =>
      _RealizarTrocaItensScreenState();
}

class _RealizarTrocaItensScreenState extends State<RealizarTrocaItensScreen> {
  late Cupom _cupom;
  Map<String, dynamic> _cliente = {};
  String _cause = 'INSATISFACAO';
  String _reason = '';
  String _operationType = 'TROCA';
  bool _argsLidos = false;

  final List<TextEditingController> _qtds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLidos) return;
    _argsLidos = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _cupom = args['cupom'] as Cupom;
      _cliente = Map<String, dynamic>.from(args['cliente'] ?? {});
      _cause = args['cause'] ?? 'INSATISFACAO';
      _reason = args['reason'] ?? '';
      _operationType = args['operationType'] ?? 'TROCA';
    } else {
      _cupom = Cupom(
        creationDate: '',
        couponPdvNumber: '',
        couponStoreNumber: '',
        couponNumber: '',
        keyNfce: '',
        totalValue: 0,
        products: const [],
      );
    }
    for (final _ in _cupom.products) {
      _qtds.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _qtds) {
      c.dispose();
    }
    super.dispose();
  }

  List<ProdutoSelecionado> get _selecionados {
    final lista = <ProdutoSelecionado>[];
    for (var i = 0; i < _cupom.products.length; i++) {
      final txt = _qtds[i].text.trim();
      final q = int.tryParse(txt) ?? 0;
      if (q > 0) lista.add(ProdutoSelecionado(_cupom.products[i], q));
    }
    return lista;
  }

  String _brl(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final grouped = parts[0].replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'R\$ $grouped,${parts[1]}';
  }

  void _continuar() {
    final selecionados = _selecionados;
    if (selecionados.isEmpty) {
      ToastUtils.show(context, 'Selecione ao menos um produto');
      return;
    }
    Navigator.of(context).pushNamed('/troca_avaliacao', arguments: {
      'cupom': _cupom,
      'selecionados': selecionados,
      'cliente': _cliente,
      'cause': _cause,
      'reason': _reason,
      'operationType': _operationType,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Detalhes do cupom',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 24,
              runSpacing: 4,
              children: [
                _infoCupom('Loja de origem do cupom',
                    _cupom.couponStoreNumber),
                _infoCupom('Data da compra',
                    TrocaApi.fmtIsoDate(_cupom.creationDate)),
                _infoCupom('PDV', _cupom.couponPdvNumber),
                _infoCupom('Cupom', _cupom.couponNumber),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecione o produto que o cliente deseja trocar :',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            child: _cupom.products.isEmpty
                ? const Center(
                    child: Text('Nenhum produto no cupom',
                        style: TextStyle(color: Colors.black54)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _cupom.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _cardProduto(_cupom.products[i], i),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('‹ Voltar',
                      style: TextStyle(color: Colors.black87)),
                ),
                ElevatedButton(
                  onPressed: _continuar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Continuar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCupom(String label, String value) {
    return Text('$label: $value',
        style: const TextStyle(fontSize: 12, color: Colors.black54));
  }

  Widget _cardProduto(CupomProduct p, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ã',
                  style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p.name.isNotEmpty ? p.name : p.description,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _colInfo('EAN', p.ean),
              _colInfo('Valor', _brl(p.unitValue)),
              _colInfo('Qtd cupom:', '${p.totalSaleQuantity}'),
              _colInfo('Qtd disponível:', '${p.totalQuantityAvailable}'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Qtd desejada:',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 54,
                    height: 36,
                    child: TextField(
                      controller: _qtds[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ],
    );
  }
}
