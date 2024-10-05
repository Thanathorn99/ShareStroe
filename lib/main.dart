import 'package:flutter/material.dart';
// ignore: unused_import
import 'pages/product.dart';
// ignore: unused_import
import 'database/model.dart';
//
// *** Edit #1 *** => import plug-in
//
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'package:test_cloundbase/database/database_helper.dart';
// ignore: unused_import
import 'pages/login.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // ignore: prefer_const_constructors
    options: FirebaseOptions(
      apiKey:"AIzaSyAP0Po8N2BjbZV8cFzBQVLw6WIyzGqxwz8", 
      appId:"1:334942489320:android:9d196bf79fa38f22d6175d", 
      messagingSenderId:"", 
      projectId:"dormitory-ab7e3")
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      //
      // *** Edit #3 *** => modify calling ProductScreen (add new parameter)
      //
      home: const LoginScreen()
    );
  }
}
