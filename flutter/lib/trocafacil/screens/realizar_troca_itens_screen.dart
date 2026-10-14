import 'package:flutter/material.dart';
import 'package:inventario/network/session_manager.dart';
import 'package:inventario/precificacao/utils/toast_utils.dart';
import '../models/cupom.dart';
import '../network/troca_api.dart';
import '../network/troca_session.dart';

/// Tela dos itens da troca: mostra o item selecionado do cupom e as perguntas
/// de avaliação (Sim/Não), com botões CANCELAR e CONTINUAR.
class RealizarTrocaItensScreen extends StatefulWidget {
  const RealizarTrocaItensScreen({super.key});

  @override
  State<RealizarTrocaItensScreen> createState() =>
      _RealizarTrocaItensScreenState();
}

class _RealizarTrocaItensScreenState extends State<RealizarTrocaItensScreen> {
  final TrocaApi _api = TrocaApi();

  late Cupom _cupom;
  Map<String, dynamic> _cliente = {};
  String _cause = 'INSATISFACAO';
  String _motivoLabel = 'Insatisfação';
  bool _argsLidos = false;

  int _idxSelecionado = 0;
  List<Map<String, dynamic>> _perguntas = [];
  bool _carregandoPerguntas = false;
  final Map<String, bool> _respostas = {};
  bool _enviando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLidos) return;
    _argsLidos = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _cupom = args['cupom'] as Cupom;
      _cliente = Map<String, dynamic>.from(args['cliente'] ?? {});
      _cause = args['motivo'] ?? 'INSATISFACAO';
      _motivoLabel = args['motivoLabel'] ?? 'Insatisfação';
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
    _carregarPerguntas();
  }

  CupomProduct get _produto => _cupom.products[_idxSelecionado];

  Future<void> _carregarPerguntas() async {
    if (_cupom.products.isEmpty) return;
    setState(() {
      _carregandoPerguntas = true;
      _perguntas = [];
      _respostas.clear();
    });
    try {
      final infos =
          '${_produto.departmentCode},${_produto.line};';
      final resp = await _api.getQuestions(
        cause: _cause,
        infosProduct: infos,
      );
      final lista = <Map<String, dynamic>>[];
      for (final bloco in resp) {
        final qs = bloco['questionsProduct'];
        if (qs is List) {
          for (final q in qs.whereType<Map>()) {
            lista.add(Map<String, dynamic>.from(q));
          }
        }
      }
      lista.sort((a, b) => ((a['question_order'] as num?)?.toInt() ?? 0)
          .compareTo((b['question_order'] as num?)?.toInt() ?? 0));
      if (!mounted) return;
      setState(() {
        _perguntas = lista;
        _carregandoPerguntas = false;
      });
    } on TrocaApiException catch (e) {
      if (!mounted) return;
      setState(() => _carregandoPerguntas = false);
      if (e.statusCode == 401) {
        final t = await TrocaSession.create();
        t.clear();
        if (!mounted) return;
        ToastUtils.showError(context, 'Sessão expirada. Faça login novamente.');
      } else {
        ToastUtils.showError(context, e.message);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregandoPerguntas = false);
      ToastUtils.showError(context, 'Erro ao carregar perguntas');
    }
  }

  bool get _todasRespondidas =>
      _perguntas.isNotEmpty &&
      _perguntas.every((q) => _respostas.containsKey(_id(q)));

  String _id(Map<String, dynamic> q) =>
      (q['id_avaliation_questions'] ?? '').toString();

  String _desc(Map<String, dynamic> q) =>
      (q['description_question'] ?? '').toString();

  String _brl(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final grouped = parts[0].replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'R\$ $grouped,${parts[1]}';
  }

  Future<void> _continuar() async {
    if (!_todasRespondidas || _enviando) return;
    setState(() => _enviando = true);
    try {
      final session = await SessionManager.create();
      final email = session.getUserEmail() ?? '';
      final createdBy = email.contains('@') ? email.split('@').first : email;
      final hoje = DateTime.now();
      final operationDate =
          '${hoje.year.toString().padLeft(4, '0')}-'
          '${hoje.month.toString().padLeft(2, '0')}-'
          '${hoje.day.toString().padLeft(2, '0')}';

      final produto = _produto;
      final body = {
        'products': [
          {
            'EAN': produto.ean,
            'SKU': produto.sku,
            'productDescription': produto.name.isNotEmpty
                ? produto.name
                : produto.description,
            'qtProduct': produto.totalSaleQuantity > 0
                ? produto.totalSaleQuantity
                : 1,
            'nsu': produto.nsu,
            'unitValue': produto.unitValue,
            'imei': produto.imeiCode,
            'avaliationResults': _perguntas
                .map((q) => {
                      'id_avaliation_questions': _id(q),
                      'client_answer': _respostas[_id(q)] ?? false,
                    })
                .toList(),
            'excededTime': produto.excededTime,
            'treatmentDesc': produto.treatmentDescription,
            'treatmentCode': produto.treatmentCode,
            'departamentCode': produto.departmentCode,
            'catalog': produto.catalog,
            'category': produto.category,
            'currentPrice': produto.currentPrice,
            'line': produto.line,
          }
        ],
        'costumerData': {
          'costumerDocument': _cliente['cpfCnpj'] ?? '',
          'costumerName': _cliente['nome'] ?? '',
          'costumerPhone': _cliente['telefone'] ?? '',
          'neighborhood': '',
          'uf': '',
          'address': _cliente['endereco'] ?? '',
          'city': '',
          'email': '',
        },
        'couponData': {
          'key_nfce': _cupom.keyNfce,
          'couponNumber': _cupom.couponNumber,
          'originStore': _cupom.couponStoreNumber,
          'originPDV': _cupom.couponPdvNumber,
          'transactionDate': _cupom.creationDate,
          'vl_total': _cupom.totalValue,
        },
        'createdBy': createdBy,
        'cause': _cause,
        'reason': 'Presente',
        'operationType': 'TROCA',
        'storeNumber': session.getUserStore(),
        'tipo': 'VENDA_FISICA',
        'tipoDoc': 'CUPOM_FISCAL',
        'systemSource': 'FISICO',
        'operationDate': operationDate,
      };

      final resultado = await _api.finishTrade(body);
      if (!mounted) return;
      _mostrarResultado(resultado);
    } on TrocaApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        final t = await TrocaSession.create();
        t.clear();
        ToastUtils.showError(context, 'Sessão expirada. Faça login novamente.');
      } else {
        ToastUtils.showError(context, e.message);
      }
    } catch (_) {
      if (!mounted) return;
      ToastUtils.showError(context, 'Erro ao finalizar troca');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarResultado(Map<String, dynamic> resultado) {
    final status = (resultado['operationStatus'] ?? '').toString();
    final prods = resultado['products'];
    final autorizado = prods is List && prods.isNotEmpty
        ? (prods.first['tradeProductAuthorization'] ?? '').toString()
        : '';
    final aprovado = autorizado.toUpperCase() == 'APROVADO' ||
        status.toLowerCase() == 'aceita';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(aprovado ? 'Troca aprovada' : 'Troca recusada'),
        content: Text(
          aprovado
              ? 'A troca foi registrada. Deseja imprimir a etiqueta?'
              : 'Operação: $status${autorizado.isNotEmpty ? ' ($autorizado)' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Fechar'),
          ),
          if (aprovado)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context)
                    .pushNamed('/troca_etiqueta', arguments: {
                  'token': null,
                });
              },
              child: const Text('Imprimir etiqueta'),
            ),
        ],
      ),
    );
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
        title: const Text('Realizar troca',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
      ),
      body: _cupom.products.isEmpty
          ? const Center(child: Text('Nenhum item no cupom'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_cupom.products.length > 1) ...[
                        const Text('Selecione o item',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0;
                                i < _cupom.products.length;
                                i++)
                              ChoiceChip(
                                label: Text(
                                  _cupom.products[i].name.isNotEmpty
                                      ? _cupom.products[i].name
                                      : _cupom.products[i].description,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                selected: _idxSelecionado == i,
                                selectedColor: const Color(0xFFD32F2F),
                                labelStyle: TextStyle(
                                    color: _idxSelecionado == i
                                        ? Colors.white
                                        : Colors.black87),
                                onSelected: (_) {
                                  setState(() => _idxSelecionado = i);
                                  _carregarPerguntas();
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      _cartaoItem(),
                      const SizedBox(height: 20),
                      const Text('Avaliação',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 12),
                      if (_carregandoPerguntas)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_perguntas.isEmpty)
                        const Text('Nenhuma pergunta para este item',
                            style: TextStyle(color: Colors.black54))
                      else
                        ..._perguntas.map(_perguntaWidget),
                    ],
                  ),
                ),
                _rodape(),
              ],
            ),
    );
  }

  Widget _cartaoItem() {
    final p = _produto;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.name.isNotEmpty ? p.name : p.description,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text('EAN: ${p.ean}   •   SKU: ${p.sku}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text('${p.category}   •   ${p.treatmentDescription}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(_brl(p.unitValue),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F))),
              const Spacer(),
              if (p.currentPrice.isNotEmpty)
                Text('Atual: R\$ ${p.currentPrice}',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
            ],
          ),
          if (p.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(p.message,
                style: const TextStyle(fontSize: 11, color: Colors.red)),
          ],
        ],
      ),
    );
  }

  Widget _perguntaWidget(Map<String, dynamic> q) {
    final id = _id(q);
    final resposta = _respostas[id];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_desc(q),
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 10),
          Row(
            children: [
              _botaoResposta('Sim', true, id, resposta == true),
              const SizedBox(width: 8),
              _botaoResposta('Não', false, id, resposta == false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botaoResposta(String texto, bool valor, String id, bool selecionado) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _respostas[id] = valor),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selecionado ? const Color(0xFFD32F2F) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selecionado
                    ? const Color(0xFFD32F2F)
                    : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            texto,
            style: TextStyle(
                color: selecionado ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _rodape() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _enviando
                  ? null
                  : () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFD32F2F)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('CANCELAR',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  (_todasRespondidas && !_enviando) ? _continuar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('CONTINUAR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
