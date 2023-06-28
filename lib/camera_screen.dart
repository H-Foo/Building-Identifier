import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  class _FloatingBoxState extends State<FloatingBox>{
  bool showBox = true;

  Future<void> showAlert() async {
    showDialog(context: context,
        builder: (BuildContext context){
          return  AlertDialog(
            title: const Text("SORRY NO MATCH!"),
            content: const Text("No existing information of this building in database.."),
            actions: [
              ElevatedButton(onPressed: (){
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
    Future.delayed(Duration(seconds: 55), (){
      if (mounted){
        setState(() {
          showBox = false;
        });
        showAlert(); //shows alert no match found
      }
    });
  }

  Widget build(BuildContext context){
    //checking condition
    if (!showBox){
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

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver{
  CameraController? controller;
  bool _isCameraInitialized = false;
  Position _currentPosition = Position(longitude: 0.00, latitude: 0.00, timestamp: DateTime.now(), accuracy: 1.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
  final picker = ImagePicker();
  List<FloatingBox> floatingBoxes = [];

  Future<void> showLoading() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 54), (){
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

  void _handleTapDown(TapDownDetails details){
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);

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

  //stores compass events
  CompassEvent? _lastRead;
  DateTime? _lastReadAt;

  void _buildManualReader() async{
    final CompassEvent tmp = await FlutterCompass.events!.first;
    setState(() {
      _lastRead = tmp;
      _lastReadAt = DateTime.now();
    });
  }

  @override
  void initState(){
    onNewCameraSelected(cameras[0]);
    super.initState();
    _getCurrentLocation();
    _buildManualReader();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    final CameraController? cameraController = controller;

    //App state changed before initialization
    if (cameraController == null || !cameraController.value.isInitialized){
      return;
    }

    if (state == AppLifecycleState.inactive){
      //Free memory when camera isnt active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed){
      //Reinitialized camera
      onNewCameraSelected(cameraController.description);
    }
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
                alignment: Alignment.center,
                width: double.infinity,
                height: 105.0,
                padding: EdgeInsets.all(10.0),
                color: Colors.black87,
                child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.of(context).pushReplacementNamed('firstapp/myHomePage');
                    },
                    child: Icon(const IconData(58199, fontFamily:'MaterialIcons', matchTextDirection: true),
                      color: Colors.white),
                  ),
                ]
              )
            ),
            Align(
              alignment: const Alignment(-0.5, -0.70),
              child: Container(
                width: double.infinity,
                height: 35.0,
                padding: EdgeInsets.all(5.0),
                color: Colors.black45,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          onTap: (){
                            _getCurrentLocation();
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.0),
                            child: Text("Altitude(m): ${_currentPosition.altitude.toStringAsFixed(4)}   Latitude: ${_currentPosition.latitude.toStringAsFixed(4)}   Longitude: ${_currentPosition.longitude.toStringAsFixed(4)}",
                            style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              ),
            ),
            Positioned( top: 142, left: 3,
                child: Container(
                  width: 78,
                  height: 72,
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(color: Colors.black38,
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: _buildCompass(),
                )),

            ...floatingBoxes,
          ],
         ),
        ): Container(),
    ));
  }
}
