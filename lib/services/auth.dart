import 'package:chat/helper_functions/sharedpref_helper.dart';
import 'package:chat/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() {
    return auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User userDetails = result.user;

    if (result != null) {
      SharedPreferencesHelper().saveUserEmail(userDetails.email);
      SharedPreferencesHelper().saveUserId(userDetails.uid);
      SharedPreferencesHelper().saveDisplayName(userDetails.displayName);
      SharedPreferencesHelper().saveUserProfileUrl(userDetails.photoURL);

      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "username": userDetails.email.replaceAll("@gmail.com", ""),
        "imgUrl": userDetails.photoURL,
        "name" : userDetails.displayName,
      };

      DatabaseMethods().addUserInfoToDB(userDetails.uid, userInfoMap).then{
        (value){
          Navigator.pushReplacement(context, newRoute)
        };
      }
    }
  }
}
