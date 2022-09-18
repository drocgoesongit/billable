import 'package:billable/const.dart';
import 'package:billable/screens/unfinished_cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final CollectionReference transactionReference = FirebaseFirestore.instance.collection("OngoingTransaction");

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: transactionReference.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot,) {
          if(streamSnapshot.hasData){
            return ListView.builder(
              shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index){
                  var number = index+1;
                  var position = number.toString();
                  final DocumentSnapshot document = streamSnapshot.data!.docs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UnfinishedCart()),
                      );
                    },
                    child: Card(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      margin: const EdgeInsets.all(10.0),
                      child: ListTile(
                        title: Text(document['id'], style: kMediumTextDark,),
                        subtitle: const Text("Paused cart", style: kSmallTextDark,),
                        trailing: const Icon(
                          Icons.pause_circle,
                          color: kDarkBlue,
                        ),
                      ),
                    ),
                  );
                });
          }
          else{
            return const Center(
              child: Text("No paused carts"),
            );
          }
        }
    );
  }
}
