import 'package:flutter/material.dart';
import 'package:poultry_disease/dbcontroller.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
        double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('POULTRY DISEASE DETECTION', 
        style: TextStyle(color: Colors.white, fontSize: 18),),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: h,
           padding: EdgeInsets.symmetric(
            horizontal: w*0.15, 
            vertical: h*0.3),
          decoration: BoxDecoration(color: Colors.teal.shade800),
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
               const Text('Registration', style: TextStyle(color: Colors.teal, fontSize: 20),),
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
                    
                    if (username.isNotEmpty && password.isNotEmpty) {
                      DatabaseHelper dbHelper = DatabaseHelper();
                      User user = User(username: username, password: password);
                      await dbHelper.insertUser(user);
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Success'),
                            content: const Text('Registration successful.'),
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
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Please enter both email and password.'),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
                  child: const Text('Register', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}