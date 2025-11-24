import 'package:flutter/material.dart';
import 'package:gym_manager/const/colors.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColor.mainColor,
        strokeWidth: 6,
      ),
    );
  }
}
