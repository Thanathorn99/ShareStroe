import 'package:flutter/material.dart';
// ignore: unused_import
import '../database/auth.dart';
// ignore: unused_import
import '../database/database_helper.dart';
// ignore: unused_import
import '../pages/product.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _passwd = '';

  Future _showAlert(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          width: 350, // Width of the box
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // Shadow with more opacity
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 3), // Changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100.0,
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 3),
                        blurRadius: 10,
                        color: Colors.black26,
                        
                      ),
                    ],
                  ),
                ),
              ),
              // เพิ่มไอคอน person ใต้คำว่า "Login"
              const Icon(
                Icons.person,
                size: 250,
                color: Colors.white,
              ),
              const SizedBox(height: 25.0), // เพิ่มระยะห่าง
              TextFormField(
                key: UniqueKey(),
                obscureText: false,
                initialValue: _email,
                autofocus: true,
                onChanged: (value) => _email = value,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 250, 92, 0)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  filled: true,
                  fillColor: Colors.orange[50], // Light orange color
                ),
              ),
              const SizedBox(height: 25.0),
              TextFormField(
                key: UniqueKey(),
                obscureText: true,
                initialValue: _passwd,
                onChanged: (value) => _passwd = value,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 250, 92, 0)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  filled: true,
                  fillColor: Colors.orange[50], // Light orange color
                ),
              ),
              const SizedBox(height: 35.0),
              Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orangeAccent, Colors.deepOrange],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await UserAuthentication()
                          .signInWithEmailAndPassword(_email, _passwd)
                          .then((res) {
                        if (res == true) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProductListScreen(
                                    dbHelper: DatabaseHelper(),
                                  )));
                          setState(() {
                            _email = '';
                            _passwd = '';
                          });
                        } else {
                          _showAlert(context,
                              'Invalid email or password for logging in');
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      width: MediaQuery.of(context).size.width,
                      child: const Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    );
  }
}
