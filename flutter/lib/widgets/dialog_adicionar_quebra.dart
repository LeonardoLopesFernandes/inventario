import 'package:flutter/material.dart';
import '../models/inventario.dart';
import '../models/quebra.dart';
import '../utils/constants.dart';

enum QuebraDialogAction { cancelar, inserirOutro, confirmar }

class QuebraDialogResult {
  final QuebraDialogAction action;
  final int quantidade;
  final BreakageReason? motivo;

  QuebraDialogResult(this.action, this.quantidade, this.motivo);
}

/// Dialog "Adicionar item à quebra", com Saldo atual (do produto), campo de
/// quantidade a quebrar, spinner de Motivo e os botões
/// CANCELAR / INSERIR OUTRO ITEM / CONFIRMAR.
Future<QuebraDialogResult?> mostrarDialogAdicionarQuebra(
  BuildContext context, {
  required Product produto,
  required List<BreakageReason> motivos,
}) {
  final qtdController = TextEditingController(text: '0');
  BreakageReason? motivoSel = motivos.isNotEmpty ? motivos.first : null;

  return showDialog<QuebraDialogResult>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDlg) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Adicionar item à quebra',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(Constants.invTextDark)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(produto.description,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(Constants.invTextDark))),
                        const SizedBox(height: 4),
                        Text('EAN: ${produto.ean}',
                            style: const TextStyle(
                                color: Color(Constants.invTextSecondary),
                                fontSize: 14)),
                        Text('SAP: ${produto.sapCode}',
                            style: const TextStyle(
                                color: Color(Constants.invTextSecondary),
                                fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo atual',
                            style: TextStyle(
                                color: Color(Constants.invTextSecondary),
                                fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${produto.stock.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: produto.stock < 0
                                    ? Colors.red
                                    : const Color(Constants.invTextDark))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Indique abaixo a quantidade a quebrar.',
                  style: TextStyle(
                      color: Color(Constants.invTextDark), fontSize: 14)),
              const SizedBox(height: 8),
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
                value: motivoSel,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  border: OutlineInputBorder(),
                ),
                items: motivos
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.label),
                        ))
                    .toList(),
                onChanged: (v) => setDlg(() => motivoSel = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
                ctx,
                QuebraDialogResult(
                    QuebraDialogAction.cancelar, 0, motivoSel)),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
                ctx,
                QuebraDialogResult(
                    QuebraDialogAction.inserirOutro,
                    int.tryParse(qtdController.text.trim()) ?? 0,
                    motivoSel)),
            child: const Text('INSERIR OUTRO ITEM'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(Constants.primaryRed),
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: () => Navigator.pop(
                ctx,
                QuebraDialogResult(
                    QuebraDialogAction.confirmar,
                    int.tryParse(qtdController.text.trim()) ?? 0,
                    motivoSel)),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    ),
  );
}
