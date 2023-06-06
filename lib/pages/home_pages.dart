import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:codigo_maps/utils/map_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List data = [
    {
      "id": 1,
      "latitude": -11.965208,
      "longitude": -76.983297,
      "title": "Comisaria",
      "image": "https://cdn-icons-png.flaticon.com/512/3882/3882851.png",
    },
    {
      "id": 2,
      "latitude": -11.964228,
      "longitude": -76.983315,
      "title": "Bombero",
      "image": "https://cdn-icons-png.flaticon.com/512/921/921079.png",
    },
    {
      "id": 3,
      "latitude": -11.965119,
      "longitude": -76.986518,
      "title": "Hospital",
      "image":
          "https://www.shareicon.net/data/512x512/2016/07/10/119238_hospital_512x512.png",
    }
  ];

  Set<Marker> myMarkers = {
    const Marker(
      markerId: MarkerId("mandarina0"),
      position: LatLng(-11.964758, -76.984970),
    ),
    const Marker(
      markerId: MarkerId("mandarina1"),
      position: LatLng(-11.964958, -76.984570),
    ),
  };

  Set<Polyline> myPolyline = {};
  final List<LatLng> _points = [];

  StreamSubscription<Position>? positionStreamSubscription;

  @override
  initState() {
    super.initState();
    getData();
    getCurrentPosition();
  }

  getData() async {
    for (var element in data) {
      getImageMarkerBytes(element["image"], frontInternet: true).then((value) {
        Marker marker = Marker(
          markerId: MarkerId(myMarkers.length.toString()),
          position: LatLng(element["latitude"], element["longitude"]),
          icon: BitmapDescriptor.fromBytes(value),
        );
        myMarkers.add(marker);
        setState(() {});
      });
    }
  }

  //
  getCurrentPosition() async {
    Polyline route1 = Polyline(
      polylineId: const PolylineId("route1"),
      color: Colors.deepPurple,
      width: 3,
      points: _points,
    );
    myPolyline.add(route1);

    BitmapDescriptor myIcon = BitmapDescriptor.fromBytes(
      await getImageMarkerBytes(
        "https//freesvg.org/img/car_topview.png",
        frontInternet: true,
      ),
    );
    Position? positionTemp;

    positionStreamSubscription = Geolocator.getPositionStream().listen((event) {
      LatLng point = LatLng(event.latitude, event.longitude);
      _points.add(point);

      double rotation = 0;

      if (positionTemp != null) {
        rotation = Geolocator.bearingBetween(
          positionTemp!.latitude,
          positionTemp!.longitude,
          event.latitude,
          event.longitude,
        );
      }

      Marker indicator = Marker(
        markerId: const MarkerId("IndicatorPosition"),
        position: point,
        icon: myIcon,
        rotation: rotation,
      );
      myMarkers.add(indicator);
      positionTemp = event;
      setState(() {});
    });

    //  Position position = await Geolocator.getCurrentPosition();
    // Geolocator.getPositionStream().listen((event) {
    //   print(event);
    // });
  }

  Future<Uint8List> getImageMarkerBytes(String path,
      {bool frontInternet = false, double width = 100}) async {
    late Uint8List bytes;

//Si la imagen es de internet
    if (frontInternet) {
      File file = await DefaultCacheManager().getSingleFile(path);
      bytes = await file.readAsBytes();
//
    } else {
      ByteData byteData = await rootBundle.load(path);
      bytes = byteData.buffer.asUint8List();
    }
//con ello configuramos el tamaño de la imagen
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 100);
    ui.FrameInfo frame = await codec.getNextFrame();
    ByteData? myByteData =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List myBytes = myByteData!.buffer.asUint8List();
    return myBytes;
  }

  @override
  void dispose() {
    super.dispose();
    positionStreamSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-11.964758, -76.984970),
          zoom: 16,
        ),
        compassEnabled: true,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle(json.encode(mapStyle));
        },
        zoomControlsEnabled: true, //para hacer zoom
        zoomGesturesEnabled:
            true, // con esto se puede mover pero no se puede hacer zoom

        //Para crear marcadores
        markers: myMarkers,
        polylines: myPolyline,
        onTap: (LatLng position) async {
          Marker marker = Marker(
            markerId: MarkerId(myMarkers.length.toString()),
            position: position,
            // icon: await BitmapDescriptor.fromAssetImage(
            //   const ImageConfiguration(),
            //   "assets/images/location.png", //para cambiar el ìcono del marcador
            // ),
            // icon: BitmapDescriptor.defaultMarkerWithHue(
            //     BitmapDescriptor.hueOrange),//cambiar colorr

            icon: BitmapDescriptor.fromBytes(
              await getImageMarkerBytes(
                "https://cdn-icons-png.flaticon.com/512/1673/1673219.png",
                frontInternet: true,
                width: 200,
              ),
            ),
            rotation: 0, //para obtener la rotaciòn del marcador
            draggable: true, //para arrastrar y mover
            onDrag: (LatLng newPosition) //para ser arrastrado
                {
              print(newPosition);
            },
          );
          myMarkers.add(marker);
          setState(() {});
        },
      ),
    );
  }
}
