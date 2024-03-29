import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_app_flutter/screens/welcome_screen.dart';
import 'package:grocery_app_flutter/services/store_services.dart';
import 'package:grocery_app_flutter/services/user_services.dart';

class StoreProvider with ChangeNotifier{
  UserServices _userServices = UserServices();
  User user = FirebaseAuth.instance.currentUser;
  var userLatitude = 0.0;
  var userLongitude = 0.0;
  String selectedStore;
  String selectedStoreId;
  DocumentSnapshot storedetails;
  String distance;
  String selectedProductCategory;
  String selectedSubCategory;


  getSelectedStore(storeDetails,distance){
    this.storedetails = storeDetails;
    this.distance = distance;
    notifyListeners();
  }

  selectedCategory(category){
    this.selectedProductCategory = category;
    notifyListeners();
  }

  selectedCategorySub(subCategory){
    this.selectedSubCategory = subCategory;
    notifyListeners();
  }

  Future<void> getUserLocationData(context) async {
    _userServices.getUserById(user.uid).then((result) {
      if (user != null) {
        this.userLatitude = result.data()['latitude'];
        this.userLongitude = result.data()['longitude'];
        notifyListeners();
      } else {
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      }
    });
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Dịch vụ định vị đã bị tắt.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Quyền cập nhật vị trí bị từ chối, chúng tôi không thể cấp quyền yêu cầu. ');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Quyền cập nhật vị trí bị từ chối (giá trị thực: $permission).');
      }
    }
    return await Geolocator.getCurrentPosition();
  }
}