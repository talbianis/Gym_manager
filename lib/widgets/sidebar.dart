import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/screens/expired_client.dart';
import 'package:gym_manager/screens/vipScreen.dart';
import '../screens/clients_screen.dart';
import '../screens/revenue_screen.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      child: Stack(
        children: [
          // Background Image
          Container(
            width: 200.w,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 27, 25, 80),
              image: DecorationImage(
                alignment: AlignmentDirectional(-0.5, 1),
                image: AssetImage('assets/images/ali.jpg'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
          ),

          // Your existing content
          Container(
            width: 200.w,
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 150.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 40.sp,
                      color: AppColor.whitecolor,
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
                SizedBox(height: 50.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(180.w, 50.h),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ClientsScreen()),
                    );
                  },
                  child: const Text(
                    "Clients",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 20.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(180.w, 50.h),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RevenueScreen()),
                    );
                  },
                  child: Text(
                    "Daily Revenue",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(180.w, 50.h),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ExpiredClientsScreen()),
                    );
                  },
                  child: const Text(
                    "Expired Clients",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

                SizedBox(height: 20.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(180.w, 50.h),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VipClientsScreen()),
                    );
                  },
                  child: Text(
                    'VIP Clients',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ),

                const Spacer(),
                Text(
                  'By Talbi Anis',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
