import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_flutter/screens/product_details_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class ProductCard extends StatelessWidget{
  final DocumentSnapshot document;
  ProductCard(this.document);

  @override
  Widget build(BuildContext context) {

    String offer = (((document.data()['comparedPrice'] - document.data()['price'])/document.data()['comparedPrice'])*100).toStringAsFixed(1);
    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey[300])
        )
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
        child: Row(
          children: [
            Stack(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: (){
                      pushNewScreenWithRouteSettings(
                        context,
                        settings: RouteSettings(name: ProductDetailScreen.id),
                        screen: ProductDetailScreen(document: document,),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                    child: SizedBox(
                      height: 140,
                      width: 130,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                          child: Hero(
                            tag: 'product${document.data()['productName']}',
                              child: Image.network(document.data()['productImage']))),
                    ),
                  ),
                ),
                if(document.data()['comparedPrice'] > 0)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10,top: 3,bottom: 3),
                    child:
                      Text(
                        '-$offer%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(document.data()['brand'],style: TextStyle(fontSize: 10),),
                        SizedBox(height: 6,),
                        Text(document.data()['productName'],style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 6,),
                        Container(
                            width: MediaQuery.of(context).size.width-160,
                            padding: EdgeInsets.only(top: 10,bottom: 10,left: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey,
                            ),
                            child: Text(document.data()['weight'],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600]
                              ),)),
                        SizedBox(height: 6,),
                        Row(
                          children: [
                            Text('\$${document.data()['price'].toStringAsFixed(0)}',
                              style: TextStyle(fontWeight: FontWeight.bold) ,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            if(document.data()['comparedPrice']>0)
                            Text('\$${document.data()['comparedPrice'].toStringAsFixed(0)}',
                              style: TextStyle(decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 10
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width-160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Card(
                              color: Colors.red,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 30, right: 30, top: 7,bottom: 7),
                                child: Text('Add',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}