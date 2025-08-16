import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = "https://stagingappku.my.id/po-api/api";

  static Future<Map<String, dynamic>> payOrder({
    required int purchaseOrderId,
    required String paymentDate,
    required double amount,
    required String method,
    required String note,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/payments");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "purchase_order_id": purchaseOrderId,
        "payment_date": paymentDate,
        "amount": amount,
        "method": method,
        "note": note,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal melakukan pembayaran: ${response.body}");
    }
  }
}
