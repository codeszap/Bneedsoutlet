import 'package:bneedsoutlet/style/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logout extends StatelessWidget {
  const Logout({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.logout),
      onPressed: () {
        _showConfirmationDialog(context);
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.BodyColor,
          title: Center(child: Text('LOGOUT',style: TextStyle(fontWeight: FontWeight.bold),)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, true);
                SharedPreferences loginprefs = await SharedPreferences.getInstance();
                await loginprefs.clear();
              },
              child: Text('YES'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }
}

