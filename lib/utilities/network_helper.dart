// ignore_for_file: use_build_context_synchronously, constant_identifier_names

import 'dart:convert';
import 'package:billable/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String api_key = "rzp_test_uj5csPT8ukw8hI";
const secret_key = "MtfB8wXUS9ascCUX2elTvFi1";

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
                    duration: const Duration(milliseconds: 400),
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
            duration: const Duration(milliseconds: 10000),
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

  Future<String> sendWelcomeNotifications(String email, String name) async {
    Uri url = Uri.parse("https://api.courier.com/send");
    final jsonData =
      {
        "message": {
          "to": {
            "email": email
          },
          "template": kWelcomeTemplate,
          "data": {
            "name": name
          },
          "routing": {
            "method": "single",
            "channels": [
              "email"
            ]
          }
        }
      };
    final jsonBody = json.encode(jsonData);
    const authorization = "Bearer $kCourierApiKey";

    http.Response response = await http.post(url, headers: {'authorization': authorization, 'Content-type': "application/json",}, body:jsonBody);

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
            duration: const Duration(milliseconds: 10000),
          ));
    }
    if(data != null){
      return "s";
    }else{
      return "r";
    }

  }
  Future<String> sendThankingNotification(String email, String name) async {
    Uri url = Uri.parse("https://api.courier.com/send");
    final jsonData =
    {
      "message": {
        "to": {
          "email": email
        },
        "template": kThanksTemplate,
        "data": {
          "name": name
        },
        "routing": {
          "method": "single",
          "channels": [
            "email"
          ]
        }
      }
    };
    final jsonBody = json.encode(jsonData);
    const authorization = "Bearer $kCourierApiKey";

    http.Response response = await http.post(url, headers: {'authorization': authorization, 'Content-type': "application/json",}, body:jsonBody);

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
            duration: const Duration(milliseconds: 10000),
          ));
    }
    if(data != null){
      return "s";
    }else{
      return "r";
    }

  }
}