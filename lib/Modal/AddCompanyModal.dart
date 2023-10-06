import 'dart:convert';
import 'dart:io';
import 'package:bneedsoutlet/screens/AddCompany.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
class Company {
  final String companyid;

     Company({
    required this.companyid,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyid: json['CompanyName'],
    );
  }
}


Future<List<Company>> fetchAlbums(BuildContext context) async {
  try {
    SharedPreferences loginprefs = await SharedPreferences.getInstance();
    var username = loginprefs.getString('username');
    final url = Uri.parse('http://bneeds.in/bneedsoutletapi/ShowAddCompanyApi.aspx?action=show&username=$username');
    // logger.i(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Company> companies  = jsonList.map((json) => Company.fromJson(json)).toList();
      return companies ;
    } else {
      throw Exception('Failed to load albums');
    }
  } on SocketException {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please connect to the internet and try again.'),
          actions: [
            TextButton(
              child:const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return [];
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: const SingleChildScrollView(
            child: Center(
              child: Text(
                'NO company Available.',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),
              ),
            ),
          ),
          actions: [
            TextButton(
              child:const Text('OK'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCompany(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
    return [];
  }

}

