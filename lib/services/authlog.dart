import 'package:flutter/material.dart';
import 'package:gym_manager/screens/homeScreen.dart';
import 'package:gym_manager/screens/login.dart';

import 'package:provider/provider.dart';
import 'package:gym_manager/view_models/login_viewmodel.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context);

    // Show loading while checking initial login status
    if (!loginVM.initialCheckDone) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Checking login status...'),
            ],
          ),
        ),
      );
    }

    // If user is logged in, go to home screen
    if (loginVM.isLoggedIn) {
      return HomeScreen();
    }

    // Otherwise, show login screen
    return LoginScreen();
  }
}
