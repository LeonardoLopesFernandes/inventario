import 'dart:typed_data';
import 'package:barcode/barcode.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Gera o PDF da etiqueta/vale troca a partir dos dados da operação e salva
/// em `Download/Troca` (via canal nativo com MediaStore).
class TrocaEtiquetaPdf {
  TrocaEtiquetaPdf._();

  static String _brl(num v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  static Future<Uint8List> gerar({
    required String labelNumber,
    required String tradeId,
    required String loja,
    required String data,
    required String cliente,
    required String documento,
    required String produto,
    required num valor,
  }) async {
    final doc = pw.Document();
    final pageFormat = PdfPageFormat(
      100 * PdfPageFormat.mm,
      150 * PdfPageFormat.mm,
      marginAll: 8 * PdfPageFormat.mm,
    );
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('VALE TROCA',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _linha('Loja', loja),
            _linha('Operação', tradeId),
            _linha('Data', data),
            pw.Divider(),
            if (cliente.isNotEmpty) _linha('Cliente', cliente),
            if (documento.isNotEmpty) _linha('Documento', documento),
            pw.SizedBox(height: 6),
            if (produto.isNotEmpty) _linha('Produto', produto),
            _linha('Valor', _brl(valor)),
            pw.SizedBox(height: 12),
            pw.Text('Nº da etiqueta',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.Text(labelNumber,
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.BarcodeWidget(
              barcode: Barcode.code128(),
              data: labelNumber,
              width: 260,
              height: 90,
              drawText: true,
              textStyle: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  static pw.Widget _linha(String label, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 70,
            child: pw.Text('$label:',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(valor, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  /// Gera e salva em Download/Troca. Retorna true se salvou.
  static Future<bool> salvarNoDownloads({
    required String labelNumber,
    required String tradeId,
    required String loja,
    required String data,
    required String cliente,
    required String documento,
    required String produto,
    required num valor,
  }) async {
    final bytes = await gerar(
      labelNumber: labelNumber,
      tradeId: tradeId,
      loja: loja,
      data: data,
      cliente: cliente,
      documento: documento,
      produto: produto,
      valor: valor,
    );
    const channel = MethodChannel('com.ir/media');
    final uri = await channel.invokeMethod<String>('saveToDownloads', {
      'fileName': 'etiqueta_$labelNumber.pdf',
      'mime': 'application/pdf',
      'bytes': bytes,
      'subfolder': 'Troca',
    });
    return uri != null && uri.isNotEmpty;
  }
}
