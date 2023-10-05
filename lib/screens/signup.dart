import 'package:http/http.dart' as http;
import 'package:bneedsoutlet/screens/login.dart';
import 'package:bneedsoutlet/style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Singup extends StatefulWidget {
  const Singup({super.key});

  @override
  State<Singup> createState() => _SingupState();
}

class _SingupState extends State<Singup> {

  final _usernameController = TextEditingController();
  final _userpasswordController = TextEditingController();
  final _usercompanyIdController = TextEditingController();
  final _usercompanyNameController = TextEditingController();

  bool _validateusername = false;
  bool _validateUserpassword = false;
  bool _validateUsercompanyId = false;
  bool _validatecompanyName = false;

  void _onSavePressed(){
    setState(() {
      _usernameController.text.isEmpty
          ? _validateusername = true
          : _validateusername = false;
      _userpasswordController.text.isEmpty
          ? _validateUserpassword = true
          : _validateUserpassword = false;
      _usercompanyIdController.text.isEmpty
          ? _validateUsercompanyId = true
          : _validateUsercompanyId = false;
      _usercompanyNameController.text.isEmpty
          ? _validatecompanyName = true
          : _validatecompanyName = false;
    });

    if (_validateusername == false &&
        _validateUserpassword == false &&
        _validateUsercompanyId == false &&
        _validatecompanyName == false
    ) {
      var username = _usernameController.text;
      var password = _userpasswordController.text;
      var companyId = _usercompanyIdController.text;
      var companyName = _usercompanyNameController.text;

      var url = Uri.parse(
          'http://bneeds.in/bneedsoutletapi/SignUpApi.aspx?'
              '&username=$username'
              '&password=$password'
              '&companyId=$companyId'
              '&companyName=$companyName'
      );
      // logger.i(url);
      // Make the HTTP request
      http.get(url).then((response) async {
        if (response.statusCode == 200) {
          // Request successful
          if (response.body == 'SignUp Failed') {
            // logger.i("+++++++++++++++++++++++");
            Fluttertoast.showToast(msg: 'Already Account Created');
            _usernameController.text = '';
            _userpasswordController.text = '';
            _usercompanyIdController.text = '';
            _usercompanyNameController.text = '';
          } else {
            Fluttertoast.showToast(msg: 'Account Created Successfuly');
            _usernameController.text = '';
            _userpasswordController.text = '';
            _usercompanyIdController.text = '';
            _usercompanyNameController.text = '';
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
                  _usercompanyIdController.text = "";
                  _usercompanyNameController.text = "";
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BodyColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Icon(
                          Icons.sensor_door,
                        size: 60,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "SIGNUP",
                      style: TextStyle(
                          fontSize: 45,
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
                TextField(
                  controller: _usercompanyIdController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.credit_card_outlined),
                    labelText: "Company Id",
                    border: const OutlineInputBorder(),
                    errorStyle: const TextStyle(color: Colors.red),
                    errorText: _validateUsercompanyId
                        ? 'Company Id Value Can\'t Be Empty'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usercompanyNameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.code),
                    labelText: "Company Name",
                    border: const OutlineInputBorder(),
                    errorStyle: const TextStyle(color: Colors.red),
                    errorText: _validatecompanyName
                        ? 'Company Name Value Can\'t Be Empty'
                        : null,
                  ),
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
                        "SAVE",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: (){
                        _usercompanyNameController.text ="";
                        _userpasswordController.text ="";
                        _usercompanyIdController.text="";
                        _usernameController.text="";
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
                    Navigator.pushReplacement(context
                      , MaterialPageRoute(builder: (context) => Login(),
                      ),
                    );
                  },
                  child: const Text(
                    "Already Have Account",
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
      ),
    );
  }
}
