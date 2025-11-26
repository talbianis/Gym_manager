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

      color: Color.fromARGB(255, 27, 25, 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 40.sp,
                color: AppColor.whitecolor,
              ),
              Text(
                ' ALI Gym ',
                style: TextStyle(fontSize: 30.sp, color: AppColor.whitecolor),
              ),
            ],
          ),
          SizedBox(height: 50.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(180.w, 50.h), // width, height
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // round corners
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
              minimumSize: Size(180.w, 50.h), // width, height
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // round corners
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
          ),

          SizedBox(height: 20.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(180.w, 50.h), // width, height
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // round corners
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
          const SizedBox(height: 250),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VipClientsScreen()),
              );
            },
            child: Text('vip Client'),
          ),
          Text(
            'By Talbi Anis',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
