import 'package:flutter/material.dart';
import 'package:grocery_app_flutter/providers/cart_provider.dart';
import 'package:grocery_app_flutter/screens/cart_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class CartNotification extends StatefulWidget {
  @override
  _CartNotificationState createState() => _CartNotificationState();
}

class _CartNotificationState extends State<CartNotification> {

  @override
  Widget build(BuildContext context) {
    final _cartProvider = Provider.of<CartProvider>(context);
    _cartProvider.getCartTotal();
    _cartProvider.getShopName();

    return _cartProvider.cartQty==0 ? Container() : _cartProvider.distance < 10.0 ? Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft:Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${_cartProvider.cartQty}${_cartProvider.cartQty == 1 ? ' Item' : ' Items' }',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('  |  ', style: TextStyle(color: Colors.white),),
                      Text('${_cartProvider.subTotal.toStringAsFixed(0)}\đ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if(_cartProvider.document!=null)
                    Text(
                      'Từ ${_cartProvider.document.data()['shopName']}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    )
                ],
              ),
            ),
            InkWell(
              onTap: () {
                pushNewScreenWithRouteSettings(
                  context,
                  settings: RouteSettings(name: CartScreen.id),
                  screen: CartScreen(
                    document: _cartProvider.document,
                  ),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: Container(
                child: Row(
                  children: [
                    Text(
                      'Xem giỏ hàng',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5,),
                    Icon(Icons.shopping_bag_outlined, color: Colors.white,)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ) : Container();
  }
}
