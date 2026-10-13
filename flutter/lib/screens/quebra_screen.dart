import 'package:flutter/material.dart';
import '../models/quebra.dart';
import '../network/inventario_service.dart';
import '../network/session_manager.dart';
import '../utils/constants.dart';
import 'quebra_detalhe_screen.dart';

class QuebraScreen extends StatefulWidget {
  const QuebraScreen({super.key});

  @override
  State<QuebraScreen> createState() => _QuebraScreenState();
}

class _QuebraScreenState extends State<QuebraScreen> {
  SessionManager? _session;
  InventarioService? _service;

  final List<Breakage> _items = [];
  bool _carregando = false;
  bool _isLastPage = false;
  String? _erro;
  int _offset = 0;

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
    _carregar(reset: true);
  }

  String get _storeId => _session?.getUserStore() ?? Constants.defaultStore;

  Future<void> _novaQuebra() async {
    final service = _service;
    final session = _session;
    if (service == null) return;
    try {
      final b = await service.createBreakage(
        storeId: _storeId,
        userName: session?.getUserName() ?? '',
        userEmail: session?.getUserEmail() ?? '',
      );
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => QuebraDetalheScreen(breakageId: b.id),
      ));
      _carregar(reset: true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao criar quebra'), backgroundColor: Colors.red));
    }
  }

  Future<void> _carregar({bool reset = false}) async {
    if (_carregando) return;
    if (!reset && _isLastPage) return;
    final service = _service;
    if (service == null) return;
    setState(() {
      _carregando = true;
      if (reset) {
        _erro = null;
        _offset = 0;
        _isLastPage = false;
      }
    });
    try {
      final page = await service.getBreakages(
        year: DateTime.now().year,
        store: _storeId,
        offset: reset ? 0 : _offset,
        limit: 15,
      );
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page.breakages);
        _offset = _items.length;
        _isLastPage = _items.length >= page.total || page.breakages.isEmpty;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Falha ao carregar quebras';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(Constants.bgGray),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(Constants.invTextDark)),
        title: const Text('Quebra de itens',
            style: TextStyle(
                color: Color(Constants.invTextDark),
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: _corpo(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novaQuebra,
        backgroundColor: const Color(Constants.primaryRed),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        icon: const Icon(Icons.add),
        label: const Text('Nova quebra',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _corpo() {
    if ((_carregando && _items.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _carregar(reset: true),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _carregar(reset: true),
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(child: Text('Nenhuma quebra encontrada')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _carregar(reset: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _BreakageCard(breakage: _items[i]),
      ),
    );
  }
}

class _BreakageCard extends StatelessWidget {
  final Breakage breakage;

  const _BreakageCard({required this.breakage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  breakage.description.isNotEmpty
                      ? breakage.description
                      : (breakage.id.isEmpty ? 'Quebra' : breakage.id),
                  style: const TextStyle(
                      color: Color(Constants.invTextDark),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              if (breakage.quantity != 0)
                Text('${breakage.quantity}',
                    style: const TextStyle(
                        color: Color(Constants.invTextDark),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
            ],
          ),
          if (breakage.ean.isNotEmpty || breakage.sapCode.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('EAN ${breakage.ean}   •   SAP ${breakage.sapCode}',
                style: const TextStyle(
                    color: Color(Constants.invTextSecondary), fontSize: 12)),
          ],
          if (breakage.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Motivo: ${breakage.reason}',
                style: const TextStyle(
                    color: Color(Constants.invTextSecondary), fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
