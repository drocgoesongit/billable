import 'package:billable/const.dart';
import 'package:billable/screens/home.dart';
import 'package:billable/screens/main_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp ( const MyApp() );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "Poppins",
        primarySwatch: Colors.orange,
        buttonTheme: const  ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        )
      ),


      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _scanBarcode = 'Unknown';
  List<Widget> listOfItems = [TextWidget(string: "unknown",)];




  @override
  void initState() {
    super.initState();
    checkForAlreadyLoggedIN();
  }

  void checkForAlreadyLoggedIN() async {
    if(await FirebaseAuth.instance.currentUser != null){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User already logged in."),
            duration: Duration(milliseconds: 400),
          ));
  }
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(check: false,) ));
                },
              color: Colors.blueAccent,
              child: const Text("Start Scanning"),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MainLogin() ));
              },
              color: Colors.blueAccent,
              child: const Text("Login", style: kButtonFontWhite,),
            ),
            TextWidget(string: _scanBarcode),
            Expanded(
              child: ListView.builder(itemBuilder: (context, index) {
                return listOfItems[index];
              },
              itemCount: listOfItems.length,),
            )
          ],
        )

      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  TextWidget({required this.string});

  String string;

  @override
  Widget build(BuildContext context) {
    return Text(
        string,
        style: const TextStyle(
          color: Colors.grey,
        )
    );
  }
}
