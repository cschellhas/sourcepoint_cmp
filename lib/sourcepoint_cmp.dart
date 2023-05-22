import 'dart:async';

import 'package:flutter/services.dart';

import 'action_type.dart';
import 'gdpr_user_consent.dart';

export 'package:sourcepoint_cmp/gdpr_user_consent.dart';
export 'package:sourcepoint_cmp/action_type.dart';

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
  final void Function({GDPRUserConsent? consent})? onConsentReady;

  /// called on Sourcepoint errors
  final void Function(String? errorMessage)? onError;

  /// called when the Dialog message is about to be shown
  final void Function()? onConsentUIReady;

  /// called when the Dialog message is about to disappear
  final void Function()? onConsentUIFinished;

  final void Function(ActionType? actionType)? onAction;

  SourcepointCmp({
    required this.accountId,
    required this.propertyId,
    required this.propertyName,
    required this.pmId,
    this.onConsentUIReady,
    this.onConsentUIFinished,
    this.onConsentReady,
    this.onError,
    this.onAction
  }) {
    _channel.setMethodCallHandler(_handleEvent);
  }

  /// Handles returned events
  Future<void> _handleEvent(MethodCall call) async {
    switch (call.method) {
      case 'onConsentUIReady':
        this.onConsentUIReady!();
        break;
      case 'onConsentUIFinished':
        this.onConsentUIFinished!();
        break;
      case 'onAction':
        final int code = call.arguments['actionType'];
        final actionType = actionTypeFromCode(code);
        this.onAction!(actionType);
        break;
      case 'onConsentReady':
        GDPRUserConsent consent = GDPRUserConsent(
          consentString: call.arguments['consentString'],
          acceptedVendors: _castDynamicList(call.arguments['acceptedVendors']),
          acceptedCategories: _castDynamicList(call.arguments['acceptedCategories']),
          legIntCategories: _castDynamicList(call.arguments['legIntCategories']),
          specialFeatures: _castDynamicList(call.arguments['specialFeatures']),
        );
        this.onConsentReady!(consent: consent);
        break;
      case 'onError':
        var debugDescription = call.arguments['debugDescription'] as String?;
        this.onError!(debugDescription);
        break;
    }
  }

  List<String> _castDynamicList(List<dynamic>? list) {
    if (list == null) return [];

    return List<String>.from(list.map((value) => value as String));
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
