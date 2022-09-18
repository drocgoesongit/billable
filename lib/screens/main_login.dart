import 'package:billable/const.dart';
import 'package:billable/database/authentication.dart';
import 'package:billable/screens/home.dart';
import 'package:billable/screens/register_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';


class MainLogin extends StatefulWidget {
  const MainLogin({Key? key}) : super(key: key);

  @override
  State<MainLogin> createState() => _MainLoginState();
}

class _MainLoginState extends State<MainLogin> {
  final _formKey = GlobalKey<FormState>();
  var rememberValue = false;
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 16.0),
              child: Container(
                width: double.infinity,
                alignment: Alignment.topLeft,
                child: const Text("Operator \nLogin",
                style: kExtraLargeTitleDark,),
              ),
            ),
        Expanded(child: Container(
          child: Image.asset("assets/images/login.png"),
        )),
        Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  onChanged: (value) => email = value,
                  validator: (value) => EmailValidator.validate(value!)
                      ? null
                      : "Please enter a valid email",
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon  : const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
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
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: MaterialButton(
                  color: kOrangeColor,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      signInWithEmailPassword(email, password);
                      try {
                        User? user =
                            await signInWithEmailPassword(email, password);
                        if (user != null) {
                          print(user.email.toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen(check: false))
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Can't log in right now."),
                                          duration: Duration(milliseconds: 400),
                                    ));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        duration: Duration(milliseconds: 4000),
                                  ));
                      }
                    }
                  },
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  elevation: 5.0,
                  minWidth: double.infinity,
                  padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                  child: const Text(
                    'Sign in',
                    style: kButtonFontWhite
                  ),
                ),
              ),
              const SizedBox(
                height: 17,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not registered yet?', style: kSmallTextDark,),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const RegisterMain(),
                        ),
                      );
                    },
                    child: const Text('Create an account', style: kSmallTextBoldDark, ),
                  ),
                ],
              ),
            ],
          ),
        ),
            const SizedBox(
              height: 30.0,
            )
        ],
        ),
      ),
    );
  }
}
