import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:poultry_disease/dbcontroller.dart';
import 'package:poultry_disease/main.dart';
import 'package:poultry_disease/registration_screen.dart';
import 'package:camera/camera.dart';

class LoginScreen extends StatefulWidget {
final CameraDescription camera;
  const LoginScreen({super.key, required this.camera});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade400,
        title: const Center(
          child: Text(
            textAlign: TextAlign.center,
            'POULTRY DISEASE DETECTION',
            style: TextStyle(fontWeight: FontWeight.bold,
            color: Colors.white, 
            fontSize: 18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(  
          color: Colors.teal.shade800,
          padding: EdgeInsets.symmetric(horizontal: w*0.15, vertical: h*0.25),
          child: Container(
            padding: const EdgeInsets.all(20),
           decoration: BoxDecoration( 
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
           ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    'LOGIN',
                    style: TextStyle(fontSize: 18, color: Colors.teal),
                  ),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    String username = usernameController.text;
                    String password = passwordController.text;
            
                    DatabaseHelper dbHelper = DatabaseHelper();
                    User? user = await dbHelper.getUser(username);
            
                    if (user != null && user.password == password) {
                     Navigator.push(context, MaterialPageRoute(builder: ((context) => MyHomePage(camera: widget.camera,))));
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Invalid email or password.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800
                  , padding: EdgeInsets.symmetric(horizontal: w*0.2, vertical: h*0.005)),
                  child: const Text('Login', style: TextStyle(color: Colors.white),),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>RegistrationScreen()));
                  },
                  
                  child: const Text('Don\'t have an account?', style: TextStyle(color: Colors.green),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
