import 'package:flutter/material.dart';
import '../models/inventario.dart';
import '../models/quebra.dart';
import '../utils/constants.dart';

class QuebraItemResult {
  final int quantidade;
  final BreakageReason motivo;

  QuebraItemResult(this.quantidade, this.motivo);
}

/// Bottom sheet "Adicionar item à quebra": descrição, EAN/SAP, Saldo atual,
/// quantidade a quebrar, motivo e os botões Cancelar / Confirmar e adicionar.
Future<QuebraItemResult?> mostrarDialogAdicionarQuebra(
  BuildContext context, {
  required Product produto,
  required List<BreakageReason> motivos,
  int quantidadeInicial = 0,
  String? motivoInicial,
}) {
  final qtdController =
      TextEditingController(text: quantidadeInicial.toString());
  BreakageReason? motivoSel;
  for (final m in motivos) {
    if (m.label == motivoInicial) {
      motivoSel = m;
      break;
    }
  }
  motivoSel ??= motivos.isNotEmpty ? motivos.first : null;

  return showModalBottomSheet<QuebraItemResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, 32 + MediaQuery.of(ctx).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, -5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(produto.description,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(Constants.invTextDark))),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('EAN: ${produto.ean}',
                    style: const TextStyle(
                        fontSize: 13, color: Color(Constants.invTextSecondary))),
                const SizedBox(width: 16),
                Text('Cód. SAP: ${produto.sapCode}',
                    style: const TextStyle(
                        fontSize: 13, color: Color(Constants.invTextSecondary))),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo atual',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text('${produto.stock.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: produto.stock < 0
                              ? Colors.red
                              : const Color(Constants.invTextDark))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtdController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Indique a quantidade de quebra',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BreakageReason>(
              value: motivoSel,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Selecione o motivo da quebra',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              items: motivos
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.label),
                      ))
                  .toList(),
              onChanged: (v) => setSheet(() => motivoSel = v),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style: TextStyle(
                        color: Color(Constants.primaryRed),
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(Constants.primaryRed),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: motivoSel == null
                    ? null
                    : () => Navigator.pop(
                          ctx,
                          QuebraItemResult(
                              int.tryParse(qtdController.text.trim()) ?? 0,
                              motivoSel!),
                        ),
                child: const Text('Confirmar e adicionar novo item',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
