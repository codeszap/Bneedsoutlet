import 'dart:io';
import 'package:bneedsoutlet/screens/Drawer.dart';
import 'package:bneedsoutlet/screens/login.dart';
import 'package:bneedsoutlet/style/Colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class BackupData extends StatefulWidget {
  const BackupData({Key? key}) : super(key: key);

  @override
  _BackupDataState createState() => _BackupDataState();
}

class _BackupDataState extends State<BackupData> {
  String? _selectedDirectory = "/storage/emulated/0/Documents";
  Future<void> _selectBackupDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _selectedDirectory = result;
      });
    } else {
      Fluttertoast.showToast(msg: 'Storage permission denied.');
    }
  }
  Future<void> _backupDatabase() async {
  if (_selectedDirectory != null) {
    final permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted) {
      try {
        final sourceDbPath = await getDatabasesPath();
        final sourceDbFile = File(path.join(sourceDbPath, 'NMSADMINDB.db'));

        if (await sourceDbFile.exists()) {
          final destinationDirectory = Directory(_selectedDirectory!);

          // Create a unique filename for the backup using the current date
          final currentDateTime = DateTime.now();
          final formattedDate = DateFormat('yyyyMMdd').format(currentDateTime);
          final backupFileName = 'NMSADMINDB_backup_$formattedDate.db';
          final destinationFilePath = path.join(destinationDirectory.path, backupFileName);
          final destinationFile = File(destinationFilePath);

          if (await destinationFile.exists()) {
            // A backup for the same date already exists; replace it
            await destinationFile.delete();
          }

          final sourceStream = sourceDbFile.openRead();
          final destinationStream = destinationFile.openWrite();

          await sourceStream.pipe(destinationStream);
          await destinationStream.flush();
          await destinationStream.close();

          // debuglogger.i('Database backup created successfully at: $destinationFilePath');

          Fluttertoast.showToast(msg: 'Database backup created successfully $formattedDate');
        } else {
          Fluttertoast.showToast(msg: 'Source database file not found.');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error creating database backup: $e');
      }
    } else {
      Fluttertoast.showToast(msg: 'Storage permission denied.');
    }
  } else {
    Fluttertoast.showToast(msg: 'No backup directory selected.');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BodyColor,
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Backup Data',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor:AppColors.CommonColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Exit',style: TextStyle(fontSize: 18),),
                    content: SingleChildScrollView(child: Center(child: Text('Are you sure you want to exit?',style: TextStyle(fontSize:16),))),
                    actions: [
                      TextButton(
                        child: Text('Yes',style: TextStyle(fontSize: 20,color: Colors.teal),),
                        onPressed: () async {
                         /* SharedPreferences Userprefs = await SharedPreferences.getInstance();
                          await Userprefs.clear();*/
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                      ),
                      TextButton(
                        child: Text('No',style: TextStyle(fontSize: 18,color: Colors.red),),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _selectBackupDirectory,
              child: const Text('Select Backup Directory'),
            ),
            const SizedBox(height: 16),
            Text(
              'Selected Directory: $_selectedDirectory',
              style: const TextStyle(fontWeight: FontWeight.bold),textAlign:TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _backupDatabase,
              child: const Text('Backup Database'),
            ),
          ],
        ),
      ),
    );
  }
}
