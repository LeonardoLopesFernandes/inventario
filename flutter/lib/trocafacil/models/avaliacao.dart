/// Modelos da Troca Fácil (lista de operações/avaliações).
class AvaliacaoProduct {
  final String productName;
  final String ean;
  final double unitValue;
  final int quantity;
  final String? avaliationId;
  final List<String> tags;
  final String? tradeAuthorization;

  AvaliacaoProduct({
    required this.productName,
    required this.ean,
    required this.unitValue,
    required this.quantity,
    required this.avaliationId,
    required this.tags,
    required this.tradeAuthorization,
  });

  factory AvaliacaoProduct.fromJson(Map<String, dynamic> j) {
    final rawTags = j['tags'];
    return AvaliacaoProduct(
      productName: (j['productName'] ?? '').toString(),
      ean: (j['ean'] ?? '').toString(),
      unitValue: (j['unitValue'] as num?)?.toDouble() ?? 0,
      quantity: (j['quantity'] as num?)?.toInt() ?? 0,
      avaliationId: j['avaliationId']?.toString(),
      tags: rawTags is List
          ? rawTags.map((e) => e.toString()).toList()
          : const [],
      tradeAuthorization: j['tradeAuthorization']?.toString(),
    );
  }
}

class Avaliacao {
  final String tradeId;
  final String avaliationDate;
  final String operation;
  final String cause;
  final double totalValue;
  final String transactionDate;
  final String costumerName;
  final List<AvaliacaoProduct> products;
  final String store;
  final String? exchangeStatus;
  final String? createdBy;
  final String? origin;
  final String? updatedBy;

  Avaliacao({
    required this.tradeId,
    required this.avaliationDate,
    required this.operation,
    required this.cause,
    required this.totalValue,
    required this.transactionDate,
    required this.costumerName,
    required this.products,
    required this.store,
    required this.exchangeStatus,
    required this.createdBy,
    required this.origin,
    required this.updatedBy,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> j) {
    final rawProducts = j['products'];
    return Avaliacao(
      tradeId: (j['tradeId'] ?? '').toString(),
      avaliationDate: (j['avaliationDate'] ?? '').toString(),
      operation: (j['operation'] ?? '').toString(),
      cause: (j['cause'] ?? '').toString(),
      totalValue: (j['totalValue'] as num?)?.toDouble() ?? 0,
      transactionDate: (j['transactionDate'] ?? '').toString(),
      costumerName: (j['costumerName'] ?? '').toString(),
      products: rawProducts is List
          ? rawProducts
              .whereType<Map>()
              .map((e) => AvaliacaoProduct.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      store: (j['store'] ?? '').toString(),
      exchangeStatus: j['exchangeStatus']?.toString(),
      createdBy: j['createdBy']?.toString(),
      origin: j['origin']?.toString(),
      updatedBy: j['updatedBy']?.toString(),
    );
  }

  /// Operação cancelada (não permite reimprimir a etiqueta).
  bool get cancelada {
    final s = (exchangeStatus ?? '').toUpperCase();
    return s.contains('CANCEL');
  }
}

class AvaliacoesPage {
  final List<Avaliacao> results;
  final int page;
  final int pageSize;
  final int totalElements;
  final int totalPages;

  AvaliacoesPage({
    required this.results,
    required this.page,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
  });

  factory AvaliacoesPage.fromJson(Map<String, dynamic> j) {
    final rawResults = j['results'];
    final meta = (j['metadata'] as Map?) ?? const {};
    return AvaliacoesPage(
      results: rawResults is List
          ? rawResults
              .whereType<Map>()
              .map((e) => Avaliacao.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      page: (meta['currentPage'] as num?)?.toInt() ?? 1,
      pageSize: (meta['pageSize'] as num?)?.toInt() ?? 20,
      totalElements: (meta['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
