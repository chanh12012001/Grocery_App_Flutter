import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_flutter/constants.dart';
import 'package:grocery_app_flutter/providers/order_provider.dart';
import 'package:grocery_app_flutter/services/order_services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyOrders extends StatefulWidget {
  static const String id = 'my-orders';
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  OrderServices _orderServices = OrderServices();
  User user = FirebaseAuth.instance.currentUser;

  int tag = 0;
  List<String> options = [
    'Tất cả',
    'Đã đặt hàng',
    'Đã chấp nhận',
    'Đang lấy hàng',
    'Đang giao hàng',
    'Đã giao hàng',
  ];

  @override
  Widget build(BuildContext context) {
    var _orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Đơn hàng của tôi',
          style: TextStyle(color: kTextBlackColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.search,
              color: kTextBlackColor,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              choiceStyle: C2ChoiceStyle(borderRadius: BorderRadius.all(Radius.circular(3))),
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    _orderProvider.status = null;
                  });
                }
                setState(() {
                  tag = val;
                  _orderProvider.status = options[val];
                });
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.orders
                  .where('userId', isEqualTo: user.uid)
                  .where('orderStatus', isEqualTo: tag > 0 ? _orderProvider.status : null)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Đã xảy ra sự cố');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data.size == 0) {
                  //TODO: No orders screen
                  return Center(
                    child: Text(tag > 0
                        ? 'Không có đơn hàng ${options[tag]}'
                        : 'Không có đơn đặt hàng. Tiếp tục mua sắm'),
                  );
                }

                return Expanded(
                  child: new ListView(
                    children:
                    snapshot.data.docs.map((DocumentSnapshot document) {
                      return new Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                              horizontalTitleGap: 0,
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 14,
                                child: _orderServices.statusIcon(document),
                              ),
                              title: Text(
                                document.data()['orderStatus'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _orderServices.statusColor(document),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'On ${DateFormat.yMMMd().format(DateTime.parse(document.data()['timestamp']))}',
                                style: TextStyle(fontSize: 12),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Phương thức thanh toán : ${document.data()['cod'] == true
                                        ? 'Thanh toán khi nhận hàng'
                                        : 'Thanh toán trực tuyến'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Tổng: ${document.data()['total'].toStringAsFixed(0)}\đ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if(document.data()['deliveryBoy']['name'].length > 2)
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: ListTile(
                                    tileColor: Theme.of(context).primaryColor.withOpacity(.2),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Image.network(
                                        document.data()['deliveryBoy']['image'],
                                        height: 24,
                                      ),
                                    ),
                                    title: Text(
                                      document.data()['deliveryBoy']['name'],
                                      style:TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      _orderServices.statusComment(document),
                                      style:TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            ExpansionTile(
                              title: Text(
                                'Chi tiết đơn hàng',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                'Xem chi tiết đơn hàng',
                                style:
                                TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (BuildContext context, int index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Image.network(
                                            document.data()['products'][index]['productImage']),
                                      ),
                                      title: Text(
                                        document.data()['products'][index]['productName'],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      subtitle: Text(
                                        '${document.data()['products'][index]['qty']} x ${document.data()['products'][index]['price'].toStringAsFixed(0)}\đ = ${document.data()['products'][index]['total'].toStringAsFixed(0)}\đ',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: document.data()['products'].length,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                                  child: Card(
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text('Người bán: ',
                                                style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                document.data()['seller']['shopName'],
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          if (int.parse(
                                              document.data()['discount']) > 0)
                                            Container(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Giảm giá: ',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${document.data()['discount']}',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Mã giảm giá: ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${document.data()['discountCode']}',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Phí vận chuyển: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                '${document.data()['deliveryFee'].toString()}\đ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              height: 3,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}