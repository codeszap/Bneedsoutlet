import 'package:bneedsoutlet/screens/AddCompany.dart';
import 'package:bneedsoutlet/screens/AllWiseReport.dart';
import 'package:bneedsoutlet/screens/CompanyProfile.dart';
import 'package:bneedsoutlet/screens/DateReport.dart';
import 'package:bneedsoutlet/screens/GenerateDatabase.dart';
import 'package:bneedsoutlet/screens/ItemCreation.dart';
import 'package:bneedsoutlet/screens/LedgerBalance.dart';
import 'package:bneedsoutlet/screens/Logout.dart';
import 'package:bneedsoutlet/screens/MainScreenReport.dart';
import 'package:bneedsoutlet/screens/TodayReport.dart';
import 'package:bneedsoutlet/screens/Transaction.dart';
import 'package:bneedsoutlet/screens/_AccMast.dart';
import 'package:bneedsoutlet/screens/backup_database.dart';
import 'package:bneedsoutlet/screens/login.dart';
import 'package:bneedsoutlet/screens/salesEntry.dart';
import 'package:bneedsoutlet/screens/show_printer.dart';
import 'package:bneedsoutlet/style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Database/Database_Helper.dart';


Future<void> main() async {
  runApp(const MyApp());

  //   WidgetsBinding.instance?.addPostFrameCallback((_) async {
  //   final updateAvailable = await checkForUpdates();
  //   if (updateAvailable) {
  //     showUpdateNotification();
  //   }
  // });
  DatabaseConnection databaseConnection = DatabaseConnection();
  await databaseConnection.setDatabase();
  await databaseConnection.createNewTable();  
  await databaseConnection.createSalesTable();
  await databaseConnection.addColumnToTable('AccMast', 'Address1', 'TEXT');
  await databaseConnection.addColumnToTable('AccMast', 'Address2', 'TEXT');
  await databaseConnection.addColumnToTable('AccMast', 'Address3', 'TEXT');
  await databaseConnection.addColumnToTable('AccMast', 'Address4', 'TEXT');
  await databaseConnection.addColumnToTable('AccMast', 'Gstin', 'TEXT');
  await databaseConnection.addColumnToTable('AccMast', 'Pincode', 'TEXT');
  await databaseConnection.addColumnToTable('companyProfile', 'PrintMode', 'TEXT');
  await databaseConnection.addColumnToTable('companyProfile', 'TaxType', 'TEXT');
  // await databaseConnection.deleteColumnFromTable('LedgerBalance', 'Test');
  //  debugPrint('Success');
  // Fluttertoast.showToast(msg: "Main Dart Page Loading");
}

Future<bool> checkForUpdates() async {
  // You can implement your update check logic here.
  // Return true if an update is available, false otherwise.
  return false;
}

// void showUpdateNotification() {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//   runApp(MaterialApp(
//     navigatorKey: navigatorKey,
//     home: Scaffold(
//       body: Center(
//         child: AlertDialog(
//           title: const Text('Update Available'),
//           content: const Text('A new version of the app is available.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 // Close the dialog and exit the app.
//                 navigatorKey.currentState!.pop();
//                 SystemNavigator.pop();
//               },
//               child: const Text('Later'),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Open the app's update page.
//                 launchUpdateURL();
//               },
//               child:const Text('Update'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   ));
// }


// void launchUpdateURL() async {
//   const url = 'https://play.google.com/store/apps/details?id=com.nminfotech.bneedsoutletgst';
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bneeds Outlets Gst',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.CommonColor),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/login': (context) => const Login(),
        '/todayReport': (context) => const TodayReport(),
        '/MainScreen': (context) => const MainScreen(),
        '/dateReport': (context) => const DateReport(),
        '/ledgerBalance': (context) => const Ledgerbalance(),
        '/addCompany': (context) => const AddCompany(),
        '/itemCreation': (context) => const  ItemCreation(),
        '/Transaction': (context) => const Transaction(),
        '/AllWiseReport': (context) => const AllWiseReport(),
        '/SalesEntry': (context) => const SalesEntry(),
        '/accmast': (context) => const Accmast(),
        '/CompanyProfile': (context) => const  CompanyProfile(),
        '/logout': (context) => const Logout(),
        '/BackupData': (context) => const BackupData(),
        '/GenerateDatabaseState': (context) => const GenerateDatabase(),
        '/showprinter': (context) => const ShowPrinter(),
      },
    );
  }
}

