import 'package:flutter/material.dart';
import '../models/inventario.dart';
import '../models/quebra.dart';
import '../network/inventario_service.dart';
import '../network/session_manager.dart';
import '../utils/constants.dart';
import '../widgets/dialog_adicionar_quebra.dart';
import 'scanner_ean_screen.dart';

class QuebraDetalheScreen extends StatefulWidget {
  final String breakageId;

  const QuebraDetalheScreen({super.key, required this.breakageId});

  @override
  State<QuebraDetalheScreen> createState() => _QuebraDetalheScreenState();
}

class _QuebraDetalheScreenState extends State<QuebraDetalheScreen> {
  final TextEditingController _buscaController = TextEditingController();
  SessionManager? _session;
  InventarioService? _service;
  List<BreakageReason> _reasons = const [];
  List<BreakageItem> _itens = [];
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = await SessionManager.create();
    final service = InventarioService.forSession(session);
    List<BreakageReason> reasons = const [];
    try {
      reasons = await service.getBreakageReasons();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _session = session;
      _service = service;
      _reasons = reasons;
    });
  }

  String get _storeId => _session?.getUserStore() ?? Constants.defaultStore;

  Future<void> _buscar() async {
    final valor = _buscaController.text.trim();
    if (valor.isEmpty) return;
    setState(() => _buscando = true);
    Product produto;
    try {
      produto = await _service!.getProductStore(storeId: _storeId, ean: valor);
    } catch (_) {
      if (!mounted) return;
      setState(() => _buscando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Item não encontrado'), backgroundColor: Colors.red));
      return;
    }
    if (!mounted) return;
    setState(() => _buscando = false);
    final res = await mostrarDialogAdicionarQuebra(context,
        produto: produto, motivos: _reasons);
    if (res == null ||
        res.action == QuebraDialogAction.cancelar ||
        res.motivo == null) {
      return;
    }
    try {
      final itens = await _service!.addBreakageItem(
        widget.breakageId,
        ean: produto.ean,
        sapCode: produto.sapCode,
        description: produto.description,
        stock: produto.stock.toInt(),
        quantity: res.quantidade,
        reasonId: res.motivo!.id,
      );
      if (!mounted) return;
      setState(() => _itens = itens);
      _buscaController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Item adicionado à quebra'),
          backgroundColor: Color(Constants.badgeGreen)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao adicionar item'), backgroundColor: Colors.red));
    }
  }

  Future<void> _escanear() async {
    final ean = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerEANScreen()),
    );
    if (ean != null && ean.isNotEmpty) {
      _buscaController.text = ean;
      _buscar();
    }
  }

  @override
  void dispose() {
    _buscaController.dispose();
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(Constants.invTextDark)),
        title: const Text('Quebra',
            style: TextStyle(
                color: Color(Constants.invTextDark),
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Color(Constants.primaryRed), shape: BoxShape.circle),
              child: Text('${_itens.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscaController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _buscar(),
                    decoration: InputDecoration(
                      hintText: 'EAN / SAP',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF9E9E9E)),
                      filled: true,
                      fillColor: const Color(Constants.bgGray),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _escanear,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(Constants.primaryRed),
                      shape: BoxShape.circle,
                    ),
                    child: _buscando
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.qr_code_scanner,
                            color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: _corpo()),
          ],
        ),
      ),
    );
  }

  Widget _corpo() {
    if (_itens.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Adicione itens à quebra',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(Constants.invTextDark))),
          SizedBox(height: 8),
          Text('Utilize o EAN/SAP para adicionar itens e quantidades.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Color(Constants.invTextSecondary))),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      itemCount: _itens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final it = _itens[i];
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onLongPress: () => _removerItem(it),
          child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(Constants.borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(it.description,
                        style: const TextStyle(
                            color: Color(Constants.invTextDark),
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('EAN ${it.ean}   •   SAP ${it.sapCode}',
                        style: const TextStyle(
                            color: Color(Constants.invTextSecondary),
                            fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text('Quebra',
                      style: TextStyle(
                          color: Color(Constants.invTextSecondary),
                          fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('${it.quantity}',
                      style: const TextStyle(
                          color: Color(Constants.invTextDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ));
      },
    );
  }

  Future<void> _removerItem(BreakageItem it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Remover item'),
        content: Text('Remover "${it.description}" da quebra?'),
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
      final lista =
          await _service!.removeBreakageItem(widget.breakageId, it.id);
      if (!mounted) return;
      setState(() {
        _itens = lista ?? _itens.where((e) => e.id != it.id).toList();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao remover item'), backgroundColor: Colors.red));
    }
  }
}
