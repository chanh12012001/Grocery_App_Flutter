import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app_flutter/constants.dart';
import 'package:grocery_app_flutter/providers/auth_provider.dart';
import 'package:grocery_app_flutter/providers/location_provider.dart';
import 'package:grocery_app_flutter/screens/map_screen.dart';
import 'package:grocery_app_flutter/screens/my_orders_screen.dart';
import 'package:grocery_app_flutter/screens/payment/credit_card_list.dart';
import 'package:grocery_app_flutter/screens/profile_update_screen.dart';
import 'package:grocery_app_flutter/screens/welcome_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  static const String id = 'profile-screen';

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthProvider>(context);
    var locationData = Provider.of<LocationProvider>(context);
    User user = FirebaseAuth.instance.currentUser;
    userDetails.getUserDetails();
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'CN-Store',
          style: TextStyle(color: kTextBlackColor),
        ),
      ),
      body: userDetails.snapshot == null ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'TÀI KHOẢN CỦA TÔI',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  color: Color(0xFF0971B6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                userDetails.snapshot.data()['firstName'][0],
                                style: TextStyle(fontSize: 50, color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userDetails.snapshot.data()['firstName'] != null
                                        ? '${userDetails.snapshot.data()['firstName']} ${userDetails.snapshot.data()['lastName']}'
                                        : 'Cập nhật tên của bạn',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if(userDetails.snapshot.data()['email'] != null) //other wise hide
                                    Text(
                                      '${userDetails.snapshot.data()['email']}',
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  Text(
                                    user.phoneNumber,
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (userDetails.snapshot != null)
                          ListTile(
                            tileColor: Colors.white,
                            leading: Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                            title:
                            Text(userDetails.snapshot.data()['location']),
                            subtitle: Text(
                              userDetails.snapshot.data()['address'],
                              maxLines: 1,
                            ),
                            trailing: SizedBox(
                              width: 80,
                              child: OutlineButton(
                                borderSide: BorderSide(color: Colors.white),
                                child: Text(
                                  'Đổi',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  EasyLoading.show(status: 'Vui lòng đợi...');
                                  locationData.getCurrentPosition().then((value) {
                                    if (value != null) {
                                      EasyLoading.dismiss();
                                      pushNewScreenWithRouteSettings(
                                        context,
                                        settings:
                                        RouteSettings(name: MapScreen.id),
                                        screen: MapScreen(),
                                        withNavBar: false,
                                        pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                      );
                                    } else {
                                      EasyLoading.dismiss();
                                      print('Không cho phép quyền truy cập');
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 10.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      pushNewScreenWithRouteSettings(
                        context,
                        settings: RouteSettings(name: UpdateProfile.id),
                        screen: UpdateProfile(),
                        withNavBar: false,
                        pageTransitionAnimation:
                        PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                )
              ],
            ),
            ListTile(
              onTap: (){
                pushNewScreenWithRouteSettings(
                  context,
                  settings: RouteSettings(name: MyOrders.id),
                  screen: MyOrders(),
                  withNavBar: true,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              leading: Icon(Icons.history),
              title: Text('Đơn hàng của tôi'),
              horizontalTitleGap: 2,
            ),
            Divider(),
            ListTile(
              onTap: (){
                pushNewScreenWithRouteSettings(
                  context,
                  settings: RouteSettings(name: CreditCardList.id),
                  screen: CreditCardList(),
                  withNavBar: true,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              leading: Icon(Icons.credit_card),
              title: Text('Quản lý thẻ tín dụng'),
              horizontalTitleGap: 2,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications_none),
              title: Text('Thông báo'),
              horizontalTitleGap: 2,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.power_settings_new),
              title: Text('Đăng xuất'),
              horizontalTitleGap: 2,
              onTap: () {
                FirebaseAuth.instance.signOut();
                pushNewScreenWithRouteSettings(
                  context,
                  settings: RouteSettings(name: WelcomeScreen.id),
                  screen: WelcomeScreen(),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}