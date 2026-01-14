import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:gym_manager/view_models/login_viewmodel.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      final loginVM = Provider.of<LoginViewModel>(context, listen: false);

      await loginVM.logout();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoggingOut = false);

      // Show error if logout fails
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Logout failed. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
      child: SizedBox(
        height: _isLoggingOut ? 350.h : 350.h,
        width: 300.w,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _isLoggingOut
                ? [
                    CircularProgressIndicator(color: AppColor.mainColor),
                    SizedBox(height: 20.h),
                    Text(
                      'Logging out...',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ]
                : [
                    // Icon
                    Icon(Icons.logout, size: 40.sp, color: AppColor.mainColor),

                    // Title
                    Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 36, 51, 65),
                      ),
                    ),

                    // Message
                    SizedBox(height: 4.h),
                    Text(
                      "Are you sure you want to logout from your account?",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 8.h),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel Button
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColor.mainColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: AppColor.mainColor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Logout Button
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: ElevatedButton(
                              onPressed: _handleLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
