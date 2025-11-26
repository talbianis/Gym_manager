import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/screens/homeScreen.dart';
import 'package:gym_manager/view_models/client_viewmodel.dart';
import 'package:gym_manager/view_models/reveniew_viewmodel.dart';
import 'package:gym_manager/view_models/vip_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize DB for Windows Desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClientViewModel()),
        ChangeNotifierProvider(create: (_) => RevenueViewModel()),
        ChangeNotifierProvider(create: (_) => VipClientViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1366, 768),

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Gym Manager",

        home: HomeScreen(),
      ),
    );
  }
}
