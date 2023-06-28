import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  Future<void> showAlert() async {
    showDialog(context: context,
        builder: (BuildContext context){
          return  AlertDialog(
            title: const Text("PERMISSION DENIED!"),
            content: const Text("Please change the application permission settings."),
            actions: [
              ElevatedButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: const Text("OK"))
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              alignment: const Alignment(0, 0),
              children: [
                Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/city.png"),
                              fit: BoxFit.cover),
                        )),

                Positioned(top:55, left: 25, width: 360, height: 40,
                    child: Container(
                      decoration: BoxDecoration(color: const Color(3345377237),
                        borderRadius: BorderRadius.all(Radius.circular(20)),),
                    )),
                Positioned( height: 97, width: 294.5, left: 57.5, top: 264,
                    child: Text('BUILDING IDENTIFIER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  shadows: [const Shadow(offset: Offset(5, 3,),
                  color: Color(2868956927,),
                  blurRadius: 3)],
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                ),)),
                // Positioned(top: 606, width: 113, height: 115,
                //     child: Container(
                //       decoration: BoxDecoration(
                //         color: const Color(3345377237),
                //         shape: BoxShape.circle,
                //         image: DecorationImage(
                //           image: AssetImage("assets/detect.png"),
                //           fit: BoxFit.scaleDown,
                //         ))
                //       ),
                //     ),
                Positioned( width: 176, height: 49, top: 625,
                   child: ElevatedButton(
                      child: Text('START IDENTIFYING'),
                      onPressed: () async {
                          PermissionStatus cameraStatus = await Permission.camera.request();
                          PermissionStatus locationStatus = await Permission.location.request();
                          if (cameraStatus == PermissionStatus.denied){
                            showAlert();
                            print("camera permission denied");
                          }
                          if(locationStatus == PermissionStatus.denied){
                            showAlert();
                            print("location permission denied");
                          }
                          if (cameraStatus == PermissionStatus.granted && locationStatus == PermissionStatus.granted){
                            Navigator.of(context).pushReplacementNamed('firstapp/camera_screen');
                          }
                        },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                          backgroundColor:
                          MaterialStateProperty.all(const Color(3345377237)),
                          padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                          textStyle:
                          MaterialStateProperty.all(TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  ),
                ),
                Positioned( top: 420, width: 90, height: 83,
                    child: Image(
                  image: const AssetImage("assets/detect.png"), fit: BoxFit.cover
                )),
                Positioned(top: 61, left: 347, width: 27, height: 27,
                  child: GestureDetector(
                    child: Icon(
                      const IconData(
                        0xe57f, fontFamily:'MaterialIcons', matchTextDirection: true,),
                      color: Colors.lightBlueAccent,),
                    onTap: (){
                      Navigator.of(context).pushReplacementNamed('firstapp/settings');
                    },
                  ),
                ),
    ],),
   );
  }
}
