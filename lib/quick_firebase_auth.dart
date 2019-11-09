library quick_firebase_auth;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Authenticate {
  String smsCode;
  String verificationId;

  Future<void> phoneAuthentication(BuildContext context, String phoneNo, Widget redirectTo) async {
    signIn() async {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: this.verificationId,
        smsCode: this.smsCode
      );
      
      await FirebaseAuth.instance.signInWithCredential(credential).then((user) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => redirectTo));
      }).catchError((e) {
        print(e);
      });
    }

    Future<bool> smsCodeDialog(BuildContext context) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              }
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Done'),
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    if(user != null) {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => redirectTo));
                    } else {
                      Navigator.of(context).pop();
                        signIn();
                    }
                  });
                },
              )
            ],
          );
        }
      );
    }

    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsCodeDialog(context).then((value) {
        print('Signed In Successfully.');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => redirectTo));
    };

    final PhoneVerificationFailed verifiedFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNo,
      codeAutoRetrievalTimeout: autoRetrieve,
      codeSent: smsCodeSent,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifiedFailed,
    );
  }
}