import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:smart_config/smartConfig.dart';





class ScanningRadarScreen extends StatefulWidget {
  String ssid;
  String bssid;
  String password;
  ScanningRadarScreen({Key? key,required this.ssid,required this.bssid,required this.password}) : super(key: key);
  @override
  _ScanningRadarScreenState createState() => _ScanningRadarScreenState();
}

class _ScanningRadarScreenState extends State<ScanningRadarScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  var finalResults, packId;
  int tempInt = 0;

  final provisioner = Provisioner.espTouch();
  bool isResponse  = false;
  //ScanResult ? scanResult;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);


    try {

      provisioner.listen((response) {
        debugPrint("Device ${response.bssidText} connected to WiFi!");
        //Navigator.pop(context);
        setState(() {
          isResponse = true;
        });
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          isScrollControlled: true,
          builder: (ctx) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Device configured successfully!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFD5C51)
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "IP Address: ${response.ipAddressText}",
                    style: const TextStyle(fontSize: 16,color: Colors.black),
                  ),
                  Text(
                    "MAC: ${response.bssidText.replaceAll(":", "").toUpperCase()}",
                    style: const TextStyle(fontSize: 16,color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC5D53),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {

                        Future.delayed(const Duration(milliseconds: 500), () {
                          provisioner.stop();
                          Navigator.pop(context); // Close the bottom sheet
                          Future.delayed(const Duration(milliseconds: 200),(){
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>  SmartConfig(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0); // Slide from right
                                  const end = Offset.zero;
                                  const curve = Curves.ease;
                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  final offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 600),
                              ),
                            );

                          });
                          // Close the bottom sheet
                        });// close the sheet
                        // Add your logic here if needed
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      });
      startConfig();


      Future.delayed(const Duration(minutes: 1), () {
        if (isResponse == false) {
          // Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "No Device Found",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            provisioner.stop();
                            Navigator.pop(context); // Close the bottom sheet
                            Future.delayed(Duration(milliseconds: 200),(){
                              Navigator.pop(context);
                            });
                            // Close the bottom sheet
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  const Color(0xFFEC5D53),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Ok",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

        }
      });

    } catch (e) {
      print("EXCEPTION ==>$e");

      provisioner.stop();

      Future.delayed(const Duration(seconds: 2), () async {
        await provisioner.start(ProvisioningRequest.fromStrings(
          ssid: widget.ssid,
          bssid: widget.bssid, // Optional
          password: widget.password,
        ));
      });
    }

  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void startConfig()async{
    await provisioner.start(ProvisioningRequest.fromStrings(
      ssid: widget.ssid,
      bssid: widget.bssid, // Optional
      password: widget.password,
    ));
  }


  Widget buildRadarWaves() {
    return CustomPaint(
      painter: RipplePainter(_animation.value),
      child: Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: 400.w,
                height: 55.h,
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 50.w,
                        height: 50.w,
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                            provisioner.stop();
                          },
                          child: Card(
                            elevation: 2,
                            child: Center(
                              child: Icon(Icons.keyboard_arrow_left_outlined,color: Colors.black,size: 30.sp,),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    Text(
                      "Scanning devices nearby ",
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
              Container(

                width: double.infinity,
                height: 600.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => buildRadarWaves(),
                    ),
                    Container(
                      width: 70.sp,
                      height: 70.sp,
                      decoration: BoxDecoration(
                        color:    Color(0xFFEF4B3E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Icon(Icons.wifi, color: Colors.white, size: 36),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }







}

class RipplePainter extends CustomPainter {
  final double progress;
  RipplePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = 250.0; // Wider ripples
    final int waveCount = 6;

    for (int i = 0; i < waveCount; i++) {
      double currentProgress = (progress + i / waveCount) % 1;
      double radius = maxRadius * currentProgress;

      final paint = Paint()
        ..color = Color.lerp(  Color(0xFFFF8A80), Colors.white, currentProgress)!
            .withOpacity(1 - currentProgress)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) => true;
}
