import 'package:billable/const.dart';
import 'package:billable/models/products.dart';
import 'package:billable/screens/home.dart';
import 'dart:math';
import 'package:billable/utilities/network_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


class Payment extends StatefulWidget {
  Payment({required this.amount, required this.productList, required this.name, required this.number});
  String amount;
  List<Product> productList;
  String name;
  String number;

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {

  Razorpay _razorpay = Razorpay();
  late String order_id;


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear();
  }

  int getRandom() {
    Random random = Random();
    int randomNumber = random.nextInt(10000);
    return randomNumber;// from 0 upto 99 included
  }

  @override
  initState() {
    super.initState();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0),
              width: double.infinity,
              alignment: Alignment.topLeft,
              child: const Text(
                "Payment",
                style: kExtraLargeTitleDark,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            ListTile(
              leading: const Icon(
                Icons.monetization_on,
                color: kDarkBlue,
              ),
              title: Text("₹ ${widget.amount}",
              style: kMediumTextDark,),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:   const Text(
                "Pay with razorpay with Card, UPI, or NetBanking",
                style: kSmallTextDark,
              ),
            ),

            Expanded(child: Container(
              child: Image.asset("images/assets/payment.png"),
            )),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    height: 65,
                    minWidth: MediaQuery.of(context).size.width/2 - 24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                    ),
                    onPressed: () async {
                      String here = await NetworkHelper(context: context).getData(int.parse(widget.amount), getRandom().toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                        content: Text(here),
                        duration: const Duration(milliseconds: 400),
                        ));
                      },
                    child: const Text("Create Order"),
                  ),
                  MaterialButton(
                    height: 65,
                    color: kOrangeColor,
                    minWidth: MediaQuery.of(context).size.width/2 - 24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(color: kOrangeColor, width: 2.0),
                    ),
                    onPressed: () async {
                      var options = {
                        'key': 'rzp_test_KpdQA981o8JxuY',
                        'amount': int.parse(widget.amount)*100, //in the smallest currency sub-unit.
                        'name': 'Billable',
                        'retry' : {
                          'enabled' : true,
                          'max_count' : 2,
                        },
                        'send_sms_hash': true,
                        // 'order_id': 'order_EMBFqjDHEEn80l', // Generate order_id using Orders API
                        'description': 'Complete order',
                        'timeout': 60, // in seconds
                      };
                      _razorpay.open(options);
                    },
                    child: const Text("Pay"),
                  ),
                ],
              ),
            ),
            // MaterialButton(
            //     onPressed: () async {
            //   String here = await NetworkHelper(context: context).getData(int.parse(widget.amount), getRandom().toString());
            //   ScaffoldMessenger.of(context).showSnackBar(
            //                 SnackBar(
            //                   content: Text(here),
            //                   duration: const Duration(milliseconds: 400),
            //             ));
            // },
            //   child: const Text("Get order id"),
            // ),
            // MaterialButton(
            //   onPressed: () async {
            //     var options = {
            //       'key': 'rzp_test_KpdQA981o8JxuY',
            //       'amount': int.parse(widget.amount)*100, //in the smallest currency sub-unit.
            //       'name': 'Billable',
            //       'retry' : {
            //         'enabled' : true,
            //         'max_count' : 2,
            //       },
            //       'send_sms_hash': true,
            //       // 'order_id': 'order_EMBFqjDHEEn80l', // Generate order_id using Orders API
            //       'description': 'Complete order',
            //       'timeout': 60, // in seconds
            //     };
            //     _razorpay.open(options);
            //   },
            //   child: Text("Make payment"),
            // ),
          ],
        )
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {

    ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Payment successful."),
                    duration: Duration(milliseconds: 3000),
              ));

    CollectionReference _ref = FirebaseFirestore.instance.collection("Orders");
    var productMap = widget.productList.map((e){
      return{
        "name": e.name,
        "price": e.price.toString(),
      };
    }).toList();
    _ref.doc().set({
      "amount": widget.amount,
      "payment": "successful",
      "products": productMap,
      "name": widget.name,
      "number": widget.number,
    }).then((value) => {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(check: false)),
      )
    });


  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                    content: Text("Error: ${response.message}"),
                    duration: const Duration(milliseconds: 2000),
              ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

}

// ignore: must_be_immutable
class TextWidget extends StatelessWidget {
  TextWidget({Key? key, required this.string, required this.price}) : super(key: key);

  String string;
  String price;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(string),
        trailing: Text("₹ $price"),
      ),
    );
  }
}


