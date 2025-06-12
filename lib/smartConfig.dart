import 'dart:async';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'configLoading.dart';

class SmartConfig extends StatefulWidget {
  const SmartConfig({Key? key}) : super(key: key);

  @override
  _SmartConfigState createState() => _SmartConfigState();
}

class _SmartConfigState extends State<SmartConfig> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController bssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool fetchingWifiInfo = false;
  bool isSsid = true;
  bool isBssid = true;
  bool isPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void onConfigurePressed() {
    final ssid = ssidController.text.trim();
    final bssid = bssidController.text.trim();
    final password = passwordController.text.trim();

    if (ssid.isEmpty || bssid.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("All fields are required")));
      return;
    }

    // Proceed with smart config logic
    print("Configuring with SSID: $ssid, BSSID: $bssid, Password: $password");
  }

  @override
  void initState() {
    fetchWifiInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFA098),
                Color(0xFFFFCDD2),
                Color(0xFFFFEBEE), // Soft light red
                 // Soft pinkish red
                // Soft red blend
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                 Image.asset("assets/applogo_01.png",width: 120,height: 120,),
                  SizedBox(height: 20.h),
                  Image.asset(
                    "assets/wifi.png",
                    width: 2.sw,
                    height: 0.3.sh,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.all(12.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel("SSID"),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2.r,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Row(
                            children: [
                              Icon(Icons.wifi, color: Colors.grey, size: 20.sp),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: TextFormField(
                                  controller: ssidController,

                                  obscureText: false,
                                  style: TextStyle(fontSize: 14.sp),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),

                                    // suffixIcon: suffixIcon,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isSsid)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'SSID is required',
                                style: TextStyle(
                                  color: Colors.red[300],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 16.h),
                        buildLabel("BSSID"),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2.r,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wifi_tethering,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: TextField(
                                  controller: bssidController,
                                  obscureText: false,
                                  style: TextStyle(fontSize: 14.sp),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                    // suffixIcon: suffixIcon,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isBssid)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'BSSID is required',
                                style: TextStyle(
                                  color: Colors.red[300],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 16.h),

                        buildLabel("Password"),

                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2.r,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: false,

                                  style: TextStyle(fontSize: 14.sp),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 20.sp,
                                        color: Colors.black54,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isPassword)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Password is required',
                                style: TextStyle(
                                  color: Colors.red[300],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 20.h),
                        InkWell(
                          onTap: () {
                            if (_validateSsid() &&
                                _validateBssid() &&
                                _validatePassword()) {
                              // All fields valid, proceed with Smart Config logic
                              print("SSID: ${ssidController.text}");
                              print("BSSID: ${bssidController.text}");
                              print("Password: ${passwordController.text}");
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => ScanningRadarScreen(
                                        ssid: ssidController.text,
                                        bssid: bssidController.text,
                                        password: passwordController.text,
                                      ),
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(
                                      1.0,
                                      0.0,
                                    ); // Slide from right
                                    const end = Offset.zero;
                                    const curve = Curves.ease;
                                    final tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    final offsetAnimation = animation.drive(
                                      tween,
                                    );
                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFF8A80), // Soft Pinkish Red
                                  Color(0xFFE57373), // Light Red
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Configure",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.r,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void fetchWifiInfo() async {
    print("fetching");
    try {
      if (!fetchingWifiInfo) {
        final info = NetworkInfo();
        print(await info.getWifiName());
        var permission = await Permission.location.status;
        print("permission status ==> $permission");

        if (permission == PermissionStatus.granted) {
          print("Location Permission is our ALLY");
          String wifiName = await info.getWifiName() ?? "";
          ssidController.text = wifiName.replaceAll("\"", "");

          print("kjfkdjfiafiajfdfwfjw${wifiName}");
          bssidController.text = await info.getWifiBSSID() ?? '';
        } else {
          await Permission.location.request();
          print("Location Permission is not our ally");
        }

        setState(() {
          fetchingWifiInfo = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  bool _validateSsid() {
    setState(() {
      isSsid = ssidController.text.trim().isNotEmpty;
    });

    return isSsid;
  }

  bool _validateBssid() {
    setState(() {
      isBssid = bssidController.text.trim().isNotEmpty;
    });

    return isBssid;
  }

  bool _validatePassword() {
    setState(() {
      isPassword = passwordController.text.trim().isNotEmpty;
    });

    return isPassword;
  }
}
