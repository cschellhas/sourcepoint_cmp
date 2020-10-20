# sourcepoint_cmp

Flutter Plugin for integrating Sourcepoint CMP

## Usage

To use this plugin, add `sourcepoint_cmp` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

### Example

``` dart
import 'package:flutter/material.dart';
import 'package:sourcepoint_cmp/sourcepoint_cmp.dart';

  @override
  void initState() {
    super.initState();

    _sourcepointCmp = SourcepointCmp(
        accountId: 22,
        propertyId: 7639,
        propertyName: "tcfv2.mobile.webview",
        pmId: "122058",
        onConsentReady: () {
          print('consentReady');
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
                    _sourcepointCmp.showPM(); //show Privacy Manager
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


```

