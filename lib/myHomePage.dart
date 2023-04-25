import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera_features/camera_features.dart';
import 'package:permission_handler/permission_handler.dart';


class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  File? imageFile;
  Position _currentPosition = Position(longitude: 0.00, latitude: 0.00, timestamp: DateTime.now(), accuracy: 1.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
  String _cameraInfo = 'Unknown';

  Future<void> getCameraInfo() async{
    String cameraInfo;
    try{
      var test = <String>[];
      test.add("LENS_INFO_AVAILABLE_FOCAL_LENGTHS");
      cameraInfo = await CameraFeatures.getCameraFeatures(test);
    } on PlatformException{
      cameraInfo = "Failed to get information.";
    }
    setState(() {
      _cameraInfo = cameraInfo;
    });
}

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

  void getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 1080,
      maxWidth: 1080,
    );

    setState(() {
      imageFile = File(pickedFile!.path);
      super.initState();
    });
  }

  _getCurrentLocation() {
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: ListView(
              children: [
                SizedBox(
                  height: 50,
                ),
                imageFile != null
                    ? Container(
                        child: Image.file(imageFile!),
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/city.png"),
                              fit: BoxFit.cover),
                        )),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if(_currentPosition != null) Text(
                        "LAT: ${_currentPosition.latitude}, LNG:${_currentPosition.longitude}"
                      ),
                      ElevatedButton(onPressed: (){_getCurrentLocation();},
                          child: Text("Get Location"))
                    ],
                  )
                ),
                Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("FC: $_cameraInfo")
                      ],
                    )
                ),
                 Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ElevatedButton(
                      child: Text('Start Identifying'),
                      onPressed: () async {
                          PermissionStatus cameraStatus = await Permission.camera.request();
                          if (cameraStatus == PermissionStatus.denied){
                            showAlert();
                            print("camera permission denied");
                          }
                          if (cameraStatus == PermissionStatus.granted){
                            getFromCamera();
                          }
                        },
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.indigoAccent),
                          padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                          textStyle:
                          MaterialStateProperty.all(TextStyle(fontSize: 16))),
                    ),
                  ),
                Positioned(top: 29, left: 316, width: 27, height: 27,
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
    backgroundColor: Colors.black);
  }
}
