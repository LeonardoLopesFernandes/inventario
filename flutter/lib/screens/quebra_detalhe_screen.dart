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
  Breakage? _breakage;
  bool _somenteLeitura = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = await SessionManager.create();
    final service = InventarioService.forSession(session);
    Breakage? breakage;
    List<BreakageItem> itens = [];
    List<BreakageReason> reasons = const [];
    try {
      final d = await service.getBreakageDetail(widget.breakageId);
      breakage = d.breakage;
      itens = d.items;
      reasons = d.reasons;
    } catch (_) {
      try {
        reasons = await service.getBreakageReasons();
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _session = session;
      _service = service;
      _breakage = breakage;
      _itens = itens;
      _reasons = reasons;
      _somenteLeitura = breakage?.processado ?? false;
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
          content: Text('Falha ao adicionar item'),
          backgroundColor: Colors.red));
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

  Future<void> _descartarQuebra() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Descartar quebra'),
        content: const Text(
            'A quebra será removida e os itens descartados. Deseja continuar?'),
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
      await _service!.deleteBreakage(widget.breakageId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao descartar quebra'),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _abrirQuebra() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Abrir quebra'),
        content: const Text(
            'Deseja abrir (processar) a quebra? Depois não será possível alterar os itens.'),
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
      await _service!.processBreakage(widget.breakageId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Quebra aberta com sucesso'),
          backgroundColor: Color(Constants.badgeGreen)));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao abrir quebra'), backgroundColor: Colors.red));
    }
  }

  Future<void> _editarItem(BreakageItem it) async {
    final qtdController = TextEditingController(text: '${it.quantity}');
    BreakageReason? motivo;
    for (final m in _reasons) {
      if (m.label == it.reason) {
        motivo = m;
        break;
      }
    }
    motivo ??= _reasons.isNotEmpty ? _reasons.first : null;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Alterar item da quebra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(it.description,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(Constants.invTextDark))),
              const SizedBox(height: 4),
              Text('EAN ${it.ean}   •   SAP ${it.sapCode}',
                  style: const TextStyle(
                      color: Color(Constants.invTextSecondary), fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: qtdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade a quebrar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BreakageReason>(
                value: motivo,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  border: OutlineInputBorder(),
                ),
                items: _reasons
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.label),
                        ))
                    .toList(),
                onChanged: (v) => setDlg(() => motivo = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(Constants.primaryRed),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      final lista = await _service!.updateBreakageItem(
        widget.breakageId,
        it.id,
        quantity: int.tryParse(qtdController.text.trim()) ?? it.quantity,
        reasonId: motivo?.id ?? '',
      );
      if (!mounted) return;
      setState(() => _itens = lista ?? _itens);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao alterar item'), backgroundColor: Colors.red));
    }
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
            if (!_somenteLeitura) ...[
              const SizedBox(height: 12),
              _campoBusca(),
            ],
            if (_somenteLeitura) ...[
              const SizedBox(height: 12),
              _avisoConsulta(),
            ],
            const SizedBox(height: 12),
            Expanded(child: _corpo()),
            if (!_somenteLeitura) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _descartarQuebra,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(Constants.primaryRed),
                        side: const BorderSide(
                            color: Color(Constants.primaryRed)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('DESCARTAR QUEBRA',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _abrirQuebra,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(Constants.primaryRed),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('ABRIR QUEBRA',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _campoBusca() {
    return Row(
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
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
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
    );
  }

  Widget _avisoConsulta() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.warning_amber_rounded,
              color: Color(0xFFB26A00), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Quebra processada. Os dados estão disponíveis apenas para consulta.',
              style: TextStyle(color: Color(0xFF7A5200), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corpo() {
    if (_itens.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Nenhum item na quebra',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(Constants.invTextDark))),
          if (!_somenteLeitura) ...[
            const SizedBox(height: 8),
            const Text('Utilize o EAN/SAP para adicionar itens.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Color(Constants.invTextSecondary))),
          ],
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
          onLongPress: _somenteLeitura ? null : () => _removerItem(it),
          onTap: _somenteLeitura ? null : () => _editarItem(it),
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
                      if (it.reason.isNotEmpty)
                        Text('Motivo: ${it.reason}',
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
          ),
        );
      },
    );
  }
}
