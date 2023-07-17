import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

var db = FirebaseFirestore.instance;
String? error;
List<double>? _gyroscopeData;
Position _currentPosition = Position(longitude: 0.00, latitude: 0.00, timestamp: DateTime.now(), accuracy: 1.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
Offset? _tapCoordinates;
const platform = MethodChannel('com.example.firstapp/Parameters');
var _buildInfo = null;

void readDb(){
  db.collection("building").get().then(
      (querySnapshot){
        print("success!");
        for (var docSnapshot in querySnapshot.docs){
          print('${docSnapshot.id} => ${docSnapshot.data()}');
        }
      },
    onError: (e) => print("Error completing: $e"),
  );
}

Future<String> _fetchStaticMap(double lat, double long) async{
  final apiKey = 'AIzaSyCaZOdkK0M9X20uCBWuTqE7xklRCw9E9YM'; // Replace with your actual Google Maps API key
  final width = 400;
  final height = 300;
  final zoom = 15;

  final url = 'https://maps.googleapis.com/maps/api/staticmap?'
      'center=$lat,$long'
      '&zoom=$zoom'
      '&size=${width}x$height'
      '&maptype=roadmap'
      '&markers=color:red%7Clabel:%7C$lat,$long'
      '&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to fetch static map image');
  }
}

Future<List<dynamic>?> getParameters() async{
  try{
    final List<dynamic>? parameters = await MethodChannel('com.example.firstapp/Parameters').invokeMethod('getParameters');
    return parameters;
  } on PlatformException catch (e){
    error = e.message;
  }
}

class CameraScreen extends StatefulWidget{
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class FloatingBox extends StatefulWidget {
  final Offset position;
  final String result;

  const FloatingBox({
    required this.position,
    required this.result,
  });

  _FloatingBoxState createState() => _FloatingBoxState();
}

class _FloatingBoxState extends State<FloatingBox> {
  bool showBox = true;
  Future<void> noResult() async {
    showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("No Match Found!"),
            content: const Text("No building information in database."),
            actions: [
              ElevatedButton(onPressed: () {
                Navigator.of(context).pop();
              }, child: const Text("OK"))
            ],
          );
        }
    );
  }

  Future<void> foundResult() async {
    showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Building Identified!"),
            content: Text("Name: ${_buildInfo["name"]}, Location: [${_buildInfo["lat"].toStringAsFixed(4)} , ${_buildInfo["long"].toStringAsFixed(4)}]"),
            actions: [
              ElevatedButton(onPressed: () {
                Navigator.of(context).pop();
              }, child: const Text("OK"))
            ],
          );
        }
    );
  }

  void initState(){
    super.initState();
    //Hide textbox after x duration
    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          showBox = false;
          if(_buildInfo != null){
            foundResult();
          }
          else{
            noResult();
          }
        });
      }
    });
  }

  Widget build(BuildContext context) {
    //checking condition
    if (!showBox) {
      return SizedBox.shrink();
    }
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.indigoAccent.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,),
          ],
        ), child: Text(widget.result),
      ),
    );
  }
}

void _getCalibration() async {
  final _gyroscope = _gyroscopeData?.map((double v) => v.toStringAsFixed(1)).toList();
  final List<num> _gps = [_currentPosition.altitude, _currentPosition.latitude, _currentPosition.longitude];
  try {
    print("what about this?");
    platform.setMethodCallHandler((call) async{
      print("setMethod");
    });
    print("pls");
    //if (_gyroscope != null){
    _buildInfo = await platform.invokeMethod('getParameters', {'cameraId': '0', '_xPixel': _tapCoordinates?.dx, '_yPixel': _tapCoordinates?.dy, 'gps':_gps});
    print("screw this ${_buildInfo}");
    //}
  } on PlatformException catch (e) {
    print("Error: ${e.message}");
  }
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver{
  CameraController? controller;
  bool _isCameraInitialized = false;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  List<FloatingBox> floatingBoxes = [];

  void onNewCameraSelected (CameraDescription cameraDescription) async{
    final previousCameraController = controller;
    //Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    //dispose the prev controller
    await previousCameraController?.dispose();

    //replace with new controller
    if(mounted){
      setState(() {
        controller = cameraController;
      });
    }
    //Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {

      });
    });

    //Initialize controller
    try{
      await cameraController.initialize();
    } on CameraException catch (e){
      print ('Error initializing camera: $e');
    }

    //Update boolean
    if (mounted){
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
    for (final subscription in _streamSubscriptions){
      subscription.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    final CameraController? cameraController = controller;

    //App state changed before initialization
    if (cameraController == null || !cameraController.value.isInitialized){
      return;
    }

    if (state == AppLifecycleState.inactive){
      //Free memory when camera isn't active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed){
      //Reinitialized camera
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void initState(){
    onNewCameraSelected(cameras[0]);
    super.initState();
    readDb();
    _getCalibration();
    _getGyroscope();
    _getCurrentLocation();
    _buildManualReader();
  }

  Future<void> showLoading() async {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 2), (){
            Navigator.of(context).pop(true);
          });
          return SpinKitCircle(
            size: 80,
            itemBuilder: (context, index){
              final colors = [Colors.white, Colors.pinkAccent, Colors.cyanAccent];
              final color = colors[index% colors.length];
              return DecoratedBox(decoration: BoxDecoration(
                color: color,
              ),);
            },
          );
        });
  }

  //get pixel coordinates
  void _handleTapDown(TapDownDetails details){
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    //store tapped pixel coordinates
    setState(() {
      _tapCoordinates = localPosition;
    });
    //User can only tap on specific area of the phone screen
    final Rect desiredArea = Rect.fromLTRB(2,128,397,709);

    if(desiredArea.contains(localPosition)){
      final String result = 'Identifying building...';
      showLoading();
      setState(() {
        floatingBoxes.add(
          FloatingBox(position: localPosition, result: result),
        );
      });
    }
  }

  //get user current latitude, longitude, altitude
  void _getCurrentLocation() {
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

  void _getGyroscope(){
    _streamSubscriptions.add(
      gyroscopeEvents.listen((event) {
        setState(() {
          _gyroscopeData = <double>[event.x,event.y,event.z];
        });
      }, onError: (e){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: const Text("Gyroscope sensor not found!"),
            content: const Text("Device does not support Gyroscope sensor"),
            actions: [
              ElevatedButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: const Text("OK"))
            ],
          );
        },
        barrierDismissible: true,);
      }, cancelOnError: true,),
    );
  }

  void _buildManualReader() async{
    setState(() {
    });
  }

  Widget _buildCompass(){
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context,snapshot){
        if (snapshot.hasError){
          return Text('Error reading heading: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        double? direction = snapshot.data!.heading;
        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1),
              child: Image.asset("assets/compass.png"),
            ),
          );
      },
    );
  }

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTapDown: _handleTapDown,
      child: Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized? new AspectRatio(
        aspectRatio: 1/ controller!.value.aspectRatio,
        child: Stack(
          children: <Widget>[
            controller!.buildPreview(),
            Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                height: 75.0,
                padding: EdgeInsets.only(left: 26, top: 30),
                color: Colors.black87,
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget> [
                    InkWell(
                    onTap: (){
                      Navigator.of(context).pushReplacementNamed('firstapp/myHomePage');
                    },
                    child: Icon(const IconData(58199, fontFamily:'MaterialIcons', matchTextDirection: true),
                      color: Colors.white),
                    ),
                    InkWell(
                    highlightColor: Colors.lightBlueAccent,
                    onTap: () {
                       _getGyroscope();
                      _getCurrentLocation();
                      _getCalibration();
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                            title: Text("Location Refreshed!"),
                            content: Text("Location and device orientation updated."),
                            actions: [ ElevatedButton(onPressed: (){
                              Navigator.of(context).pop();},
                              child: const Text("OK"))
                        ],
                        );
                      },
                      barrierDismissible: true,);
                    },
                    child: Icon(const IconData(0xf00e9, fontFamily: 'MaterialIcons'),
                    color: Colors.white,),
                    ),
                    InkWell(
                      onTap: (){
                        if(_buildInfo == null){
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                              title: Text("Building location on Map"),
                              content: Text("No identified building to show on maps."),
                              actions: [ ElevatedButton(onPressed: (){
                                Navigator.of(context).pop();},
                                  child: const Text("Close"))
                              ],
                            );
                          },
                            barrierDismissible: true,);
                        }
                        _fetchStaticMap(_buildInfo["lat"],_buildInfo["long"]).then((
                            imageData) {
                          print("imagedata $imageData");
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                              title: Text("Building location on Map"),
                              content: Image.memory(Uint8List.fromList(convert.base64Decode(imageData)),
                                fit: BoxFit.fitWidth,),
                              actions: [ElevatedButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: const Text("Close"),)],
                            );
                          }, barrierDismissible: true,);
                        }).catchError((e){print("Error in displaying map $e");});
                      },
                      child: Icon(const IconData(0xe3c8, fontFamily:'MaterialIcons', matchTextDirection: true),
                          color: Colors.white),
                    ),
                  ],),
            ), //back button
            Align(
              alignment: const Alignment(-0.5, -0.79),
              child: Container(
                width: double.infinity,
                height: 35.0,
                padding: EdgeInsets.all(5.0),
                color: Colors.black45,
                child: Container(
                  padding: EdgeInsets.only(left:30,top:4),
                  child: Text("Altitude(m): ${_currentPosition.altitude.toStringAsFixed(4)}   Latitude: ${_currentPosition.latitude.toStringAsFixed(4)}   Longitude: ${_currentPosition.longitude.toStringAsFixed(4)}",
                    style: TextStyle(color: Colors.white),),
                ),
              ),
            ), //Location info
            Positioned( top: 110, left: 3,
                child: Container(
                  width: 78,
                  height: 72,
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(color: Colors.black38,
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: _buildCompass(),
                )),//compass

            ...floatingBoxes,
          ],
         ),
        ): Container(),
    ));
  }
}
