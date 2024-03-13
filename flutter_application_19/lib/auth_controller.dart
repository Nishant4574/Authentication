import 'package:firebase/Screens/Homepage.dart';
import 'package:firebase/login_page.dart';
import 'package:firebase/signup_page.dart';
import 'package:firebase/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authcontroller extends GetxController {
  handeAuthstate() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return Signup();
          } else {
            return Welcomepage(email: "hi");
          }
        });
  }

  SignInwithgoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final Credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    return await FirebaseAuth.instance.signInWithCredential(Credential);
  }

  SignOut() {
    FirebaseAuth.instance.signOut();
  }

  static Authcontroller instance =
      Get.find(); //access the authcontroller for globally accesssible
  late Rx<User?> _user; //include user information email,password..
  FirebaseAuth auth = FirebaseAuth.instance; //navigating tpo differnt pages
  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser); //user feature and keep the track
    _user.bindStream(auth
        .userChanges()); //thing changes like login,logout user will be notififed
    ever(_user, _inititalScreen); //listening ever changes at the the time
  }

  _inititalScreen(User? user) {
    if (user == null) {
      print("Login page");
      Get.offAll(() => Loginpage()); //if user has login
    } else {
      Get.offAll(() => Homepage()); //if user has not login
    }
  }

  void register(String email, password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      Get.snackbar("About user", "User message",
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: Text("Account creation failed"),
          messageText: Text(
            e.toString(),
            style: TextStyle(color: Colors.white),
          ));
    }
  }

  void login(String email, password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("About Login", "Login message",
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: Text("Login failed"),
          messageText: Text(
            e.toString(),
            style: TextStyle(color: Colors.white),
          ));
    }
  }

  void logout() async {
    await auth.signOut();
  }
}
