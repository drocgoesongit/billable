import 'package:billable/utilities/customer_register_util.dart';
import 'package:flutter/material.dart';


// First we will check for customer already in the database.
// if present then we just gonna proceed with his preregistered information.
// if not present than open Registering UI and get it registered with his phone number email is optional.


class CustomerLogin extends StatelessWidget {
  const CustomerLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: LoginPage(),
    );
  }
}

