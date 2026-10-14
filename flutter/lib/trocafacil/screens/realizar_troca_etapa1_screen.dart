import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Etapa 1/2 da Troca Fácil: identificação do cliente e endereço.
/// Ao digitar o CEP (8 dígitos), busca o endereço no ViaCEP e preenche
/// rua/bairro/cidade/UF automaticamente.
class RealizarTrocaEtapa1Screen extends StatefulWidget {
  const RealizarTrocaEtapa1Screen({super.key});

  @override
  State<RealizarTrocaEtapa1Screen> createState() =>
      _RealizarTrocaEtapa1ScreenState();
}

class _RealizarTrocaEtapa1ScreenState
    extends State<RealizarTrocaEtapa1Screen> {
  final _cpfCnpj = TextEditingController();
  final _nome = TextEditingController();
  final _telefone = TextEditingController();

  final _cep = TextEditingController();
  final _rua = TextEditingController();
  final _bairro = TextEditingController();
  final _numero = TextEditingController();
  final _complemento = TextEditingController();

  String _cidade = '';
  String _uf = '';
  bool _buscandoCep = false;
  String? _erroCep;

  final List<TextEditingController> _all = [];

  @override
  void initState() {
    super.initState();
    _all.addAll([_cpfCnpj, _nome, _telefone, _rua, _bairro, _numero, _complemento]);
    for (final c in _all) {
      c.addListener(_onChange);
    }
    _cep.addListener(_onCepChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    _cep.dispose();
    super.dispose();
  }

  String get _cepDigits => _cep.text.replaceAll(RegExp(r'\D'), '');

  void _onCepChange() {
    setState(() {});
    if (_cepDigits.length == 8) _buscarCep(_cepDigits);
  }

  Future<void> _buscarCep(String cep) async {
    setState(() {
      _buscandoCep = true;
      _erroCep = null;
    });
    try {
      final resp = await http
          .get(Uri.parse('https://viacep.com.br/ws/$cep/json/'))
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body) as Map<String, dynamic>;
        if (j['erro'] == true) {
          setState(() => _erroCep = 'CEP não encontrado');
        } else {
          setState(() {
            _rua.text = (j['logradouro'] ?? '').toString();
            _bairro.text = (j['bairro'] ?? '').toString();
            _cidade = (j['localidade'] ?? '').toString();
            _uf = (j['uf'] ?? '').toString();
          });
        }
      } else {
        setState(() => _erroCep = 'Falha ao buscar CEP');
      }
    } catch (_) {
      if (mounted) setState(() => _erroCep = 'Falha ao buscar CEP');
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  bool get _preenchido =>
      _cpfCnpj.text.trim().isNotEmpty &&
      _nome.text.trim().isNotEmpty &&
      _telefone.text.trim().isNotEmpty &&
      _cepDigits.length == 8 &&
      _rua.text.trim().isNotEmpty &&
      _numero.text.trim().isNotEmpty;

  void _continuar() {
    Navigator.of(context).pushNamed('/troca_etapa2', arguments: {
      'cpfCnpj': _cpfCnpj.text.trim(),
      'nome': _nome.text.trim(),
      'telefone': _telefone.text.trim(),
      'cep': _cepDigits,
      'rua': _rua.text.trim(),
      'bairro': _bairro.text.trim(),
      'numero': _numero.text.trim(),
      'complemento': _complemento.text.trim(),
      'cidade': _cidade,
      'uf': _uf,
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
                      value: 0.5,
                      backgroundColor: Color(0xFFE0E0E0),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('1/2',
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
                const Text('Identificação do cliente',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 16),
                _campo(_cpfCnpj, 'CPF/CNPJ',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _campo(_nome, 'Nome'),
                const SizedBox(height: 12),
                _campo(_telefone, 'Telefone',
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 24),
                const Text('Endereço',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 16),
                _campoCep(),
                if (_buscandoCep)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Buscando endereço...',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                if (_erroCep != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_erroCep!,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFFD32F2F))),
                  ),
                const SizedBox(height: 12),
                _campo(_rua, 'Nome da rua'),
                const SizedBox(height: 12),
                _campo(_bairro, 'Bairro'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _campo(_numero, 'Número',
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _campo(_complemento, 'Complemento'),
                    ),
                  ],
                ),
                if (_cidade.isNotEmpty || _uf.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('$_cidade${_uf.isNotEmpty ? ' - $_uf' : ''}',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _preenchido ? _continuar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Continuar',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String hintText, {
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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

  Widget _campoCep() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _cep,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
        ],
        decoration: InputDecoration(
          hintText: 'CEP',
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: _buscandoCep
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : null,
        ),
      ),
    );
  }
}
