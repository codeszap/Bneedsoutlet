import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Modal/AddCompanyModal.dart';

Widget CommonCompanyDropdown(Future<List<Company>> futureCompanies, String? selectedValue, void Function(String?) onChanged) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Align(
      alignment: Alignment.center,
      child: FutureBuilder<List<Company>>(
        future: futureCompanies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            List<Company> companies = snapshot.data!;
            if (selectedValue == null && companies.isNotEmpty) {
              selectedValue = companies.first.companyid;
            }
            return DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              hint: Text(selectedValue ?? 'Select a company'),
              items: companies.map((company) {
                return DropdownMenuItem<String>(
                  value: company.companyid,
                  child: Text(company.companyid),
                );
              }).toList(),
              onChanged: onChanged,
            );
          } else {
            return const Text('No companies available.');
          }
        },
      ),
    ),
  );
}
