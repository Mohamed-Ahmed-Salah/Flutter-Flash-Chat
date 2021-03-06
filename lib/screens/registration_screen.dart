
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}


class _RegistrationScreenState extends State<RegistrationScreen> {
  String email, password;
  final _auth=FirebaseAuth.instance;
  bool _saving=false;
  final fieldText = TextEditingController();
  final fieldText2 = TextEditingController();

  void clearText() {
    fieldText.clear();
    fieldText2.clear();

  }
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _saving,

      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                controller: fieldText,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: fieldText2,
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Register',
                colour: Colors.blueAccent,
                onPressed: () async{
                  setState(() {
                    _saving=true;
                  });
                  print("$email   $password");
                  try {
                    final newUSer = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    print(newUSer);
                    if (newUSer != null) {

                      Navigator.pushNamed(context, ChatScreen.id);
                      setState(() {
                        _saving=false;
                        clearText();
                      });
                    }
                  }catch(e){
                    print(e);
                    setState(() {
                      _saving=false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
