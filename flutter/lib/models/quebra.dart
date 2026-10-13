// Models da API de Quebra (sl-bff).
Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// Motivos de quebra (carregados de /web/breakage/reasons).
class BreakageReason {
  final String id;
  final String label;
  final int reasonNumber;
  final int code;

  BreakageReason({
    required this.id,
    required this.label,
    required this.reasonNumber,
    required this.code,
  });

  factory BreakageReason.fromJson(Map<String, dynamic> j) => BreakageReason(
        id: (j['id'] ?? j['_id'])?.toString() ?? '',
        label: j['label']?.toString() ?? '',
        reasonNumber: (j['reasonNumber'] as num?)?.toInt() ?? 0,
        code: (j['code'] as num?)?.toInt() ?? 0,
      );
}

class Breakage {
  final String id;
  final String ean;
  final String sapCode;
  final String description;
  final int quantity;
  final String reason;
  final String createdAt;
  final String status;

  Breakage({
    required this.id,
    required this.ean,
    required this.sapCode,
    required this.description,
    required this.quantity,
    required this.reason,
    required this.createdAt,
    required this.status,
  });

  factory Breakage.fromJson(Map<String, dynamic> j) => Breakage(
        id: (j['id'] ?? j['_id'])?.toString() ?? '',
        ean: (j['ean'] ?? j['EAN'])?.toString() ?? '',
        sapCode: (j['sapCode'] ?? j['sap'])?.toString() ?? '',
        description:
            (j['description'] ?? j['descricao'])?.toString().trim() ?? '',
        quantity: (j['quantity'] ??
                j['quantidade'] ??
                j['breakageQuantity'] as num?)
            ?.toInt() ??
            0,
        reason: (j['reason'] ?? j['motivo'])?.toString() ?? '',
        createdAt:
            (j['createdAt'] ?? j['date'] ?? j['data'])?.toString() ?? '',
        status: j['status']?.toString() ?? '',
      );
}

class BreakagePage {
  final int total;
  final int limit;
  final int offset;
  final List<Breakage> breakages;

  BreakagePage({
    required this.total,
    required this.limit,
    required this.offset,
    required this.breakages,
  });

  factory BreakagePage.fromJson(Map<String, dynamic> j) {
    final r = _map(j['_result']);
    return BreakagePage(
      total: (r['total'] as num?)?.toInt() ?? 0,
      limit: (r['limit'] as num?)?.toInt() ?? 0,
      offset: (r['offset'] as num?)?.toInt() ?? 0,
      breakages: (j['breakages'] as List? ?? const [])
          .map((e) => Breakage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
