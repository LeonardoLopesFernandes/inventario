import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventario/network/session_manager.dart';
import '../models/avaliacao.dart';
import 'troca_session.dart';

/// Cliente HTTP da Troca Fácil (bff-front).
///
/// O token (`authorization`) vem do login Microsoft da Troca Fácil (guardado
/// em [TrocaSession]); a loja vem da sessão principal. `loja` no header leva o
/// prefixo "L" (ex.: L291).
class TrocaApi {
  static const String baseUrl =
      'https://trocafacil-bff-front.americanas.io/bff-frontend';

  Future<Map<String, String>> _headers() async {
    final troca = await TrocaSession.create();
    final token = troca.getToken() ?? '';
    final session = await SessionManager.create();
    final store = session.getUserStore();
    return {
      'accept': 'application/json, text/plain, */*',
      'authorization': token,
      'loja': store,
      'permissions': 'LOJA_RESPONSAVEL',
      'origin': 'https://trocafacil.americanas.io',
      'referer': 'https://trocafacil.americanas.io/',
    };
  }

  Future<String> _storeRaw() async {
    final session = await SessionManager.create();
    // store sem o prefixo "L" (ex.: 291).
    return session.getUserStore().replaceFirst(RegExp('^L'), '');
  }

  /// Lista as operações/avaliações (endpoint /bff-trade/avaliations).
  Future<AvaliacoesPage> getAvaliacoes({
    required String startDate,
    required String finalDate,
    int sort = -1,
    int pageSize = 20,
    int page = 1,
    String? status,
    String? operation,
    String? cause,
    String? transactionDate,
    String? productName,
    String? costumerName,
    String? costumerDocument,
    String? tag,
    String? tradeId,
    String? origin,
  }) async {
    final session = await SessionManager.create();
    final store = session.getUserStore();
    final query = <String, String>{
      'startDate': startDate,
      'finalDate': finalDate,
      'store': store,
      'sort': '$sort',
      'pageSize': '$pageSize',
      'page': '$page',
      if (status != null && status.isNotEmpty) 'status': status,
      if (operation != null && operation.isNotEmpty) 'operation': operation,
      if (cause != null && cause.isNotEmpty) 'cause': cause,
      if (transactionDate != null && transactionDate.isNotEmpty)
        'transactionDate': transactionDate,
      if (productName != null && productName.isNotEmpty)
        'productName': productName,
      if (costumerName != null && costumerName.isNotEmpty)
        'costumerName': costumerName,
      if (costumerDocument != null && costumerDocument.isNotEmpty)
        'costumerDocument': costumerDocument,
      if (tag != null && tag.isNotEmpty) 'tag': tag,
      if (tradeId != null && tradeId.isNotEmpty) 'tradeId': tradeId,
      if (origin != null && origin.isNotEmpty) 'origin': origin,
    };
    final uri = Uri.parse('$baseUrl/bff-trade/avaliations')
        .replace(queryParameters: query);
    final resp = await http.get(uri, headers: await _headers());
    if (resp.statusCode == 401) {
      throw TrocaApiException(401, 'Sessão expirada');
    }
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw TrocaApiException(resp.statusCode, 'Erro ${resp.statusCode}');
    }
    final body = resp.body.isEmpty
        ? <String, dynamic>{}
        : json.decode(resp.body) as Map<String, dynamic>;
    return AvaliacoesPage.fromJson(body);
  }

  /// Consulta uma operação/troca por id.
  Future<Map<String, dynamic>> getOperacao(String tradeId) async {
    final uri = Uri.parse('$baseUrl/bff-trade/operation/$tradeId');
    final resp = await http.get(uri, headers: await _headers());
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw TrocaApiException(resp.statusCode, 'Erro ${resp.statusCode}');
    }
    return json.decode(resp.body) as Map<String, dynamic>;
  }

  /// Formata data ISO/AAAA-MM-DDTHH:mm:ss em dd/MM/yyyy.
  static String fmtIsoDate(String iso) {
    if (iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  /// Formata AAAAMMDD em dd/MM/yyyy.
  static String fmtCompactDate(String v) {
    if (v.length != 8) return v;
    return '${v.substring(6, 8)}/${v.substring(4, 6)}/${v.substring(0, 4)}';
  }
}

class TrocaApiException implements Exception {
  final int statusCode;
  final String message;
  TrocaApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}
