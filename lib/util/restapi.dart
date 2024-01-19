import 'dart:convert';

import 'package:bnrclash2022_blocksquad/models/channel_balance.dart';
import 'package:bnrclash2022_blocksquad/models/invoice.dart';
import 'package:bnrclash2022_blocksquad/models/invoice_request.dart';
import 'package:http/http.dart' as http;

import '../models/payment.dart';
import '../models/payment_response.dart';

class RestApi {
  Future<ChannelBalance> getLightningBalance() async {
    String response = await _getRequest('/v1/balance/channels');
    return ChannelBalance.fromJson(jsonDecode(response));
  }

  Future<PaymentResponse> payLightningInvoice(Payment data) async {
    String response = await _postRequest('/v2/router/send', data.toJson());

    if (response.contains("SUCCEEDED")) {
      return PaymentResponse("SUCCESS", hackOutThePaymentHash(response));
    } else if (response.contains("error")) {
      return PaymentResponse("ERROR", 'Invoice has already been paid');
    } else if (response.contains('IN_FLIGHT')) {
      return PaymentResponse("NO ROUTE", '');
    }
    return PaymentResponse("FAILED", hackOutThePaymentHash(response));
  }

  /// Look for the first instance of "payment_hash" followed by 64 hex characters and return those characters
  String hackOutThePaymentHash(String response) {
    RegExp reg1 = RegExp(r'("payment_hash":"[0-9a-fA-F]{64})');
    Match? firstMatch = reg1.firstMatch(response);
    if (firstMatch == null) return "";
    String firstMatchString =
        response.substring(firstMatch.start, firstMatch.end);
    return firstMatchString.substring(firstMatchString.length - 64);
  }

  Future<Invoice> createInvoice(InvoiceRequest data) async {
    String response = await _postRequest('/v1/invoices', data.toJson());
    return Invoice.fromJson(jsonDecode(response));
  }

  Future<Invoice> getInvoice(String rHash) async {
    String hex = base64ToHex(rHash);
    String response = await _getRequest('/v1/invoice/$hex');
    return Invoice.fromJson(jsonDecode(response));
  }

  String base64ToHex(String source) =>
      base64Decode(LineSplitter.split(source).join())
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join();

  Future<String> _getRequest(String route) => _request(route, 'get', null);

  Future<String> _postRequest(String route, dynamic data) =>
      _request(route, 'post', data);

  Future<String> _request(
      String route, String method, Map<String, dynamic>? data) {
    // ignore: todo
    //TODO: Fetch these values from config file.
    /* In Polar, select a node then find these variable settings under 'connect'
    * Rest host contains your host + port number
    * Select Base64 and copy the admin macaroon
    */
    //!Android emulator uses 10.0.2.2 as an alias for localHost
    const String host = 'https://10.0.2.2';
    const int port = 8082;
    //!Macaroon hex is in base64
    const String macaroonHex =
        'AgEDbG5kAvgBAwoQwByI4E9Cu2ZVC0gKVYDxQRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYgqFfbW/PEZUMxBXEtjfLS3P8wDvpmLdpHChojxfMjTWY=';

    String url = _getURL(host, port, route);

    Map<String, String> headers = {
      'Grpc-Metadata-macaroon': macaroonHex,
      'Content-Type': 'application/json',
      'timeout_seconds': '60',
      'allow_self_payment': 'true'
    };

    return _restReq(headers, url, method, data);
  }

  _getURL(
    String host,
    int port,
    String route,
  ) {
    var baseUrl = '$host:$port';

    if (baseUrl[baseUrl.length - 1] == '/') {
      baseUrl = baseUrl.substring(0, -1);
    }

    return '$baseUrl$route';
  }

  Future<String> _restReq(
    Map<String, String> headers,
    String url,
    String method,
    Map<String, dynamic>? data,
  ) async {
    late http.Response response;

    if (method == 'get') {
      response = await http.get(Uri.parse(url), headers: headers);
    } else if (method == 'post') {
      response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(
          data,
        ),
      );
    }

    return response.body;
  }
}
