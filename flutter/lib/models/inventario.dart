// Models da API do Inventário (sl-bff.americanas.io).

class CycleCountPage {
  final int total;
  final int offset;
  final int limit;
  final List<Inventory> inventories;

  CycleCountPage({
    required this.total,
    required this.offset,
    required this.limit,
    required this.inventories,
  });

  factory CycleCountPage.fromJson(Map<String, dynamic> json) {
    final r = (json['_result'] as Map?) ?? const {};
    return CycleCountPage(
      total: (r['total'] as num?)?.toInt() ?? 0,
      offset: (r['offset'] as num?)?.toInt() ?? 0,
      limit: (r['limit'] as num?)?.toInt() ?? 0,
      inventories: (json['inventories'] as List? ?? const [])
          .map((e) => Inventory.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class Inventory {
  final String id;
  final String inventoryNumber;
  final String reference;
  final String createdAt;
  final String statusCode;
  final String statusName;

  Inventory({
    required this.id,
    required this.inventoryNumber,
    required this.reference,
    required this.createdAt,
    required this.statusCode,
    required this.statusName,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as Map?) ?? const {};
    return Inventory(
      id: json['id']?.toString() ?? '',
      inventoryNumber: json['inventoryNumber']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      statusCode: status['code']?.toString() ?? '',
      statusName: status['name']?.toString() ?? '',
    );
  }

  bool get finalizado => statusCode.toUpperCase() == 'FINISHED';
}

class StoreCycleCount {
  final bool enabled;
  final String type;

  StoreCycleCount({required this.enabled, required this.type});

  factory StoreCycleCount.fromJson(Map<String, dynamic> json) =>
      StoreCycleCount(
        enabled: json['status'] == true,
        type: json['type']?.toString() ?? '',
      );
}

class StoreInfo {
  final String id;
  final String name;
  final StoreCycleCount cycleCount;

  StoreInfo({required this.id, required this.name, required this.cycleCount});

  factory StoreInfo.fromJson(Map<String, dynamic> json) => StoreInfo(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        cycleCount: StoreCycleCount.fromJson(
            (json['cycleCount'] as Map?)?.cast<String, dynamic>() ?? const {}),
      );
}

class InventoryItem {
  final String id;
  final String ean;
  final String sapCode;
  final String departmentId;
  final String description;
  final int expectedQuantity;
  final int countedQuantity;
  final double unitPrice;
  final double amountDifference;

  InventoryItem({
    required this.id,
    required this.ean,
    required this.sapCode,
    required this.departmentId,
    required this.description,
    required this.expectedQuantity,
    required this.countedQuantity,
    required this.unitPrice,
    required this.amountDifference,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id']?.toString() ?? '',
        ean: json['ean']?.toString() ?? '',
        sapCode: json['sapCode']?.toString() ?? '',
        departmentId: json['departmentId']?.toString() ?? '',
        description: json['description']?.toString().trim() ?? '',
        expectedQuantity: (json['expectedQuantity'] as num?)?.toInt() ?? 0,
        countedQuantity: (json['countedQuantity'] as num?)?.toInt() ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        amountDifference: (json['amountDifference'] as num?)?.toDouble() ?? 0,
      );

  int get diferenca => countedQuantity - expectedQuantity;
}

class InventoryDetail {
  final String id;
  final String inventoryNumber;
  final String reference;
  final String statusCode;
  final String statusName;
  final List<InventoryItem> items;

  InventoryDetail({
    required this.id,
    required this.inventoryNumber,
    required this.reference,
    required this.statusCode,
    required this.statusName,
    required this.items,
  });

  factory InventoryDetail.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as Map?) ?? const {};
    return InventoryDetail(
      id: json['id']?.toString() ?? '',
      inventoryNumber: json['inventoryNumber']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      statusCode: status['code']?.toString() ?? '',
      statusName: status['name']?.toString() ?? '',
      items: (json['items'] as List? ?? const [])
          .map((e) => InventoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  bool get finalizado => statusCode.toUpperCase() == 'FINISHED';
}

class NotificationMessage {
  final String id;
  final String title;
  final String body;
  final String createdAt;
  final String status;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.status,
  });

  factory NotificationMessage.fromJson(Map<String, dynamic> json) =>
      NotificationMessage(
        id: (json['id'] ?? json['_id'])?.toString() ?? '',
        title: (json['title'] ?? json['subject'])?.toString() ?? '',
        body: (json['message'] ?? json['body'] ?? json['description'])
                ?.toString() ??
            '',
        createdAt: (json['createdAt'] ?? json['date'])?.toString() ?? '',
        status: json['status']?.toString() ?? '',
      );

  bool get lida => status.toUpperCase() == 'READ';
}

class NotificationPage {
  final int total;
  final int offset;
  final int limit;
  final List<NotificationMessage> messages;

  NotificationPage({
    required this.total,
    required this.offset,
    required this.limit,
    required this.messages,
  });

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final r = (json['_result'] as Map?) ?? const {};
    return NotificationPage(
      total: (r['total'] as num?)?.toInt() ?? 0,
      offset: (r['offset'] as num?)?.toInt() ?? 0,
      limit: (r['limit'] as num?)?.toInt() ?? 0,
      messages: (json['messages'] as List? ?? const [])
          .map((e) => NotificationMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class Product {
  final String sapCode;
  final String ean;
  final String description;
  final double quantity;
  final double stock;

  Product({
    required this.sapCode,
    required this.ean,
    required this.description,
    required this.quantity,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        sapCode: json['sapCode']?.toString() ?? '',
        ean: json['ean']?.toString() ?? '',
        description: json['description']?.toString().trim() ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        stock: (json['stock'] as num?)?.toDouble() ?? 0,
      );
}
