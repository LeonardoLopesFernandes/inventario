import 'package:flutter/material.dart';

/// Filtro da lista de operações (Troca Fácil).
class FiltrarOperacoesScreen extends StatefulWidget {
  const FiltrarOperacoesScreen({super.key});

  @override
  State<FiltrarOperacoesScreen> createState() =>
      _FiltrarOperacoesScreenState();
}

class _FiltrarOperacoesScreenState extends State<FiltrarOperacoesScreen> {
  final _numero = TextEditingController();
  final _etiqueta = TextEditingController();
  final _cliente = TextEditingController();
  String? _dataAvaliacao;
  String? _dataCompra;
  String? _operacao;
  String? _motivo;
  String _ordenarData = 'Data Avaliação';
  String _ordenarOrdem = 'Decrescente';

  @override
  void dispose() {
    _numero.dispose();
    _etiqueta.dispose();
    _cliente.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate(bool avaliacao) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() {
      if (avaliacao) {
        _dataAvaliacao = _fmt(picked);
      } else {
        _dataCompra = _fmt(picked);
      }
    });
  }

  void _limpar() {
    setState(() {
      _numero.clear();
      _etiqueta.clear();
      _cliente.clear();
      _dataAvaliacao = null;
      _dataCompra = null;
      _operacao = null;
      _motivo = null;
      _ordenarData = 'Data Avaliação';
      _ordenarOrdem = 'Decrescente';
    });
  }

  void _aplicar() {
    Navigator.of(context).pop({
      'numero': _numero.text.trim(),
      'etiqueta': _etiqueta.text.trim(),
      'dataAvaliacao': _dataAvaliacao,
      'operacao': _operacao,
      'motivo': _motivo,
      'dataCompra': _dataCompra,
      'cliente': _cliente.text.trim(),
      'ordenarData': _ordenarData,
      'ordenarOrdem': _ordenarOrdem,
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
        title: const Text(
          'Filtrar Operações',
          style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _campoTexto(controller: _numero, hintText: 'Nº de operação'),
          const SizedBox(height: 12),
          _campoTexto(controller: _etiqueta, hintText: 'Nº da etiqueta'),
          const SizedBox(height: 12),
          _campoData(
            valor: _dataAvaliacao,
            hintText: 'Data Avaliação',
            onTap: () => _pickDate(true),
          ),
          const SizedBox(height: 12),
          _campoDropdown(
            valor: _operacao,
            hintText: 'Operação',
            itens: const ['Troca', 'Devolução'],
            onChanged: (v) => setState(() => _operacao = v),
          ),
          const SizedBox(height: 12),
          _campoDropdown(
            valor: _motivo,
            hintText: 'Motivo',
            itens: const ['Insatisfação', 'Defeito'],
            onChanged: (v) => setState(() => _motivo = v),
          ),
          const SizedBox(height: 12),
          _campoData(
            valor: _dataCompra,
            hintText: 'Data Compra',
            onTap: () => _pickDate(false),
          ),
          const SizedBox(height: 12),
          _campoTexto(controller: _cliente, hintText: 'Cliente'),
          const SizedBox(height: 20),
          const Text('Ordenar por:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          _outlinedDropdown(
            label: 'Data',
            value: _ordenarData,
            itens: const ['Data Avaliação', 'Data Compra'],
            onChanged: (v) => setState(() => _ordenarData = v!),
          ),
          const SizedBox(height: 12),
          _outlinedDropdown(
            label: 'Ordem',
            value: _ordenarOrdem,
            itens: const ['Decrescente', 'Crescente'],
            onChanged: (v) => setState(() => _ordenarOrdem = v!),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _aplicar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text('Aplicar Filtros',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _limpar,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                foregroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Limpar Filtros',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),
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

  Widget _campoData({
    required String? valor,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                  valor ?? hintText,
                  style: TextStyle(
                      color: valor == null
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

  Widget _campoDropdown({
    required String? valor,
    required String hintText,
    required List<String> itens,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valor,
          isExpanded: true,
          hint: Text(hintText,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          icon: Icon(Icons.keyboard_arrow_down,
              color: Colors.grey.shade600, size: 22),
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          items: itens
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _outlinedDropdown({
    required String label,
    required String value,
    required List<String> itens,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600, size: 22),
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              items: itens
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
