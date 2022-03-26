library gps_popup;

import 'package:flutter/cupertino.dart';

class InternetPopup {
  bool _isOnline = false;
  bool _isDialogOn = false;

  final Connectivity _connectivity = Connectivity();

  static final InternetPopup _internetPopup = InternetPopup._internal();

  factory InternetPopup() {
    return _internetPopup;
  }

  InternetPopup._internal();

  void initialize({
    required BuildContext context,
    String? customMessage,
    String? customDescription,
    bool? onTapPop = false,
  }) {
    _connectivity.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        _isOnline = await DataConnectionChecker().hasConnection;
      } else {
        _isOnline = false;
      }

      if (_isOnline == true) {
        if (_isDialogOn == true) {
          _isDialogOn = false;
          Navigator.of(context).pop();
        }
      } else {
        _isDialogOn = true;
        Alerts(context: context).customDialog(
            type: AlertType.warning,
            message: customMessage ?? 'No Internet Connection Found!',
            description: customDescription ?? 'Please enable your internet',
            showButton: onTapPop,
            onTap: () {
              _isDialogOn = false;
              Navigator.of(context).pop();
            });
      }
    });
  }

  void initializeCustomWidget(
      {required BuildContext context, required Widget widget}) {
    _connectivity.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        _isOnline = await DataConnectionChecker().hasConnection;
      } else {
        _isOnline = false;
      }

      if (_isOnline == true) {
        if (_isDialogOn == true) {
          _isDialogOn = false;
          Navigator.of(context).pop();
        }
      } else {
        _isDialogOn = true;

        Alerts(context: context).showModalWithWidget(child: widget);
      }
    });
  }
}

void initialize({required BuildContext context}) async {
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
    ),
  ).listen((Position position) async {
    if (await Geolocator.isLocationServiceEnabled() == true) {
      var v = Geolocator.distanceBetween(initialPosition!.latitude,
          initialPosition!.longitude, position.latitude, position.longitude);
      if (v >= 5) {
        initialPosition = position;
        submitLocation(position);
      }
    }
  }).onError((e) {
    Alerts(context: context).customDialog(
      type: AlertType.warning,
      message: e.toString(),
      description: 'Please enable your location service and press OK',
      onTap1: () async {
        if (await Geolocator.isLocationServiceEnabled() == true) {
          Navigator.of(context).pop();
        }
      },
    );
  });
}
