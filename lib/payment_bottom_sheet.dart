import 'dart:async';
import 'package:bnrclash2022_blocksquad/models/donations.dart';
import 'package:bnrclash2022_blocksquad/models/donations_dao.dart';
import 'package:bnrclash2022_blocksquad/models/invoice.dart';
import 'package:bnrclash2022_blocksquad/models/invoice_request.dart';
import 'package:bnrclash2022_blocksquad/models/project.dart';
import 'package:bnrclash2022_blocksquad/models/project_dao.dart';
import 'package:bnrclash2022_blocksquad/util/restapi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'globals.dart' as globals;

class PaymentBottomSheet extends StatefulWidget {
  final String amount;
  final Project project;

  const PaymentBottomSheet(this.amount, this.project, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final RestApi api = RestApi();

  String _invoiceText = "loading invoice";
  String _invoiceHash = "";
  bool _isPaymentSettled = false;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initInvoice();
  }

  @override
  void deactivate() {
    _timer?.cancel();
    super.deactivate();
  }

  Future<void> _initInvoice() async {
    InvoiceRequest testInvoice = InvoiceRequest(widget.amount);
    Invoice responseInvoice = await api.createInvoice(testInvoice);

    setState(() {
      _invoiceText = responseInvoice.paymentRequest;
      _invoiceHash = responseInvoice.rHash;
    });
  }

  Future<Timer> _listenForPayment() async {
    setState(() {
      _isLoading = true;
    });

    // Ideally we would use the subscribe endpoint, but i don't see how to get
    // a stream of responses with Dart.  Instead, check the endpoint every 2 seconds
    return Timer.periodic(const Duration(seconds: 2), (Timer t) async {
      Invoice updated = await api.getInvoice(_invoiceHash);
      if (updated.settled == true) {
        t.cancel();
        setState(() {
          _isLoading = false;
          _isPaymentSettled = true;
        });

        DonationsDAO dao = DonationsDAO();
        dao.saveDonation(Donations(widget.project.title, widget.project.creator,
            globals.loggedInUserName, widget.amount));

        ProjectDAO projectDao = ProjectDAO();
        projectDao.updateProjectFunding(widget.project, widget.amount);

        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            "Scan QR Code:",
            style: TextStyle(fontSize: 16),
          ),
          QrImage(
            data: _invoiceText,
            version: QrVersions.auto,
            size: 240,
            gapless: false,
          ),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _invoiceText));
              _listenForPayment().then((value) => _timer = value);
            },
            icon: const Icon(
              Icons.copy,
              size: 24.0,
            ),
            label: Text(
              _invoiceText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ), // <-- Text
          ),
          Visibility(
              visible: _isLoading,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )),
          Visibility(
              visible: _isPaymentSettled,
              child: const Text(
                "Payment Complete. Thank you for your support!",
                style: TextStyle(fontSize: 16),
              ))
        ],
      ),
    );
  }
}
