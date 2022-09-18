import 'dart:convert';

import 'package:billable/models/products.dart';
import 'package:billable/screens/home.dart';
import 'package:billable/screens/payment.dart';
import 'package:billable/utilities/separation_text.dart';
import 'package:billable/utilities/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class UnfinishedCart extends StatefulWidget {
  const UnfinishedCart({Key? key}) : super(key: key);

  @override
  State<UnfinishedCart> createState() => _UnfinishedCartState();
}

class _UnfinishedCartState extends State<UnfinishedCart> {
  String _scanBarcode = 'Unknown';
  List<Widget> listOfItems = [];
  List<String> itemsAdded = [];
  List<Product> products = [];
  final formatCurrency = NumberFormat.currency( symbol: '₹ ', locale: "HI",);
  int total = 0;
  final CollectionReference _reference = FirebaseFirestore.instance.collection("Products");
  final CollectionReference _pausedTransactionReference = FirebaseFirestore.instance.collection("OngoingTransaction");

  // -------------- single barcode event listener ------------------ //
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      _scanBarcode = barcodeScanRes;
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    _scanBarcode = barcodeScanRes;
    if(_scanBarcode != "-1" && !itemsAdded.contains(_scanBarcode)){
      var data;
      await _reference.doc(_scanBarcode).get().then((doc) {
        data = doc.data();
        var name = data['name'];
        var price = data['price'];
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("inside set state in get read method"),
                duration: Duration(milliseconds: 400),
              ));
          listOfItems.add(TextWidget(string: name, price: price.toString()));
          itemsAdded.add(_scanBarcode);
          products.add(Product(name: name, price: int.parse(price.toString())));
          total += int.parse(price.toString());
          scanBarcodeNormal();
        });
      }).
      catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Can't find element. ${error.toString()}"),
            duration: Duration(milliseconds: 3000),
          )));
    }


  }
  
  void getData() async {
    ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("getdata called"),
                    duration: Duration(milliseconds: 400),
              ));
    var data;
    try{
      CollectionReference _ref = FirebaseFirestore.instance.collection("OngoingTransaction");
      await _ref.doc(FirebaseAuth.instance.currentUser!.uid.toString()).get().then(
              (doc) {
            data = doc.data();
            var productList = data['products'];
            var list = productList.map(
                (json) => Product.fromJson(json)
            ).toList();
            setData(list);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(list.toString()),
                  duration: Duration(milliseconds: 5000),
                ));

          }
      );
    }catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      duration: Duration(milliseconds: 4000),
                ));
    }
  }

  void setData(List<Product> list) {

    setState(() {
      for(int i=0; i<list.length; i++){
        listOfItems.add(TextWidget(string: list[i].name, price: list[i].price.toString()));
      }
  });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: <Color>[
                CustomTheme.loginGradientStart,
                CustomTheme.loginGradientEnd
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 1.0),
              stops: <double>[0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding:  EdgeInsets.all(16.0),
                child: Text(
                  "Unfinished Cart",
                  style:  TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SeparationText(text: "Products"),
              const SizedBox(
                height: 10.0,
              ),
              Expanded(
                child:
                ListView.builder(itemBuilder: (context, index) {
                  return listOfItems[index];
                },
                  itemCount: listOfItems.length,
                ),

              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text(
                      "Total:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    Expanded(child: Container()),
                    Text(
                      "[${formatCurrency.format(total)}]",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  MaterialButton(
                    height: 80,
                    onPressed: ()  {
                      getData();
                    },
                    child: const Text("Pause"),
                  ),
                  MaterialButton(
                    height: 80,
                    onPressed: () {
                      scanBarcodeNormal();
                    },
                    child: const Text("Scan"),
                  ),
                  MaterialButton(
                    height: 80,
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => Payment(amount: total.toString(), productList: products,)),
                      // );
                    },
                    child: const Text("Proceed"),
                  ),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  TextWidget({required this.string, required this.price});

  String string;
  String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Text(
              string,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0
              )
          ),
          const Expanded(
            child:  SizedBox(
              width: 20.0,
            ),
          ),
          Text(
              price,
              style: const TextStyle(
                color: Colors.black,
              )
          )

        ],
      ),
    );
  }
}