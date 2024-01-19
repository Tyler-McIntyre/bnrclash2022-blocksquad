import 'package:bnrclash2022_blocksquad/models/payment_response.dart';
import 'package:bnrclash2022_blocksquad/util/restapi.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'globals.dart';
import 'models/donations_dao.dart';
import 'models/payment.dart';

class SendPaymentBottomSheet extends StatefulWidget {
  const SendPaymentBottomSheet(this.projectTitle, {Key? key}) : super(key: key);
  final String projectTitle;

  @override
  State<StatefulWidget> createState() => _SendPaymentBottomSheetState();
}

class _SendPaymentBottomSheetState extends State<SendPaymentBottomSheet> {
  final RestApi api = RestApi();

  String paymentHash = "";
  String status = "";
  bool completedPayment = false;
  final TextEditingController _invoiceController = TextEditingController();
  int userInvoiceTotal = 0;

  @override
  void deactivate() {
    super.deactivate();
  }

  void getUserTotalFunds() async {
    int total = await getTotalForUser(widget.projectTitle, loggedInUserName);
    setState(() {
      userInvoiceTotal = total;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserTotalFunds();
  }

  sendPayment(String invoice) async {
    Payment payment = Payment(invoice);
    PaymentResponse responsePayment = await api.payLightningInvoice(payment);
    setState(() {
      paymentHash = responsePayment.paymentHash;
      status = responsePayment.status;
      completedPayment = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text.rich(
            TextSpan(text: 'Please send us an invoice for ', children: [
              TextSpan(
                  text: '$userInvoiceTotal ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'Sats '),
            ]),
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              controller: _invoiceController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Send Invoice',
                suffixIcon: IconButton(
                  onPressed: (() => {sendPayment(_invoiceController.text)}),
                  icon: const Icon(Icons.send),
                ),
              )),
          const SizedBox(
            height: 45,
          ),
          Visibility(
              visible: completedPayment,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Payment status: ',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                            color: status.contains('SUCCESS')
                                ? Colors.green
                                : Colors.red,
                            fontSize: 20),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Visibility(
                        visible: completedPayment,
                        child: status.contains('SUCCESS')
                            ? const Icon(FontAwesomeIcons.thumbsUp)
                            : const Icon(FontAwesomeIcons.thumbsDown),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Visibility(
                      visible: paymentHash != '',
                      child: Column(
                        children: [
                          const Text('Payment hash: ',
                              style: TextStyle(fontSize: 20)),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            paymentHash,
                            style: TextStyle(
                                color: status.contains('SUCCESS')
                                    ? Colors.green
                                    : Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ))
                ],
              ))
        ],
      ),
    );
  }
}
