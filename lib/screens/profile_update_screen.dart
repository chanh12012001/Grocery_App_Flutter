import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app_flutter/services/user_services.dart';

class UpdateProfile extends StatefulWidget {
  static const String id = 'update-profile';

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  User user = FirebaseAuth.instance.currentUser;
  UserServices _user = UserServices();
  var firstName = TextEditingController();
  var lastName = TextEditingController();
  var mobile = TextEditingController();
  var email = TextEditingController();

  updateProfile(){
    return FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName' : firstName.text,
      'lastName' : lastName.text,
      'email' : email.text,
    });
  }

  @override
  void initState() {
    _user.getUserById(user.uid).then((value){
      if(mounted){
        setState(() {
          firstName.text = value.data()['firstName'];
          lastName.text = value.data()['lastName'];
          email.text = value.data()['email'];
          mobile.text = user.phoneNumber;
        });
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Cập nhật hồ sơ',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomSheet: InkWell(
        onTap: (){
          if(_formKey.currentState.validate()){
            EasyLoading.show(status: 'Đang cập nhật hồ sơ...');
            updateProfile().then((value){
              EasyLoading.showSuccess('Cập nhật thành công');
              Navigator.pop(context);
            });
          }
        },
        child: Container(
          width: double.infinity,
          height: 56,
          color: Colors.blueGrey[900],
          child: Center(
            child: Text(
              'Cập nhật',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: firstName,
                    decoration: InputDecoration(
                        labelText: 'Tên',
                        labelStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.zero
                    ),
                    validator: (value){
                      if(value.isEmpty){
                        return 'Vui lòng nhập tên';
                      }
                      return null;
                    },
                  ),),
                  SizedBox(width: 20,),
                  Expanded(child: TextFormField(
                    controller: lastName,
                    decoration: InputDecoration(
                        labelText: 'Họ',
                        labelStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.zero
                    ),
                    validator: (value){
                      if(value.isEmpty){
                        return 'Vui lòng nhập họ';
                      }
                      return null;
                    },
                  ),),
                ],
              ),
              SizedBox(width: 40,),
              TextFormField(
                controller: mobile,
                enabled: false,
                decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    labelStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.zero
                ),
              ),
              SizedBox(width: 40,),
              TextFormField(
                controller: email,
                decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.zero
                ),
                validator: (value){
                  if(value.isEmpty){
                    return 'Vui lòng nhập Email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}