import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      myimage: Image(image: AssetImage('assets/images/app.png')),
      context,
      message,
      backgroundColor: AppColor.successcolor.shade600,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      myimage: Image(image: AssetImage('assets/images/gym.png')),
      context,
      message,
      backgroundColor: AppColor.warningcolor.shade600,
      icon: Icons.error_rounded,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      myimage: Image(image: AssetImage('assets/images/fitness.png')),
      context,
      message,
      backgroundColor: Colors.orange.shade600,
      icon: Icons.warning_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      myimage: Image(image: AssetImage('assets/images/fitness.png')),
      context,
      message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_rounded,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    required Image myimage,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20.r,
                offset: Offset(0, 4.r),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(height: 50.h, width: 50.w, child: myimage),
              // IconButton(
              //   icon: Icon(Icons.close, color: Colors.white, size: 18),
              //   onPressed: () {
              //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //   },
              // ),
            ],
          ),
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
