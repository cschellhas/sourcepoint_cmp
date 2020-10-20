import 'dart:async';

import 'package:flutter/services.dart';

class SourcepointCmp {
  /// The method channel used to interact with the native platform.
  static const MethodChannel _channel = const MethodChannel('sourcepoint_cmp');

  /// Account ID from your Sourcepoint Account
  final int accountId;

  /// Id of your Property
  final int propertyId;

  /// Name of your Property
  final String propertyName;

  /// Privacy Manager id
  final String pmId;

  /// called after an action is taken by the user and the consent info is returned by SourcePoint's endpoints
  final void Function() onConsentReady;

  /// called on Sourcepoint errors
  final void Function(String errorMessage) onError;

  SourcepointCmp(
      {this.accountId,
      this.propertyId,
      this.propertyName,
      this.pmId,
      this.onConsentReady,
      this.onError}) {
    _channel.setMethodCallHandler(_handleEvent);
  }

  /// Handles returned events
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

  /// Load CMP Message, only for new Users
  Future<void> load() async {
    await _channel.invokeMethod('load', <String, dynamic>{
      'accountId': accountId,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'pmId': pmId
    });
  }

  /// Show Privacy Manger
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
}
