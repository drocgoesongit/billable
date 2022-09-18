import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const api_key = "rzp_test_KpdQA981o8JxuY";
const secret_key = "f83yG1oBXrrqGX72I95DhWjJ";

class NetworkHelper{
  NetworkHelper({required this.context});
  BuildContext context;

  Future getData(int amount, String receiptNumber) async {
    String url = "https://api.razorpay.com/v1/orders";
    final jsonData = {
      "amount": 100000,
      "currency": "INR",
      "receipt": "Receipt no. 1",
      "notes": {
        "notes_key_1": "Tea, Earl Grey, Hot",
        "notes_key_2": "Tea, Earl Grey… decaf."
      }
    };
    final jsonBody = json.encode(jsonData);

    String basicAuth =
        'Basic ${base64.encode(utf8.encode('$api_key:$secret_key'))}';

    ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text(basicAuth),
                    duration: Duration(milliseconds: 400),
              ));
    http.Response response = await http.post(Uri.parse(url), headers: {'authorization': basicAuth, 'Content-type': "application/json",}, body:jsonBody);
    var body = response.body;
    var data = jsonDecode(body);



    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("positive output"),
            duration: Duration(milliseconds: 1000),
          ));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body.toString()),
            duration: Duration(milliseconds: 10000),
          ));
    }

    // try{
    //
    // }catch(e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(
    //                   content: Text(e.toString()),
    //                   duration: const Duration(milliseconds: 4000),
    //             ));
    // }



    if(data != null){
      return data['id'];
    }else{
      return "r";
    }
  }
}