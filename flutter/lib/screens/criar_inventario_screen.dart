import 'package:flutter/material.dart';
import '../models/inventario.dart';
import '../network/inventario_service.dart';
import '../network/session_manager.dart';
import '../utils/constants.dart';
import 'scanner_ean_screen.dart';

class CriarInventarioScreen extends StatefulWidget {
  final String? inventoryId;

  const CriarInventarioScreen({super.key, this.inventoryId});

  @override
  State<CriarInventarioScreen> createState() => _CriarInventarioScreenState();
}

class _CriarInventarioScreenState extends State<CriarInventarioScreen> {
  final TextEditingController _eanController = TextEditingController();
  final TextEditingController _qtdController = TextEditingController(text: '0');
  SessionManager? _session;
  InventarioService? _service;

  bool _buscando = false;
  String? _erro;
  Product? _produto;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = await SessionManager.create();
    if (!mounted) return;
    setState(() {
      _session = session;
      _service = InventarioService.forSession(session);
    });
  }

  String get _storeId => _session?.getUserStore() ?? Constants.defaultStore;

  Future<void> _buscar() async {
    final ean = _eanController.text.trim();
    if (ean.isEmpty) return;
    final service = _service;
    if (service == null) return;
    setState(() {
      _buscando = true;
      _erro = null;
      _produto = null;
    });
    try {
      final p = await service.getProductByEan(storeId: _storeId, ean: ean);
      if (!mounted) return;
      setState(() {
        _produto = p;
        _buscando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Produto não encontrado para o EAN $ean';
        _buscando = false;
      });
    }
  }

  Future<void> _escanear() async {
    final ean = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerEANScreen()),
    );
    if (ean != null && ean.isNotEmpty) {
      _eanController.text = ean;
      _buscar();
    }
  }

  @override
  void dispose() {
    _eanController.dispose();
    _qtdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(Constants.invTextDark)),
        title: const Text('Criar inventário',
            style: TextStyle(
                color: Color(Constants.invTextDark),
                fontWeight: FontWeight.w500,
                fontSize: 20)),
        actions: [
          if (widget.inventoryId != null)
            IconButton(
              icon: const Icon(Icons.check_circle_outline,
                  color: Color(Constants.primaryRed)),
              tooltip: 'Finalizar inventário',
              onPressed: _finalizar,
            ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
                color: Color(Constants.primaryRed), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('OG',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(Constants.bgGray),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: Color(Constants.invTextDark), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _eanController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _buscar(),
                            decoration: const InputDecoration(
                              hintText: 'EAN',
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(Constants.primaryRed),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.qr_code_scanner,
                        color: Colors.white, size: 24),
                    onPressed: _escanear,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_buscando)
              const Center(child: CircularProgressIndicator())
            else if (_erro != null)
              Center(
                child: Text(_erro!,
                    style:
                        const TextStyle(color: Color(Constants.invTextDark))),
              )
            else if (_produto != null)
              _produtoCard(_produto!)
            else ...[
              const Spacer(),
              const Center(child: Text('😉', style: TextStyle(fontSize: 60))),
              const SizedBox(height: 16),
              const Text(
                'Adicione itens ao inventário rotativo',
                style: TextStyle(
                    color: Color(Constants.invTextDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Utilize o EAN para adicionar itens e quantidades.',
                style: TextStyle(
                    color: Color(Constants.invTextSecondary), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
            ],
          ],
        ),
      ),
    );
  }

  Widget _produtoCard(Product p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(Constants.borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.description,
              style: const TextStyle(
                  color: Color(Constants.invTextDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 6),
          Text('EAN ${p.ean}   •   SAP ${p.sapCode}',
              style: const TextStyle(
                  color: Color(Constants.invTextSecondary), fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              _col('Estoque', p.stock.toStringAsFixed(0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quantidade contada',
                        style: TextStyle(
                            color: Color(Constants.invTextSecondary),
                            fontSize: 12)),
                    const SizedBox(height: 2),
                    TextField(
                      controller: _qtdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(Constants.primaryRed),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _adicionar,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar item',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizar() async {
    final id = widget.inventoryId;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Finalizar inventário'),
        content: const Text(
            'Deseja finalizar o inventário? Depois de finalizado não será possível adicionar itens.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Não')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sim')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service!.processInventory(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Inventário finalizado'),
          backgroundColor: Color(Constants.badgeGreen)));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao finalizar inventário'),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _adicionar() async {
    final p = _produto;
    if (p == null) return;
    final id = widget.inventoryId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Crie um inventário antes de adicionar itens.')));
      return;
    }
    final qtd = int.tryParse(_qtdController.text.trim()) ?? 0;
    try {
      await _service!.addItem(
        id,
        ean: p.ean,
        sapCode: p.sapCode,
        description: p.description,
        countedQuantity: qtd,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item adicionado: ${p.description}'),
          backgroundColor: const Color(Constants.badgeGreen)));
      _eanController.clear();
      _qtdController.text = '0';
      setState(() => _produto = null);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao adicionar item'),
          backgroundColor: Colors.red));
    }
  }

  Widget _col(String label, String valor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(Constants.invTextSecondary), fontSize: 12)),
          const SizedBox(height: 2),
          Text(valor,
              style: const TextStyle(
                  color: Color(Constants.invTextDark),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
