import 'package:billable/const.dart';
import 'package:billable/models/products.dart';
import 'package:billable/screens/home.dart';
import 'package:billable/screens/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class AddProducts extends StatefulWidget {
  AddProducts({Key? key, required this.number,}) : super(key: key);
  String number;

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  String _scanBarcode = 'Unknown';
  String name = '';
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
      // ignore: invalid_return_type_for_catch_error
      catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Can't find element. ${error.toString()}"),
            duration: const Duration(milliseconds: 3000),
          )));
    }

  }

  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      getName();
    }

  void getName() async {
    CollectionReference ref = FirebaseFirestore.instance.collection("Users");
    var anotherData;

      try{
        await ref.doc(widget.number).get().then((doc) {
          anotherData = doc.data();
          var username = anotherData['first'];
          setState(() {
            name = username;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Got username"),
                duration: Duration(milliseconds: 400),
              ));
        });
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                        content: Text(e.toString()),
                        duration: Duration(milliseconds: 4000),
                  ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0),
              child: Container(
                padding: const EdgeInsets.only(top: 16.0),
                width: double.infinity,
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const Text(
                      "Add Products",
                      style: kExtraLargeTitleDark,
                    ),
                    GestureDetector(
                      onTap: () {
                        scanBarcodeNormal();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            color: kDarkBlue,
                            boxShadow: const [
                              BoxShadow(color: kDarkBlue, spreadRadius: 3),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code,
                            color: kLightGray,
                            size: 35.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),

            const SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: const Icon(
                Icons.supervised_user_circle_rounded,
                color: kDarkBlue,
              ),
              title: Text(name, style: kMediumTextDark,),
            ),
            ListTile(
              leading: const Icon(
                Icons.phone,
                color: kDarkBlue,
              ),
              title: Text("(+91) ${widget.number}", style: kMediumTextDark,),
            ),
            const SizedBox(
              height: 16.0,
            ),
            const Padding(
              padding:  EdgeInsets.only(left: 16.0 , bottom: 8.0),
              child: Text(
                "Products:",
                style: kMediumTextDark,
              ),
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
                    style: kMediumTextDark
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  const Icon(
                    Icons.info_outline,
                    color: kDarkBlue,
                  ),
                  Expanded(child: Container()),
                  Text(
                    "[${formatCurrency.format(total)}]",
                    style: kMediumTextDark
                  )
                ],
              ),
            ),
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
                    onPressed: () {
                      // var operator = FirebaseAuth.instance.currentUser!.uid.toString();
                      // var productMap = products.map((e){
                      //   return{
                      //     "name": e.name,
                      //     "price": e.price.toString(),
                      //   };
                      // }).toList();
                      // _pausedTransactionReference.doc(operator).set({
                      //   "id":widget.number,
                      //   "operator":operator,
                      //   "products": productMap
                      // }).then((value) => {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => HomeScreen(check: true)),
                      // )
                      // });
                      Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen(check: false)),
                          );
                    },
                    child: const Text("Cancel"),
                  ),
                  MaterialButton(
                    height: 65,
                    color: kOrangeColor,
                    minWidth: MediaQuery.of(context).size.width/2 - 24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(color: kOrangeColor, width: 2.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Payment(amount: total.toString(),productList: products, name: name, number: widget.number,)),
                      );
                    },
                    child: const Text("Proceed"),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
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