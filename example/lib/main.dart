import 'package:flutter/material.dart';

import 'package:sourcepoint_cmp/sourcepoint_cmp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SourcepointCmp _sourcepointCmp;

  @override
  void initState() {
    super.initState();

    _sourcepointCmp = SourcepointCmp(
        accountId: 22,
        propertyId: 7639,
        propertyName: "tcfv2.mobile.webview",
        pmId: "122058",
        onConsentReady: (GDPRUserConsent result) {
          print('Consent action is taken and returned to Sourcepoint');
        },
        onError: (errorCode) {
          print('consentError: errorCode:$errorCode');
        });

    //Show on Start
    _sourcepointCmp.load();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              Center(
                child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    _sourcepointCmp.showPM();
                  },
                  child: Text(
                    "Show PrivacyManager",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
