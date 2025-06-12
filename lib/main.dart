import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_config/smartConfig.dart';
import 'package:permission_handler/permission_handler.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
 await requestAllPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xff374a65),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Montserrat',
            textTheme: Typography.englishLike2018.apply(
              fontSizeFactor: 1.sp,
              bodyColor: const Color(0xff374a65),
              displayColor: const Color(0xff374a65),
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.black,
              secondary: const Color(0xff374a65),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff374a65),
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 16.sp),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff374a65),
                textStyle: TextStyle(fontSize: 14.sp),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff374a65),
                side: const BorderSide(color: Color(0xff374a65)),
                textStyle: TextStyle(fontSize: 14.sp),
              ),
            ),
            iconTheme: IconThemeData(
              color: Colors.black,
              size: 24.sp,
            ),
          ),
          home: child,
        );
      },
      child:  SplashScreen(),
    );
  }
}


Future<void> requestAllPermissions() async {
  final permissions = [
    Permission.location,
  ];

  final statuses = await permissions.request();

  statuses.forEach((permission, status) {
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  });
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    print("object");
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SmartConfig()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/applogo.png', width: 200, height: 200),
      ),
    );
  }
}
