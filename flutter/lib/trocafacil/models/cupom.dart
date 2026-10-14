/// Modelos do cupom (Troca Fácil) — base-cupom/get_cupom.
class CupomProduct {
  final String ean;
  final String sku;
  final String automationCodeNumber;
  final String name;
  final String description;
  final String category;
  final String departmentCode;
  final String line;
  final String nsu;
  final String imeiCode;
  final String serialNumber;
  final String treatmentCode;
  final String treatmentDescription;
  final String supplierCode;
  final String supplierDescription;
  final String message;
  final String note;
  final String catalog;
  final String currentPrice;
  final double unitValue;
  final double totalSaleValue;
  final int totalSaleQuantity;
  final int totalQuantityAvailable;
  final bool evaluated;
  final bool excededTime;

  CupomProduct({
    required this.ean,
    required this.sku,
    required this.automationCodeNumber,
    required this.name,
    required this.description,
    required this.category,
    required this.departmentCode,
    required this.line,
    required this.nsu,
    required this.imeiCode,
    required this.serialNumber,
    required this.treatmentCode,
    required this.treatmentDescription,
    required this.supplierCode,
    required this.supplierDescription,
    required this.message,
    required this.note,
    required this.catalog,
    required this.currentPrice,
    required this.unitValue,
    required this.totalSaleValue,
    required this.totalSaleQuantity,
    required this.totalQuantityAvailable,
    required this.evaluated,
    required this.excededTime,
  });

  factory CupomProduct.fromJson(Map<String, dynamic> j) => CupomProduct(
        ean: (j['ean'] ?? '').toString(),
        sku: (j['sku'] ?? '').toString(),
        automationCodeNumber: (j['automationCodeNumber'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        category: (j['category'] ?? '').toString(),
        departmentCode: (j['departmentCode'] ?? '').toString(),
        line: (j['line'] ?? '').toString(),
        nsu: (j['nsu'] ?? '').toString(),
        imeiCode: (j['imeiCode'] ?? '').toString(),
        serialNumber: (j['serialNumber'] ?? '').toString(),
        treatmentCode: (j['treatmentCode'] ?? '').toString(),
        treatmentDescription: (j['treatmentDescription'] ?? '').toString(),
        supplierCode: (j['supplierCode'] ?? '').toString(),
        supplierDescription: (j['supplierDescription'] ?? '').toString(),
        message: (j['message'] ?? '').toString(),
        note: (j['note'] ?? '').toString(),
        catalog: (j['catalog'] ?? '').toString(),
        currentPrice: (j['currentPrice'] ?? '').toString(),
        unitValue: (j['unitValue'] as num?)?.toDouble() ?? 0,
        totalSaleValue: (j['totalSaleValue'] as num?)?.toDouble() ?? 0,
        totalSaleQuantity: (j['totalSaleQuantity'] as num?)?.toInt() ?? 0,
        totalQuantityAvailable:
            (j['totalQuantityAvailable'] as num?)?.toInt() ?? 0,
        evaluated: j['evaluated'] == true,
        excededTime: j['excededTime'] == true,
      );
}

class Cupom {
  final String creationDate;
  final String couponPdvNumber;
  final String couponStoreNumber;
  final String couponNumber;
  final String keyNfce;
  final double totalValue;
  final List<CupomProduct> products;

  Cupom({
    required this.creationDate,
    required this.couponPdvNumber,
    required this.couponStoreNumber,
    required this.couponNumber,
    required this.keyNfce,
    required this.totalValue,
    required this.products,
  });

  factory Cupom.fromJson(Map<String, dynamic> j) {
    final raw = j['products'];
    return Cupom(
      creationDate: (j['creationDate'] ?? '').toString(),
      couponPdvNumber: (j['couponPdvNumber'] ?? '').toString(),
      couponStoreNumber: (j['couponStoreNumber'] ?? '').toString(),
      couponNumber: (j['couponNumber'] ?? '').toString(),
      keyNfce: (j['keyNfce'] ?? '').toString(),
      totalValue: (j['totalValue'] as num?)?.toDouble() ?? 0,
      products: raw is List
          ? raw
              .whereType<Map>()
              .map((e) => CupomProduct.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}
