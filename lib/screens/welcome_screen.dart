import 'package:flutter/material.dart';
import 'package:help_find_the_missing/constants.dart';
import 'package:help_find_the_missing/my_elevated_button.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const String id = 'welcomeScreen';

  @override
  Widget build(BuildContext context) {
    // final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Image(
                  image: AssetImage('images/img.png'),
                ),
              ),
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Be the change you want to see!',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const Text(
                ' Help find the missing.',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(
                height: 100.0,
              ),
              MyElevatedButton(
                onPress: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    builder: (context) => SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: const LoginScreen(
                          initialIndex: 0,
                        ),
                      ),
                    ),
                  );
                },
                buttonLabel: const Text(
                  'Login', //here
                  style: kButtonTextStyle,
                ),
                w: w,
              ),
              const SizedBox(
                height: 12.0,
              ),
              MyElevatedButton(
                onPress: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    builder: (context) => SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: const LoginScreen(
                          initialIndex: 1,
                        ),
                      ),
                    ),
                  );
                },
                buttonLabel: Text(
                  'Proceed as Guest',
                  style: kButtonTextStyle.copyWith(
                    color: themeColor,
                  ),
                ),
                w: w,
                buttonColor: greenAccent,
              ),
              const SizedBox(
                height: 12.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
