/// Formata uma data para dd/MM/yyyy, convertendo de UTC para o horário local
/// quando a string vier no formato ISO (ex.: `2026-10-13T00:33:56Z`).
/// Se não for ISO (ex.: `09/10/2026`), devolve como veio.
String formatDataBr(String valor) {
  if (valor.isEmpty) return valor;
  final d = DateTime.tryParse(valor);
  if (d == null) return valor;
  final l = d.toLocal();
  return '${l.day.toString().padLeft(2, '0')}/'
      '${l.month.toString().padLeft(2, '0')}/${l.year}';
}
