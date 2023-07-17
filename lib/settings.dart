import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class settings extends StatefulWidget {
  const settings({Key? key}):
      super(key: key);

  @override
  State<settings> createState(){
    return _settingsState();
  }
}

class _settingsState extends State<settings>{
  bool checked2 = false;
  bool checked3 = false;

  Future<void> checkPermissions() async {
    // Check if location permission is already granted
    PermissionStatus locationStatus = await Permission.location.status;
    setState(() {
      checked2 = locationStatus.isGranted;
    });

    // Check if camera permission is already granted
    PermissionStatus cameraStatus = await Permission.camera.status;
    setState(() {
      checked3 = cameraStatus.isGranted;
    });
  }

  void initState(){
    super.initState();
    //checks if permissions are already granted
    checkPermissions();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: const Alignment(0, 0),
        children: [
          Positioned(top: 40, left: 33.5, width: 331, height: 38,
          child: Container(decoration:
            BoxDecoration(color: const Color(3345377237,),
            borderRadius: BorderRadius.circular(20,)),),),
          Positioned(top: 52, left: 110,
            child: Text('SETTINGS',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
            textAlign: TextAlign.center,),
          width: 150, height: 20,),
           Positioned(top: 131, left: 40, width: 163, height: 22,
             child: Text('Allow Location Access',
                    style: TextStyle(
                    color: Colors.white,),
                    textAlign: TextAlign.start,),),
          Positioned(top: 114, left: 325.5,
              child: Checkbox(
                value: checked2 ?? false,
                onChanged: (newValue) async{
                  if(newValue != null){
                  //if unchecked
                  if (!newValue){
                    PermissionStatus locationStatus = await Permission.location.request();
                    setState((){
                      checked2 = locationStatus.isGranted!;
                    });
                  }else{
                    setState(() {
                      checked2 = newValue;
                    });
                  }}
                  },
                activeColor: const Color(4283193533,),
                splashRadius: 2,
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white, width: 1),
              )),
          Positioned(top: 170, left: 40, width: 163, height: 22,
            child: Text('Allow Camera Access',
              style: TextStyle(
                color: Colors.white,),
              textAlign: TextAlign.start,),),
          Positioned(top: 153, left: 325.5,
              child: Checkbox(
                value: checked3,
                onChanged: (newValue) async{
                  if (!newValue!) {
                  PermissionStatus cameraStatus = await Permission.camera.request();
                  setState(() {
                    checked3 = cameraStatus.isGranted;
                  });}else{
                    setState(() {
                      checked3 = newValue;
                    });
                  }
                  },
                activeColor: const Color(4283193533,),
                splashRadius: 2,
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white, width: 1),
              )),
      Positioned( top: 99, left: 40,
      child: Text('Application Permissions',
      style: TextStyle(color: const Color(4289967027,),
      fontSize: 12,),
      ), width: 146, height: 23,
      ),

    Positioned(top: 47, left:50, child: GestureDetector(
    child: Icon(
      const IconData(
        58199, fontFamily:'MaterialIcons', matchTextDirection: true,),
    ),
      onTap: (){
      Navigator.of(context).pushReplacementNamed('firstapp/myHomePage');
      },
    ),
    )
    ],
      ), backgroundColor: Colors.black);
  }
}