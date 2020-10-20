import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SourcepointCmp {
  static const MethodChannel _channel = const MethodChannel('sourcepoint_cmp');
  final int accountId;
  final int propertyId;
  final String propertyName;
  final String pmId;
  final void Function() onConsentReady;
  final void Function(String errorMessage) onError;
  var margins = [0, 0, 0, 0];

  SourcepointCmp(
      {this.accountId,
      this.propertyId,
      this.propertyName,
      this.pmId,
      this.onConsentReady,
      this.onError}) {
    _channel.setMethodCallHandler(_handleEvent);
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
      case 'onConsentReady':
        this.onConsentReady();
        break;
      case 'onError':
        var debugDescription = call.arguments['debugDescription'] as String;
        this.onError(debugDescription);
        break;
    }
    return null;
  }

  /// Load beforehand before displaying.
  Future<void> load() async {
    await _channel.invokeMethod('load', <String, dynamic>{
      'accountId': accountId,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'pmId': pmId
    });
  }

  Future<void> showPM() async {
    try {
      print('zeige cmp');
      _channel.invokeMethod('showPM', <String, dynamic>{
        'accountId': accountId,
        'propertyId': propertyId,
        'propertyName': propertyName,
        'pmId': pmId
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void showCmp() {
    try {
      print('zeige cmp');
      _channel.invokeMethod('showCMP');
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
