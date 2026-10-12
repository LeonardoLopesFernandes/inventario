import 'api_client.dart';
import '../utils/constants.dart';
import '../models/inventario.dart';

/// Serviço da API do Inventário (sl-bff).
class InventarioService {
  final ApiClient client;

  InventarioService(this.client);

  /// Client já configurado para o sl-bff.
  factory InventarioService.forSession(dynamic session) => InventarioService(
        ApiClient(session,
            baseUrl: Constants.slBffBaseUrl,
            platformVersion: Constants.platformVersion),
      );

  Future<CycleCountPage> getCycleCounts({
    required String storeId,
    int offset = 0,
    int limit = 20,
  }) async {
    final json = await client.get('web/cycle-count', query: {
      'storeId': storeId,
      'offset': offset.toString(),
      'limit': limit.toString(),
    }) as Map<String, dynamic>;
    return CycleCountPage.fromJson(json);
  }

  Future<StoreInfo?> getStore(String storeId) async {
    final json = await client.get('web/store', query: {
      'limit': '1',
      'offset': '0',
      'ids': storeId,
    }) as Map<String, dynamic>;
    final stores = json['stores'] as List? ?? const [];
    if (stores.isEmpty) return null;
    return StoreInfo.fromJson(Map<String, dynamic>.from(stores.first));
  }

  Future<InventoryDetail> getCycleCount(String id) async {
    final json =
        await client.get('web/cycle-count/$id') as Map<String, dynamic>;
    return InventoryDetail.fromJson(json);
  }

  Future<NotificationPage> getNotifications({
    required String storeId,
    String status = 'UNREAD',
    int limit = 4,
    int offset = 0,
    String? createdAt,
  }) async {
    final query = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
      'status': status,
      'storeId': storeId,
    };
    if (createdAt != null) query['createdAt'] = createdAt;
    final json = await client.get('web/notification', query: query)
        as Map<String, dynamic>;
    return NotificationPage.fromJson(json);
  }

  Future<Product> getProduct({
    required String storeId,
    String? ean,
    String? sapCode,
  }) async {
    final query = <String, String>{};
    if (ean != null && ean.isNotEmpty) query['ean'] = ean;
    if (sapCode != null && sapCode.isNotEmpty) query['sapCode'] = sapCode;
    final json = await client.get(
        'web/cycle-count/product/store/$storeId',
        query: query) as Map<String, dynamic>;
    return Product.fromJson(json);
  }

  /// Adiciona um item ao inventário (draft).
  Future<void> addItem(
    String inventoryId, {
    required String ean,
    required String sapCode,
    required String description,
    int expectedQuantity = 0,
    int countedQuantity = 0,
    double unitPrice = 0,
  }) async {
    await client.post('web/cycle-count/$inventoryId/item', body: {
      'ean': ean,
      'sapCode': sapCode,
      'description': description,
      'expectedQuantity': expectedQuantity,
      'countedQuantity': countedQuantity,
      'unitPrice': unitPrice,
    });
  }

  /// Exclui um inventário.
  Future<void> deleteCycleCount(String inventoryId) async {
    await client.delete('web/cycle-count/$inventoryId');
  }

  /// Cria um inventário (draft) e retorna o objeto criado.
  Future<Inventory> createInventory({
    required String storeId,
    required String email,
  }) async {
    final json = await client.post('web/cycle-count',
        body: {'storeId': storeId, 'email': email}) as Map<String, dynamic>;
    return Inventory.fromJson(json);
  }

  /// Finaliza (processa) o inventário.
  Future<void> processInventory(String inventoryId) async {
    await client.post('web/cycle-count/$inventoryId/process');
  }

  /// Atualiza a quantidade contada de um item.
  Future<void> updateItem(
    String inventoryId,
    String itemId, {
    required int quantity,
  }) async {
    await client.put('web/cycle-count/$inventoryId/item/$itemId',
        body: {'quantity': quantity});
  }

  /// Remove itens do inventário (lista de ids).
  Future<void> removeItems(String inventoryId, List<String> ids) async {
    await client.post('web/cycle-count/$inventoryId/item/remove',
        body: {'items': ids});
  }
}
