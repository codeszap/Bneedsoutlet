import 'package:bneedsoutlet/style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.BodyColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 150,
              child:DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.CommonColor,
                ),
                child: Center(
                  child: Row(
                    children: [
                      ClipOval(
                        child: Icon(
                            Icons.account_circle,
                          size: 60,
                          color: AppColors.BodyColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'BNEEDS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.print_rounded),
                      SizedBox(width: 10,),
                      Text('Show Printer',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/showprinter', (route) => false);
                  },
                ),
            ExpansionTile(
              leading: const Icon(Icons.king_bed),
              title: const Text('Master', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [

                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.looks_one),
                      SizedBox(width: 10,),
                      Text('Company Profile',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/CompanyProfile', (route) => false);
                  },
                ),
                ListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.looks_two),
                      SizedBox(width: 10,),
                      Text('Item Master',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/itemCreation', (route) => false);
                  },
                ),

                 ListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.looks_two),
                      SizedBox(width: 10,),
                      Text('Account Master',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/accmast', (route) => false);
                  },
                ),
              ],
              onExpansionChanged: (expanded) {
                if (expanded) {
                  // Handle expansion if needed
                } else {
                  // Handle collapsing if needed
                }
              },
              initiallyExpanded: false, // Set whether the tile is initially expanded or collapsed
            ),
             ExpansionTile(
              leading: const Icon(Icons.import_contacts),
              title: const Text('Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [

                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.looks_one),
                      SizedBox(width: 10,),
                      Text('Sales Entry',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/SalesEntry', (route) => false);
                  },
                ),
                ListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.looks_two),
                      SizedBox(width: 10,),
                      Text('Expense Entry',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/Transaction', (route) => false);
                  },
                ),
              ],
              onExpansionChanged: (expanded) {
                if (expanded) {
                  // Handle expansion if needed
                } else {
                  // Handle collapsing if needed
                }
              },
              initiallyExpanded: false, // Set whether the tile is initially expanded or collapsed
            ),
            ExpansionTile(
              leading: const Icon(Icons.align_horizontal_left),
              title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.looks_one),
                      SizedBox(width: 10,),
                      Text('Latest Report',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/todayReport', (route) => false);
                  },
                ),
        
                ListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.looks_two),
                      SizedBox(width: 10,),
                      Text('DateWise Report',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/AllWiseReport', (route) => false);
                  },
                ),

                     ListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.looks_two),
                      SizedBox(width: 10,),
                      Text('ledger Balance',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/ledgerBalance', (route) => false);
                  },
                ),
              ],
              onExpansionChanged: (expanded) {
                if (expanded) {
                  // Handle expansion if needed
                } else {
                  // Handle collapsing if needed
                }
              },
              initiallyExpanded: false, // Set whether the tile is initially expanded or collapsed
            ),
            ExpansionTile(
              leading: const Icon(Icons.album),
              title: const Text('Others', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.looks_one),
                      SizedBox(width: 10,),
                      Text('Add Company',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/addCompany', (route) => false);
                  },
                ),
        
                ListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.looks_two),
                      SizedBox(width: 10,),
                      Text('Backup Database',style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/BackupData', (route) => false);
                  },
                ),
              ],
              onExpansionChanged: (expanded) {
                if (expanded) {
                  // Handle expansion if needed
                } else {
                  // Handle collapsing if needed
                }
              },
              initiallyExpanded: false, // Set whether the tile is initially expanded or collapsed
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout',style: TextStyle(fontWeight: FontWeight.bold),),
              onTap: () {
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
                            child: const Text('NO'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context, true);
                              SharedPreferences loginprefs = await SharedPreferences.getInstance();
                              await loginprefs.clear();
                            },
                            child:const Text('YES'),
                          ),
                        ],
                      );
                    },
                  ).then((value) {
                    if (value == true) {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    }
                  });

              },
            ),
          ],
        ),
      ),
    );
  }
}
