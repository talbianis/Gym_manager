import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/screens/backup_screen.dart';
import 'package:gym_manager/screens/expired_client.dart';

import 'package:gym_manager/screens/vipScreen.dart';
import 'package:gym_manager/widgets/dialogcustom.dart';

import '../screens/clients_screen.dart';
import '../screens/revenue_screen.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 200.w,
      child: Stack(
        children: [
          // Background Image
          // Container(
          //   width: 200.w,
          //   decoration: BoxDecoration(
          //     color: const Color.fromARGB(255, 3, 28, 48),
          //     image: DecorationImage(
          //       alignment: AlignmentDirectional(-0.60, 1),
          //       image: AssetImage('assets/images/ali.jpg'),
          //       fit: BoxFit.cover,
          //       opacity: 0.6,
          //     ),
          //   ),
          // ),
          Container(
            width: 200.w,
            decoration: BoxDecoration(
              color: AppColor.mainColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 150.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Icon(
                    //   Icons.fitness_center_rounded,
                    //   size: 60.sp,
                    //   color: AppColor.whitecolor,
                    // ),
                    Image(
                      image: AssetImage('assets/images/muscle.png'),
                      height: 60.h,
                      color: AppColor.whitecolor.withOpacity(0.7),
                    ),

                    Text(
                      ' ALI Gym ',
                      style: TextStyle(
                        fontSize: 30.sp,
                        color: AppColor.whitecolor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     minimumSize: Size(180.w, 50.h),
                //     backgroundColor: Colors.white,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (_) => ClientsScreen()),
                //     );
                //   },
                //   child: const Text(
                //     "Clients",
                //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                //   ),
                // ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ClientsScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.person, color: AppColor.whitecolor),
                      SizedBox(width: 10.w),
                      Text(
                        'Client',
                        style: TextStyle(
                          color: AppColor.whitecolor,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  color: AppColor.whitecolor,
                  indent: 15.w,
                  endIndent: 15.w,
                ),

                SizedBox(height: 20.h),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RevenueScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.money, color: AppColor.whitecolor),
                      SizedBox(width: 10.w),
                      Text(
                        'Daily Revenue',
                        style: TextStyle(
                          color: AppColor.whitecolor,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppColor.whitecolor,
                  indent: 15.w,
                  endIndent: 15.w,
                ),

                SizedBox(height: 20.h),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ExpiredClientsScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColor.whitecolor,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Expired Clients',
                        style: TextStyle(
                          color: AppColor.whitecolor,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppColor.whitecolor,
                  indent: 15.w,
                  endIndent: 15.w,
                ),

                SizedBox(height: 20.h),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VipClientsScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.star, color: AppColor.whitecolor),
                      SizedBox(width: 10.w),
                      Text(
                        'Vip Clients',
                        style: TextStyle(
                          color: AppColor.whitecolor,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppColor.whitecolor,
                  indent: 15.w,
                  endIndent: 15.w,
                ),
                SizedBox(height: 80.h),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => LogoutDialog(),
                    );
                  },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.logout, color: AppColor.whitecolor),
                      SizedBox(width: 10.w),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: AppColor.whitecolor,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppColor.whitecolor,
                  indent: 15.w,
                  endIndent: 15.w,
                ),

                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BackupPage()),
                    );
                  },
                  child: Text(
                    'backup & Restore',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text('V1.00', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
