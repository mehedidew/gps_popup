library gps_popup;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_popup/src/custom_dialog.dart';

class GPSPopup {
  bool _isGpsOn = false;
  bool _isDialogOn = false;

  static final GPSPopup _gpsPopup = GPSPopup._internal();

  factory GPSPopup() {
    return _gpsPopup;
  }

  GPSPopup._internal();

  // void initialize({
  //   required BuildContext context,
  //   String? customMessage,
  //   String? customDescription,
  //   bool? onTapPop = false,
  // }) {
  //   _connectivity.onConnectivityChanged.listen((result) async {
  //     if (result != ConnectivityResult.none) {
  //       _isOnline = await DataConnectionChecker().hasConnection;
  //     } else {
  //       _isOnline = false;
  //     }
  //
  //     if (_isOnline == true) {
  //       if (_isDialogOn == true) {
  //         _isDialogOn = false;
  //         Navigator.of(context).pop();
  //       }
  //     } else {
  //       _isDialogOn = true;
  //       Alerts(context: context).customDialog(
  //           type: AlertType.warning,
  //           message: customMessage ?? 'No Internet Connection Found!',
  //           description: customDescription ?? 'Please enable your internet',
  //           showButton: onTapPop,
  //           onTap: () {
  //             _isDialogOn = false;
  //             Navigator.of(context).pop();
  //           });
  //     }
  //   });

  Future<Position?> determinePosition({BuildContext? context}) async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        if (context != null) {
          Alerts(context: context).customDialog(
            type: AlertType.warning,
            message: 'Location Service Disabled!',
            description: 'Please enable your location service and press OK',
            onTap1: () async {
              if (await Geolocator.isLocationServiceEnabled() == true) {
                Navigator.of(context).pop();
                initialPosition = await determinePosition(context: context);
                submitLocation(initialPosition!);
                initialize(context: context);
              }
            },
          );
        }

        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // try {
      // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      // Placemark place = placemarks[0];
      // var addresses = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
      // } catch (e) {
      //   print(e);
      // }

      return position;
    } catch (e) {
      print('Inside geolocation determine position catch block $e');
      if (context != null) {
        Alerts(context: context).customDialog(
          type: AlertType.error,
          message: 'Location issue',
          description: 'Couldn\'t get location. Please check GPS and network',
        );
      }
    }
  }

  void initialize({
    required BuildContext context,
    String? customMessage,
    String? customDescription,
    bool? onTapPop = false,
  }) async {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    ).listen((Position position) async {
      if (await Geolocator.isLocationServiceEnabled() == true) {}
    }).onError((e) {
      Alerts(context: context).customDialog(
          type: AlertType.warning,
          message: customMessage ?? 'No Internet Connection Found!',
          description: customDescription ?? 'Please enable your internet',
          showButton: onTapPop,
          onTap: () {
            _isDialogOn = false;
            Navigator.of(context).pop();
          });
    });
  }
}
