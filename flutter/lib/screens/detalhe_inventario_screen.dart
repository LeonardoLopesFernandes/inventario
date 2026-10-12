import 'package:flutter/material.dart';
import '../models/inventario.dart';
import '../network/inventario_service.dart';
import '../network/session_manager.dart';
import '../utils/constants.dart';

class DetalheInventarioScreen extends StatefulWidget {
  final String inventoryId;
  final String? inventoryNumber;

  const DetalheInventarioScreen({
    super.key,
    required this.inventoryId,
    this.inventoryNumber,
  });

  @override
  State<DetalheInventarioScreen> createState() =>
      _DetalheInventarioScreenState();
}

class _DetalheInventarioScreenState extends State<DetalheInventarioScreen> {
  bool _carregando = true;
  InventoryDetail? _detalhe;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final session = await SessionManager.create();
      final service = InventarioService.forSession(session);
      final d = await service.getCycleCount(widget.inventoryId);
      if (!mounted) return;
      setState(() {
        _detalhe = d;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Falha ao carregar o inventário';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _detalhe;
    return Scaffold(
      backgroundColor: const Color(Constants.bgGray),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(Constants.invTextDark)),
        title: Text(
          d?.inventoryNumber ?? widget.inventoryNumber ?? 'Inventário',
          style: const TextStyle(
              color: Color(Constants.invTextDark),
              fontWeight: FontWeight.w500,
              fontSize: 20),
        ),
      ),
      body: _corpo(),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _carregar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    final d = _detalhe!;
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerInfo(d),
          if (d.finalizado) ...[
            const SizedBox(height: 12),
            _avisoFinalizado(),
          ],
          const SizedBox(height: 16),
          Text('Itens (${d.items.length})',
              style: const TextStyle(
                  color: Color(Constants.invTextDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          if (d.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Nenhum item neste inventário')),
            )
          else
            ...d.items.map((i) => _ItemCard(item: i)),
        ],
      ),
    );
  }

  Future<void> _excluirInventario() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Excluir inventário'),
        content: Text(
            'Deseja excluir ${_detalhe?.inventoryNumber ?? 'este inventário'}?'),
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
      final session = await SessionManager.create();
      final service = InventarioService.forSession(session);
      await service.deleteCycleCount(widget.inventoryId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Inventário excluído'),
          backgroundColor: Color(Constants.badgeGreen)));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Falha ao excluir inventário'),
          backgroundColor: Colors.red));
    }
  }

  Widget _avisoFinalizado() {
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
              'Inventário finalizado. Os dados deste inventário estão disponíveis apenas para consulta.',
              style: TextStyle(color: Color(0xFF7A5200), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerInfo(InventoryDetail d) {
    final finalizado = d.finalizado;
    final badgeBg = finalizado
        ? const Color(Constants.invBadgeGreenBg)
        : const Color(Constants.bgGray);
    final badgeFg = finalizado
        ? const Color(Constants.invBadgeGreenText)
        : const Color(Constants.invTextSecondary);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Referência',
                  style: TextStyle(
                      color: Color(Constants.invTextSecondary), fontSize: 12)),
              const SizedBox(height: 2),
              Text(d.reference,
                  style: const TextStyle(
                      color: Color(Constants.invTextDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(d.statusName,
                style: TextStyle(
                    color: badgeFg,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ItemCard({required this.item, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final dif = item.diferenca;
    final corDif = dif == 0
        ? const Color(Constants.invTextSecondary)
        : (dif > 0 ? const Color(Constants.badgeGreen) : Colors.red);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description,
                style: const TextStyle(
                    color: Color(Constants.invTextDark),
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 6),
            Text('EAN ${item.ean}   •   SAP ${item.sapCode}',
                style: const TextStyle(
                    color: Color(Constants.invTextSecondary), fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                _qtdCol('Esperado', item.expectedQuantity.toString(),
                    const Color(Constants.invTextDark)),
                _qtdCol('Contado', item.countedQuantity.toString(),
                    const Color(Constants.invTextDark)),
                _qtdCol('Dif.', dif.toString(), corDif),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtdCol(String label, String valor, Color valorCor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(Constants.invTextSecondary), fontSize: 12)),
          const SizedBox(height: 2),
          Text(valor,
              style: TextStyle(
                  color: valorCor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
