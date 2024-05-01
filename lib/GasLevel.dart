import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workmanager/workmanager.dart';



class GasLevel extends StatefulWidget {
  @override
  _GasLevelState createState() => _GasLevelState();
}

class _GasLevelState extends State<GasLevel> {
  String lpgStatus = 'Loading...';
  String test = "number";
  Timer? timer;
  int threshold = 150;

  @override
  void initState() {
    super.initState();

    // Initialize background tasks
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    Workmanager().registerPeriodicTask(
      "gasLevelTask",
      "fetchDataPeriodically",
      frequency: Duration(minutes: 15), // Adjust the frequency as needed
    );

    fetchData();
    // Start timer to refresh data every 3 seconds
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => fetchData());
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      await fetchDataPeriodically();
      return Future.value(true);
    });
  }

  static Future<void> fetchDataPeriodically() async {
    // Implement the periodic data fetching logic here
    // You can reuse the fetchData() logic here
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    final String apiKey = 'YOUR_API_KEY';
    final response = await http.get(
      Uri.parse('YOUR_API_ENDPOINT'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Update the UI with fetched data
      setState(() {
        lpgStatus = data['lpgStatus']?.toString() ?? 'Loading...';
        test = data['test']?.toString() ?? 'number';
      });

      // Check if gas level is greater than threshold and show toast message
      double gasLevel = double.tryParse(test) ?? 0.0;
      if (gasLevel > threshold) {
        Fluttertoast.showToast(
          msg: "Gas leakage detected!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      // If there's an error fetching data, display an error message
      setState(() {
        lpgStatus = 'Error: Failed to load data';
        test = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gas Level',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF4285F4),
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Gas Leakage Status',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              // Display gas level
              Text(
                'Status: $lpgStatus',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Level: $test',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
