import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_flutter/services/cart_services.dart';
import 'package:grocery_app_flutter/widgets/cart/cart_card.dart';

class CartList extends StatefulWidget {
  final DocumentSnapshot document;
  CartList({this.document});


  @override
  _CartListState createState() => _CartListState();
}

class _CartListState extends State<CartList> {

  CartServices _cart  = CartServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _cart.cart.doc(_cart.user.uid).collection('products').snapshots( ),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Đã xảy ra sự cố');
        }

        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
        }

        return new ListView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return new CartCard(document: document,);
          }).toList(),
        );
      },
    );
  }
}
