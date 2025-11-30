import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/screens/homeScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.mainColor, AppColor.secondcolor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,

                  backgroundImage: AssetImage('assets/images/icon_app.png'),
                  backgroundColor: Colors.blueAccent.shade100,
                ),

                SizedBox(height: 20),

                // App name
                Text(
                  "ALI Gym Manager",
                  style: TextStyle(
                    fontSize: 26,
                    color: AppColor.whitecolor,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  "Simplify your daily management",
                  style: TextStyle(fontSize: 14, color: AppColor.whitecolor),
                ),

                SizedBox(height: 35.h),

                // Loading animation
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColor.mainColor),
                  strokeWidth: 5.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
