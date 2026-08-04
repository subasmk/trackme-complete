package com.trackme.app

import io.flutter.embedding.android.FlutterActivity

/**
 * TrackMe's single Flutter entry point. No custom MethodChannels are
 * registered here — the `home_widget` plugin auto-registers its own
 * platform channel via Flutter's generated plugin registrant, and all
 * widget-tap deep-linking is handled Dart-side through
 * `HomeWidget.initiallyLaunchedFromHomeWidget()` /
 * `HomeWidget.widgetClicked` (see main.dart).
 */
class MainActivity : FlutterActivity()
