import 'package:billable/const.dart';
import 'package:billable/database/authentication.dart';
import 'package:billable/screens/home.dart';
import 'package:billable/screens/main_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class RegisterMain extends StatefulWidget {
  const RegisterMain({Key? key}) : super(key: key);

  @override
  State<RegisterMain> createState() => _RegisterMainState();
}

class _RegisterMainState extends State<RegisterMain> {
  final _formKey = GlobalKey<FormState>();
  var rememberValue = false;
  late String first;
  late String last;
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                width: double.infinity,
                alignment: Alignment.topLeft,
                child: const Text(
                  "Operator \nRegister",
                  style: kExtraLargeTitleDark,
                  ),
              ),
            ),
            Expanded(child: Container(
              child: Image.asset("assets/images/login.png"),
            )),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onChanged: (value) => first = value,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: 'First name',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextFormField(
                          onChanged: (value) => last = value,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Last name',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    onChanged: (value) => email= value,
                    validator: (value) => EmailValidator.validate(value!)
                        ? null
                        : "Please enter a valid email",
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    onChanged: (value) => password = value,
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      maxLines: 1,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    onPressed: () async {
                        try{
                          User? user = await registerWithEmailAndPassword(email, password);
                          if(user != null ){
                            print(user.email.toString());
                            CollectionReference _ref = FirebaseFirestore.instance.collection("Operator");
                            await _ref.doc(user.uid.toString()).set({
                              "first": first,
                              "last": last,
                              "email": email,
                              "password": password,
                            }).then((value) => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen(check: false)),
                            ));
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Something wrong happened."),
                                            duration: Duration(milliseconds: 4000),
                                      ));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                duration: const Duration(milliseconds: 4000),
                              ));
                        }


                    },
                    color: kOrangeColor,
                    padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    elevation: 5.0,
                    minWidth: double.infinity,
                    child: const Text(
                      'Sign up',
                      style: kButtonFontWhite,
                    ),
                  ),
                  const SizedBox(
                    height: 17,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already registered?', style: kSmallTextDark,),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const MainLogin(),
                            ),
                          );
                        },
                        child: const Text('Sign in', style: kSmallTextBoldDark,),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 32.0,
            )
          ],

          ),
        ),
      )
    );
  }
}
