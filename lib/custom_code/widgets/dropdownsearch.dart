// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:dropdown_search/dropdown_search.dart';

class Dropdownsearch extends StatefulWidget {
  const Dropdownsearch({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<Dropdownsearch> createState() => _DropdownsearchState();
}

class _DropdownsearchState extends State<Dropdownsearch> {
  List<String> selectedItems = [];

  final Map<String, String> doctorsMap = {
    "AA": "Aidil Azman",
    "ACP": "Asyraf Publika",
    "ADL": "MUHAMMAD AIDIL HAFIZZI",
    "AFN": "Afnan",
    "AIMN": "Khairul Aiman",
    "AQL": "Aqil",
    "AVN": "Dr Avenesh",
    "CA": "CLINIC ASSISTANT PUBLIKA",
    "CA2": "CLINIC ASSISTANT ICON",
    "CAJB": "CLINIC ASSISTANT JB",
    "CIP": "Ahfaltin Inoluting",
    "CWW": "DR CHONG WAI WENG",
    "DAN": "DR MUHAMAD DANIAL BIN AHMAD HELMI",
    "FAR": "DR FARHAN BIN LOKMAN",
    "FIK": "DR IBNU FIKRI",
    "FKRL": "Fakrul Al-Azim",
    "GVN": "DR GAVIN GAN CHOOK KOK",
    "HAE": "Dr Haekal",
    "HZQ": "Dr Haziq",
    "IMN": "Amirul Iman",
    "IRF": "MUHAMAD IRFAN BIN YATIM MUSTAFA",
    "KA": "DR KHAIRULANWAR",
    "LHK": "DR LIEW HONG KHENG",
    "LYJ": "DR LIM YAO JIE",
    "MAA": "Amirul Afiq",
    "MAM": "DR MOHAMAD ARIF BIN MAZLAN",
    "MFR": "DR MUHAMMAD FAUZI BIN RAHIM",
    "MI": "DR MOHAMMAD IMRAN BIN BASRI",
    "MIR": "Amir Hakim",
    "NAF": "MUHAMMAD NAFIZUDDIN BIN MUHAMAD FAUZI",
    "NJW": "Nurul Najwa",
    "PRI": "Priya",
    "RGB": "Ragib Rahimi",
    "SAB": "NUR SABRINA BINTI HASHIM",
    "SYA": "DR AHMAD SYAKEER BIN SUHAIMI",
    "SHQ": "Shauqi",
    "SYD": "Rasyidah",
    "SYH": "Syahmie Arsye",
    "TCE": "DR TONG CHEE EAN",
    "VIC": "DR VICTOR KOAY",
    "WKT": "DR WONG KOK TING",
    "YUS": "Husaini",
    "SHL": "SHALINI A/P KAMALANATHAN",
    "MFIK": "MOHAMAD FIKRI BIN MOHD JAIS",
    "DNSH": "DANISH HAIQAL BIN JUNAIDI",
    "MAD": "MUHAMMAD AFIF DANIEL BIN MOHD RAZIF",
    "JKT": "JEKLEY TAJON",
    "ISM": "ISMAHWATI BINTI ISMAIL",
    "SJV": "SONIA JIVARAJAN",
    "BAD": "SHAZA BADRI BIN AZHAR",
    "VIN": "VINCENT YONG VOO HAN",
    "AAA": "AZIZAN ADIB BIN ABDUL AZIZ",
    "AZH": "AIMAN ZHAFRI BIN HASHIM",
    "SUR": "SURIOTHARAN A/L K.TAMILVAENTHAN",
  };

  @override
  Widget build(BuildContext context) {
    final doctorNames = doctorsMap.values.toList();

    return Container(
      width: widget.width ?? double.infinity,
      child: DropdownSearch<String>.multiSelection(
        selectedItems: selectedItems,
        items: (String? filter, dynamic loadProps) {
          if (filter == null || filter.isEmpty) return doctorNames;
          final q = filter.toLowerCase();
          return doctorNames.where((e) => e.toLowerCase().contains(q)).toList();
        },
        decoratorProps: const DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: "Select Doctors/Providers...",
            border: OutlineInputBorder(),
          ),
        ),
        popupProps: PopupPropsMultiSelection.menu(
          showSearchBox: true,
          searchFieldProps: const TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search...",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        onChanged: (values) {
          // Convert NAME → CODE
          final selectedCodes = values.map((name) {
            return doctorsMap.keys.firstWhere((key) => doctorsMap[key] == name);
          }).toList();

          FFAppState().defaultprovider = selectedCodes;

          setState(() {
            selectedItems = values;
          });
        },
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
