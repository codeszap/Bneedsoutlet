import 'dart:convert';
import 'package:bneedsoutlet/screens/TodayReport.dart';
import 'package:bneedsoutlet/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../style/Colors.dart';
import 'package:logger/logger.dart' as logger;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final log = logger.Logger();

  final _usernameController = TextEditingController();
  final _userpasswordController = TextEditingController();

  bool _validateusername = false;
  bool _validateUserpassword = false;

  void _onSavePressed(){
      setState(() {
        _usernameController.text.isEmpty
            ? _validateusername = true
            : _validateusername = false;
        _userpasswordController.text.isEmpty
            ? _validateUserpassword = true
            : _validateUserpassword = false;
      });

      if (_validateusername == false &&
          _validateUserpassword == false
      ) {
        var username = _usernameController.text;
        var password = _userpasswordController.text;

        var url = Uri.parse(
            'http://bneeds.in/bneedsoutletapi/loginapi.aspx?'
                '&username=$username'
                '&password=$password'
        );
          log.w(url);
        // Make the HTTP request
        http.get(url).then((response) async {
          if (response.statusCode == 200) {
            if (response.body == 'Login Failed') {
              // logger.i("+++++++++++++++++++++++");
              Fluttertoast.showToast(msg: 'Login Failed');
              _usernameController.text = '';
              _userpasswordController.text = '';
            } else {
              // Parse the JSON response
              List<dynamic> data = jsonDecode(response.body);
              if (data.isNotEmpty) {
                Map<String, dynamic> userData = data.first;
                String username = userData['Username'];
                String password = userData['Password'];
                // Store values in shared preferences
                log.w('Username: $username Password: $password');
                SharedPreferences loginprefs = await SharedPreferences.getInstance();
                await loginprefs.setString('username', username);
                await loginprefs.setString('password', password);
               

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TodayReport(),
                  ),
                );
                _usernameController.text ="";
                _userpasswordController.text ="";
                /*Fluttertoast.showToast(msg: 'Welcome: ${username}');*/
                Fluttertoast.showToast(msg: 'Login Successfully');

              }
            }
          }
        }).catchError((error) {
          // logger.i("+++++++++++++++++++++");
          // logger.i('Error: $error');
          Fluttertoast.showToast(msg: 'Error: $error');
        });

      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Invalid password'),
              content: const Text('Please enter the correct password.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _usernameController.text = "";
                    _userpasswordController.text = "";
                  },
                ),
              ],
            );
          },
        );
      }
  }

  @override
  void initState() {
    super.initState();
    checkLoggedInUser();
  }
  Future<void> checkLoggedInUser() async {
    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    bool isLoggedIn = loginprefs.containsKey('username');

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/todayReport');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.BodyColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Icon(
                      Icons.login,
                      size: 60,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "BNEEDS LOGIN",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: "User Name",
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(color: Colors.red),
                  errorText: _validateusername
                      ? 'User Name Value Can\'t Be Empty'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _userpasswordController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  labelText: "password",
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(color: Colors.red),
                  errorText: _validateUserpassword
                      ? 'User password Value Can\'t Be Empty'
                      : null,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _onSavePressed,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.CommonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )
                    ),
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: (){
                      _usernameController.text ="";
                      _userpasswordController.text ="";
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.CommonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:Colors.white
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Singup()),
                    );
                  },
                  child: const Text(
                "Create New Account",
                style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                  color: AppColors.CommonColor,
              ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
