// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:help_find_the_missing/constants/constants.dart';
import 'package:help_find_the_missing/screens/home_screen.dart';
import 'package:help_find_the_missing/my_widgets/loading_widget.dart';
import 'package:help_find_the_missing/my_widgets/my_label_widget.dart';
import 'package:help_find_the_missing/my_widgets/my_alert_dialog.dart';
import 'package:help_find_the_missing/my_widgets/my_elevated_button.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.initialIndex});

  final int initialIndex;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _numberController = TextEditingController();
  final _codeController = TextEditingController();

  bool isLoading = false;

  Future registerUser(
      String mobile, String fullName, double w, BuildContext context) async {
    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: const Duration(minutes: 2),
        verificationCompleted: (AuthCredential authCredential) {
          _auth
              .signInWithCredential(authCredential)
              .then((UserCredential userCredential) {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  name: fullName,
                ),
              ),
            );
            _fullNameController.clear();
            _numberController.clear();
          }).catchError((e) {
            print(e);
          });
        },
        verificationFailed: (FirebaseAuthException authException) {
          print(authException.message);
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          setState(() {
            isLoading = false;
          });
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Center(
                child: Text('Enter OTP'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    textAlign: TextAlign.center,
                    controller: _codeController,
                    style: const TextStyle(
                      letterSpacing: 2.0,
                      fontSize: 24.0,
                    ),
                    // decoration: kTextFieldDecoration,
                  ),
                ],
              ),
              titlePadding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              contentPadding: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              actions: [
                Center(
                  child: MyElevatedButton(
                    onPress: () {
                      var smsCode = _codeController.text.trim();
                      PhoneAuthCredential authCredential =
                          PhoneAuthProvider.credential(
                              verificationId: verificationId, smsCode: smsCode);
                      _auth
                          .signInWithCredential(authCredential)
                          .then((UserCredential userCredential) {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              name: fullName,
                            ),
                          ),
                        );
                        _fullNameController.clear();
                        _numberController.clear();
                      }).catchError(
                        (e) {
                          print(e);
                          Navigator.of(ctx).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => MyAlertDialog(
                              title: 'OTP Error',
                              content: e.toString(),
                            ),
                          );
                        },
                      );
                    },
                    buttonLabel: const Text(
                      'Submit',
                      style: kButtonTextStyle,
                    ),
                    w: w / 2,
                  ),
                ),
              ],
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timeout");
        });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          DefaultTabController(
            length: 2,
            initialIndex: widget.initialIndex,
            child: Column(
              children: [
                const TabBar(
                  indicatorColor: themeColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  labelColor: themeColor,
                  unselectedLabelColor: Color(0xff89909E),
                  tabs: <Tab>[
                    Tab(
                      text: 'Login',
                    ),
                    Tab(
                      text: 'Guest User',
                    ),
                  ],
                ),
                SizedBox(
                  height: 250,
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            const MyLabelWidget(labelName: 'Email Address'),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Enter your Email Address',
                              ),
                            ),
                            const MyLabelWidget(labelName: 'Password'),
                            TextField(
                              controller: _passwordController,
                              autocorrect: false,
                              obscureText: true,
                              enableSuggestions: false,
                              decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Password',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: MyElevatedButton(
                                onPress: () async {
                                  if (isLoading) return;

                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    await _auth.signInWithEmailAndPassword(
                                        email: _emailController.text,
                                        password: _passwordController.text);
                                    print("Successfully Logged In");
                                    _emailController.clear();
                                    _passwordController.clear();
                                    Navigator.of(context).pop();
                                    Navigator.pushNamed(context, HomeScreen.id);
                                  } catch (e) {
                                    print(e);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          MyAlertDialog(
                                        title: 'Login Error',
                                        content: e.toString(),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                buttonLabel: (!isLoading)
                                    ? const Text(
                                        'Authenticate',
                                        style: kButtonTextStyle,
                                      )
                                    : const LoadingWidget(
                                        newText: 'Logging in',
                                      ),
                                w: w,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyLabelWidget(labelName: 'Full Name'),
                            TextField(
                              keyboardType: TextInputType.name,
                              controller: _fullNameController,
                              decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Full Name',
                              ),
                            ),
                            const MyLabelWidget(labelName: 'Contact Number'),
                            TextField(
                              maxLength: 10,
                              keyboardType: TextInputType.phone,
                              controller: _numberController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Contact Number',
                              ),
                            ),
                            Center(
                              child: MyElevatedButton(
                                onPress: () async {
                                  if (isLoading) return;

                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    if (_fullNameController.text.isEmpty) {
                                      throw "Name Field cannot be empty";
                                    }
                                    if (_numberController.text.length != 10) {
                                      throw "Incorrect number";
                                    }
                                    var mobile = '+91' + _numberController.text;
                                    String name = _fullNameController.text;
                                    await registerUser(
                                        mobile, name, w, context);
                                  } catch (e) {
                                    print(e);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          MyAlertDialog(
                                        title: 'Login Error',
                                        content: e.toString(),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                buttonLabel: (!isLoading)
                                    ? Text(
                                        'Send OTP',
                                        style: kButtonTextStyle.copyWith(
                                            color: themeColor),
                                      )
                                    : const LoadingWidget(
                                        newText: 'Sending OTP',
                                        progressColor: themeColor,
                                      ),
                                w: w,
                                buttonColor: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
