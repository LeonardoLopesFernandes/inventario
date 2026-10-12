import 'package:flutter/material.dart';
import '../models/inventario.dart';
import '../network/api_client.dart';
import '../network/inventario_service.dart';
import '../network/session_manager.dart';
import '../utils/constants.dart';
import 'detalhe_inventario_screen.dart';
import 'criar_inventario_screen.dart';

class ListaInventarioScreen extends StatefulWidget {
  const ListaInventarioScreen({super.key});

  @override
  State<ListaInventarioScreen> createState() => _ListaInventarioScreenState();
}

class _ListaInventarioScreenState extends State<ListaInventarioScreen> {
  static const _limit = 20;

  final ScrollController _scroll = ScrollController();
  SessionManager? _session;
  InventarioService? _service;

  final List<Inventory> _items = [];
  int _offset = 0;
  bool _carregando = false;
  bool _isLastPage = false;
  String? _erro;
  String _filtro = 'Todos';
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
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
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    final service = _service;
    if (service == null) return;
    try {
      final now = DateTime.now();
      final created = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')} 00:00';
      final page = await service.getNotifications(
        storeId: _storeId,
        status: 'UNREAD',
        limit: 1,
        createdAt: created,
      );
      if (!mounted) return;
      setState(() => _unread = page.total);
    } catch (_) {}
  }

  String get _storeId =>
      _session?.getUserStore() ?? Constants.defaultStore;

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      _carregar();
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
      final page = await service.getCycleCounts(
        storeId: _storeId,
        offset: reset ? 0 : _offset,
        limit: _limit,
      );
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page.inventories);
        _offset = _items.length;
        _isLastPage = _items.length >= page.total ||
            page.inventories.isEmpty;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Falha ao carregar inventários';
        _carregando = false;
      });
    }
  }

  Future<void> _criarInventario() async {
    final service = _service;
    final session = _session;
    if (service == null) return;
    try {
      final inv = await service.createInventory(
          storeId: _storeId, email: session?.getUserEmail() ?? '');
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CriarInventarioScreen(inventoryId: inv.id),
      ));
      _carregar(reset: true);
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? 'HTTP ${e.code}: ${e.body}' : '$e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Falha ao criar inventário: $msg'),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _excluir(Inventory inv) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Excluir inventário'),
        content: Text('Deseja excluir ${inv.inventoryNumber}?'),
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
    if (confirmado != true) return;
    final service = _service;
    if (service == null) return;
    try {
      await service.deleteCycleCount(inv.id);
      if (!mounted) return;
      setState(() => _items.removeWhere((e) => e.id == inv.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Inventário excluído'),
          backgroundColor: Color(Constants.badgeGreen)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao excluir inventário'),
          backgroundColor: Colors.red));
    }
  }

  List<Inventory> get _filtrados {
    switch (_filtro) {
      case 'Finalizado':
        return _items.where((i) => i.finalizado).toList();
      case 'Em andamento':
        return _items.where((i) => !i.finalizado).toList();
      default:
        return _items;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(Constants.bgGray),
      appBar: _appBar(context),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _chip('Todos'),
                const SizedBox(width: 8),
                _chip('Em andamento'),
                const SizedBox(width: 8),
                _chip('Finalizado'),
              ],
            ),
          ),
          Expanded(child: _corpo()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criarInventario,
        backgroundColor: const Color(Constants.primaryRed),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 4,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('Criar inventário',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _corpo() {
    if (_session == null || (_carregando && _items.isEmpty)) {
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
    final lista = _filtrados;
    if (lista.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _carregar(reset: true),
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(child: Text('Nenhum inventário encontrado')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _carregar(reset: true),
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        itemCount: lista.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == lista.length) {
            return _carregando
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox(height: 80);
          }
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DetalheInventarioScreen(
                  inventoryId: lista[index].id,
                  inventoryNumber: lista[index].inventoryNumber,
                ),
              ),
            ),
            onLongPress: () => _excluir(lista[index]),
            child: _InventarioCard(inventario: lista[index]),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Text(
        'Inventário rotativo',
        style: TextStyle(
            color: Color(Constants.invTextDark),
            fontWeight: FontWeight.w500,
            fontSize: 20),
      ),
      actions: [
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.filter_alt_outlined,
              color: Color(Constants.invTextDark)),
        ),
        _NotificacaoBadge(count: _unread),
      ],
    );
  }

  Widget _chip(String label) {
    final selecionado = _filtro == label;
    return GestureDetector(
      onTap: () => setState(() => _filtro = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado
              ? const Color(Constants.primaryRed)
              : const Color(Constants.bgGray),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Colors.grey.shade400, width: selecionado ? 0 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selecionado)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              ),
            Text(
              label,
              style: TextStyle(
                color: selecionado
                    ? Colors.white
                    : const Color(Constants.invTextDark),
                fontWeight: selecionado ? FontWeight.bold : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventarioCard extends StatelessWidget {
  final Inventory inventario;

  const _InventarioCard({required this.inventario});

  @override
  Widget build(BuildContext context) {
    final badgeBg = inventario.finalizado
        ? const Color(Constants.invBadgeGreenBg)
        : const Color(Constants.bgGray);
    final badgeFg = inventario.finalizado
        ? const Color(Constants.invBadgeGreenText)
        : const Color(Constants.invTextSecondary);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: const Color(Constants.invLineGreen)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              inventario.inventoryNumber,
                              style: const TextStyle(
                                  color: Color(Constants.invTextDark),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              inventario.statusName,
                              style: TextStyle(
                                  color: badgeFg,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Usuário',
                                    style: TextStyle(
                                        color:
                                            Color(Constants.invTextSecondary),
                                        fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(inventario.reference,
                                    style: const TextStyle(
                                        color: Color(Constants.invTextDark),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Data de criação',
                                    style: TextStyle(
                                        color:
                                            Color(Constants.invTextSecondary),
                                        fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(inventario.createdAt,
                                    style: const TextStyle(
                                        color: Color(Constants.invTextDark),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificacaoBadge extends StatelessWidget {
  final int count;

  const _NotificacaoBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.notifications_none_outlined,
              color: Color(Constants.invTextDark)),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: Color(Constants.primaryRed), shape: BoxShape.circle),
                constraints:
                    const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}
