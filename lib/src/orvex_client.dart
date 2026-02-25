import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/invoice.dart';
import 'models/create_invoice_request.dart';

class OrvexClient {
  final String apiKey;
  final String baseUrl;

  OrvexClient({
    required this.apiKey,
    this.baseUrl = 'https://api.orvexpay.com',
  });

  Future<Invoice> createInvoice(CreateInvoiceRequest request) async {
    final url = Uri.parse('$baseUrl/api/invoice');

    // Convert request to JSON and ensure priceAmount is string if needed by backend,
    // but DTO said string. We handled it in toJson.
    final body = jsonEncode(request.toJson());

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        // The secret might be used for signature generation in the future,
        // but for now, the backend seems to rely on x-api-key for this endpoint
        // or Bearer token for merchant actions.
        // Based on `api.ts`, public invoice creation uses `x-api-key`.
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Invoice.fromJson(json);
    } else {
      throw Exception(
        'Failed to create invoice: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Invoice> getInvoice(String id) async {
    final url = Uri.parse('$baseUrl/api/invoice/$id');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Invoice.fromJson(json);
    } else {
      throw Exception(
        'Failed to get invoice: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Invoice> changeCurrency(String invoiceId, String currency) async {
    final url = Uri.parse('$baseUrl/api/invoice/$invoiceId/currency');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: '"$currency"', // Send string directly as body for [FromBody] string
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Invoice.fromJson(json);
    } else {
      throw Exception(
        'Failed to update currency: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> getPublicProject(String apiKeyId) async {
    final url = Uri.parse('$baseUrl/api/invoice/public/project/$apiKeyId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to get project info: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Invoice> createPublicInvoice(CreateInvoiceRequest request) async {
    final url = Uri.parse('$baseUrl/api/invoice/public');
    final body = jsonEncode({
      ...request.toJson(),
      'isDonation': true,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Invoice.fromJson(json);
    } else {
      throw Exception(
        'Failed to create public invoice: ${response.statusCode} ${response.body}',
      );
    }
  }
}
