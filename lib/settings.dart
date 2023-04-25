import 'package:flutter/material.dart';
import 'dart:ui';
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
  bool checked = false;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: const Alignment(0, 0),
        children: [
          Positioned(top: 40, left: 45.5, width: 331, height: 38,
          child: Container(decoration:
            BoxDecoration(color: const Color(3343934669,),
            borderRadius: BorderRadius.circular(20,)),),),
          Positioned(top: 49, left: 117,
            child: Text('SETTINGS',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
            textAlign: TextAlign.center,),
          width: 150, height: 20,),
          Positioned(top: 144, left: 40, width: 163, height: 22,
              child: Text('Allow Storage Access',
            style: TextStyle(
          color: Colors.white,),
              textAlign: TextAlign.start,),),
          Positioned(top: 130, left: 325.5,
              child: Checkbox(
            value: checked,
            onChanged: (bool? value){
              setState(() {
                () async {
                  PermissionStatus storageStatus = await Permission.manageExternalStorage.request();
                  if (storageStatus == PermissionStatus.denied){
                    print("storage permission denied");
                  }
                };
              });
            },
            activeColor: const Color(4283193533,),
            splashRadius: 2,
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.white, width: 1),
          )),
      Positioned(top: 181, left: 40, width: 163, height: 22,
        child: Text('Allow Location Access',
          style: TextStyle(
            color: Colors.white,),
          textAlign: TextAlign.start,),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("Allow Camera Access",
                style: TextStyle(
                  color: Colors.white,),
                textAlign: TextAlign.start,),
              Checkbox(
                value:false,
                onChanged: (newValue){
                  setState((){
                    checked = newValue!;
                  });},
                activeColor: const Color(4283193533,),
                splashRadius: 2,
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white, width: 1),
              )],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("Allow Camera Access",
              style: TextStyle(
                color: Colors.white,),
              textAlign: TextAlign.start,),
            Checkbox(
                value:false,
                onChanged: (newValue){
              setState((){
                checked = newValue!;
              });},
                activeColor: const Color(4283193533,),
                splashRadius: 2,
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white, width: 1),
            )],
          ),
      Positioned( top: 99, left: 40,
      child: Text('Application Permissions',
      style: TextStyle(color: const Color(4289967027,),
      fontSize: 12,),
      ), width: 146, height: 23,
      ),

    Positioned(top: 47, left:55, child: GestureDetector(
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