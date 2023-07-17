import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class help extends StatefulWidget {
  const help({Key? key}):
        super(key: key);

  @override
  State<help> createState(){
    return _helpState();
  }
}

class _helpState extends State<help>{
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
            Positioned(top: 52, left: 130,
              child: Text('How To Use',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,),
              width: 150, height: 20,),
            Positioned(top: 47, left:50, child: GestureDetector(
              child: Icon(
                const IconData(
                  58199, fontFamily:'MaterialIcons', matchTextDirection: true,),
              ),
              onTap: (){
                Navigator.of(context).pushReplacementNamed('firstapp/myHomePage');
              },
            ),
            ),
            Positioned(top: 100, left: 38,
              child: Text("Getting Started",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),textAlign: TextAlign.left,),),
            Positioned(top: 150, left: 38,
              child: Text("Enabling Permissions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.inactiveGray,
                ),textAlign: TextAlign.left,),),
            Positioned(top: 177, left: 38,
              child: Text("In order to use the application, you must enable the camera and location permission. "
                  "For location access, please select *precise location* in order to get better building matches.\n"
                  "\nTo allow access:\n",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: CupertinoColors.inactiveGray,
                ),textAlign: TextAlign.left,), width: 350,),
            Positioned(top: 261, left: 38,
              child: Text("Application settings: Help page > Home Page > Select settings icon at top right > Allow camera and location access > Return to home page > Begin identifying!\n",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: CupertinoColors.inactiveGray,
                ),textAlign: TextAlign.left,), width: 350,),
            Positioned(top: 317, left: 38,
              child: Text("Device settings: Open device Settings > Apps > Find Building Identifier > Permissions > Allow all permissions > Open Building Identifier > Begin identifying!\n",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: CupertinoColors.inactiveGray,
                ),textAlign: TextAlign.left,), width: 350,),
            Positioned(top: 390, left: 38,
              child: Text("Begin Identifying Buildings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.inactiveGray,
                ),textAlign: TextAlign.left,),),
            Positioned(top: 417, left: 38,
              child: Text("➜ Press *Start Identifying* button to open camera. Please select the refresh button first to refresh your location data. "
                  "\n➜ Point the camera to your target building and tap on the screen. The app will identify and show you the name and location of the building. \n"
                  "➜ Continue the process until you are satisfied. You can press the map button to view the building location on a map.\n"
                  "\n  (❁´‿`❁)/ Happy identifying! \\(•ˇ‿ˇ•)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: CupertinoColors.inactiveGray,
                ),textAlign: TextAlign.left,), width: 350,),
            Positioned(top: 600, left: 38,
              child: Text("**READ ME**",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey,
                ),textAlign: TextAlign.left,),),
            Positioned(top: 627, left: 38,
              child: Text("• Please allow some inaccuracies of the result as the buildings matches may vary on the accuracy of your device's location data and the surrounding environment of your target building.\n"
                "\n• This application estimates the target building's location based on your device's data, so please be informed that the result is may not be the precise coordinates of the actual building."
                ,style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: CupertinoColors.inactiveGray,
                ),textAlign: TextAlign.left,), width: 350,),
          ],
        ), backgroundColor: Colors.black);
  }
}