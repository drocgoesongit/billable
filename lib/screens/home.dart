import 'package:billable/const.dart';
import 'package:billable/main.dart';
import 'package:billable/screens/customer_register.dart';
import 'package:billable/screens/main_login.dart';
import 'package:billable/utilities/customer_register_util.dart';
import 'package:billable/utilities/productsList.dart';
import 'package:billable/utilities/transactionList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

bool _isVisible = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp ( MaterialApp(
    theme: ThemeData(
        fontFamily: "Poppins",
        primarySwatch: Colors.orange,
        buttonTheme: const  ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        )
    ),
    home: HomeScreen(check: false,)
  ) );
}

class HomePage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    List<String> activeCarts = [];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: HomeScreen(check: false,),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.blue,
        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CustomerLogin()),
          );
        },
        child: const Icon(
          Icons.add_shopping_cart_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {

  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed:  () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
    child: Text("Ok"),
    onPressed:  () {
      FirebaseAuth.instance.signOut().then((value) => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Operator logged out"),
                      duration: Duration(milliseconds: 4000),
                )));
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Log out"),
    content: Text("Do you want to log out of your operator account."),
    actions: [
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class HomeScreen extends StatefulWidget {
  HomeScreen({required this.check});
  bool check;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _product = FirebaseFirestore.instance.collection("Products");
  bool _isVisible = true;
  String orders = "1";
  String customers = "1";

  void checkForAlreadyLoggedIN() async {
    if(await FirebaseAuth.instance.currentUser != null){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User already logged in."),
            duration: Duration(milliseconds: 400),
          ));
    }else{
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainLogin()),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkForAlreadyLoggedIN();
    getData();
  }

  void getData() async {
    CollectionReference _ref = FirebaseFirestore.instance.collection("Orders");
    CollectionReference _refuser = FirebaseFirestore.instance.collection("Users");

    var dataOrders;

    try{
      await _ref.get().then((doc) {
        dataOrders = doc.size.toString();
      });
      var numberOFUsers;
      await _refuser.get().then((doc) {
        numberOFUsers =  doc.size.toString();
        updateState(dataOrders, numberOFUsers);
      });
    }catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      duration: Duration(milliseconds: 4000),
                ));
    }
  }

  void updateState(String numberOrders, String numberUsers){
    setState(() {
      orders = numberOrders;
      customers = numberUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          },
          child: const Icon(
            Icons.add_shopping_cart,
            color: kDarkBlue,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SafeArea(
              child: Column(
                children: [
                  Dashboard(customers: customers, orders: orders,),
                  const SizedBox(
                    height: 32.0,
                  ),
                  // OngoingTransactions(),
                  SizedBox(
                    height: 16.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Container(
                        width: double.infinity,
                        alignment: Alignment.topLeft,
                        child: const Text("Products",
                        )
                    ),
                  ),
                  ProductsList(),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextButton(onPressed: () {
                    showAlertDialog(context);
                  },
                      child: const Text(
                        "Logout",
                        style: kSmallTextBoldOrange,
                      ))
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
 Dashboard({required this.customers, required this.orders});

  String orders;
  String customers;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 16.0),
          width: double.infinity,
          alignment: Alignment.topLeft,
          child: const Text(
            "Dashboard",
            style: kExtraLargeTitleDark,
          ),
        ),
        const SizedBox(
          height: 16.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width/2-24,
              width: MediaQuery.of(context).size.width/2-24,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: kLightGray,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Center(
                      child: Text(
                        orders,
                        style: kDashboardNumber,
                      ),
                    )),
                    const Padding(
                      padding:  EdgeInsets.only(bottom: 16.0),
                      child:  Text(
                        "Orders",
                        style: kSmallTextBoldDark,
                      ),
                    ),
                  ],
                ),
            ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width/2-24,
              width: MediaQuery.of(context).size.width/2-24,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: kLightGray,
                ),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Center(
                      child: Text(
                        customers,
                        style: kDashboardNumber,
                      ),
                    )),
                    const Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: const Text(
                        "Customers",
                        style: kSmallTextBoldDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        )
      ],
    );
  }
}

class OngoingTransactions extends StatelessWidget {
  const OngoingTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Container(
              width: double.infinity,
              alignment: Alignment.topLeft,
              child: const Text("Unprocessed cart",
              )
          ),
        ),
        Visibility(
          child: TransactionList(),
        ),
      ],
    );
  }
}


