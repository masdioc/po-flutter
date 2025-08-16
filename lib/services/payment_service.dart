import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static const String baseUrl = "https://stagingappku.my.id/po-api/api";

  /// Proses pembayaran dengan optional bukti file
  static Future<Map<String, dynamic>> payOrder({
    required int purchaseOrderId,
    required String paymentDate,
    required double amount,
    required String method,
    required String note,
    required String token,
    File? proofFile,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/payments");

      var request = http.MultipartRequest('POST', uri);

      // Header Authorization
      request.headers['Authorization'] = 'Bearer $token';

      // Fields form
      request.fields['purchase_order_id'] = purchaseOrderId.toString();
      request.fields['payment_date'] = paymentDate;
      request.fields['amount'] = amount.toString();
      request.fields['method'] = method;
      request.fields['note'] = note;

      // File proof (jika ada)
      if (proofFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'proof', // nama parameter yang diterima API
          proofFile.path,
        ));
      }

      // Kirim request
      var response = await request.send();

      var responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data['message'] ?? "Pembayaran berhasil"
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Pembayaran gagal"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
