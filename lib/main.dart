import 'package:firstapp/myHomePage.dart';
import 'package:firstapp/settings.dart';
import 'package:firstapp/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

List<CameraDescription> cameras = [];

Future<void> main() async{
  try {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown],).then(
            (value) => runApp(MyApp()));

    cameras = await availableCameras();
  } on CameraException catch (e){
    print('Error in fetching the cameras: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Building Identifier',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(),
      routes: {
        'firstapp/settings' : (context) => settings(),
        'firstapp/myHomePage' : (context) => MyHomePage(),
        'firstapp/camera_screen' : (context) => CameraScreen(),
      },
    );
  }
}