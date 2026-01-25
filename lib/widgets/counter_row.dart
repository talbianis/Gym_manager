import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';

class CounterRow extends StatelessWidget {
  final String label;
  final int price;
  final int count;
  final IconData? icon;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterRow({
    Key? key,
    required this.label,
    required this.price,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 90.w),
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppColor.whitecolor,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(flex: 1, child: Icon(icon, size: 20.sp)),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                "${price} DA",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),
            ),

            Expanded(
              flex: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: onDecrement,
                      icon: Icon(Icons.remove_circle),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: onIncrement,
                      icon: Icon(Icons.add_circle),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                "${count * price} DA",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
