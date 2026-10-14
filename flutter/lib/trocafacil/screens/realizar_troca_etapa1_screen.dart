import 'package:flutter/material.dart';

/// Etapa 1/2 da Troca Fácil: identificação do cliente e endereço.
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
  final _endereco = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final c in [_cpfCnpj, _nome, _telefone, _cep, _endereco]) {
      c.addListener(_onChange);
    }
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _cpfCnpj.dispose();
    _nome.dispose();
    _telefone.dispose();
    _cep.dispose();
    _endereco.dispose();
    super.dispose();
  }

  bool get _preenchido =>
      _cpfCnpj.text.trim().isNotEmpty &&
      _nome.text.trim().isNotEmpty &&
      _telefone.text.trim().isNotEmpty &&
      _cep.text.trim().isNotEmpty &&
      _endereco.text.trim().isNotEmpty;

  void _continuar() {
    Navigator.of(context).pushNamed('/troca_etapa2', arguments: {
      'cpfCnpj': _cpfCnpj.text.trim(),
      'nome': _nome.text.trim(),
      'telefone': _telefone.text.trim(),
      'cep': _cep.text.trim(),
      'endereco': _endereco.text.trim(),
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
                _buildTextField(controller: _cpfCnpj, hintText: 'CPF/CNPJ'),
                const SizedBox(height: 12),
                _buildTextField(controller: _nome, hintText: 'Nome'),
                const SizedBox(height: 12),
                _buildTextField(
                    controller: _telefone, hintText: 'Telefone'),
                const SizedBox(height: 24),
                const Text('Endereço',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 16),
                _buildTextField(controller: _cep, hintText: 'CEP'),
                const SizedBox(height: 12),
                _buildTextField(
                    controller: _endereco, hintText: 'Endereço'),
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

  Widget _buildTextField({
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
}
