import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final CollectionReference _product = FirebaseFirestore.instance.collection("Products");

class ProductsList extends StatelessWidget {
  const ProductsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _product.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if(streamSnapshot.hasData){
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index){
                  final DocumentSnapshot document = streamSnapshot.data!.docs[index];
                  return Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    margin: const EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(document['name']),
                      subtitle: Text("₹ ${document['price'].toString()}"),
                    ),
                  );
                });
          }
          else{
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }
}
