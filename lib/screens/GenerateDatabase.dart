import 'package:bneedsoutlet/screens/Drawer.dart';
import 'package:bneedsoutlet/style/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Database/Database_Helper.dart';
import 'Logout.dart';

class GenerateDatabase extends StatefulWidget {
  const GenerateDatabase({super.key});

  @override
  State<GenerateDatabase> createState() => _GenerateDatabaseState();
}

class _GenerateDatabaseState extends State<GenerateDatabase> {
  final DatabaseConnection databaseConnection = DatabaseConnection();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BodyColor,
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Generate Database',
          style: TextStyle(
              color: AppColors.BodyColor, fontWeight: FontWeight.bold),
        ),
        actions:const [
          Logout(),
        ],
        backgroundColor: AppColors.CommonColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await databaseConnection.createNewTable();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.CommonColor,
            foregroundColor: AppColors.BodyColor,
          ),
          child: const Text('Create New Table'),
        ),
      ),
    );
  }
}
