import 'package:firstapp/myHomePage.dart';
import 'package:firstapp/settings.dart';
import 'package:flutter/material.dart';

void main(){
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
      },
    );
  }
}