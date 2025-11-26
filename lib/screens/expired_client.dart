import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_models/client_viewmodel.dart';

class ExpiredClientsScreen extends StatelessWidget {
  const ExpiredClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.whitecolor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Expired Clients",
          style: TextStyle(color: AppColor.whitecolor),
        ),
        backgroundColor: AppColor.mainColor,
      ),

      body: Consumer<ClientViewModel>(
        builder: (context, vm, child) {
          final expired = vm.expiredClients;

          if (expired.isEmpty) {
            return Center(
              child: Text(
                "No expired clients.",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: expired.length,
            itemBuilder: (context, index) {
              final c = expired[index];

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: Colors.red.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: Colors.red,
                          size: 30.sp,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Text Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6.h),

                            // Status Tag
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                "Expired",
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            SizedBox(height: 6.h),

                            Text("Phone: ${c.phone}"),
                            Text(
                              "Expired on: ${DateFormat('yyyy-MM-dd').format(c.endDate)}",
                            ),
                          ],
                        ),
                      ),

                      // Warning Icon
                      Column(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 30.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
