import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

// 홈 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NaverMapController _mapController;
  Completer<NaverMapController> mapControllerCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaverMap(
        options: const NaverMapViewOptions(
          indoorEnable: true, // 실내 맵 사용 가능 여부
          locationButtonEnable: true, // 현위치 버튼 사용 가능 여부
          consumeSymbolTapEvents: false, // 심볼 터치 이벤트 사용 여부
        ),
        onMapReady: (controller) async {
          // 지도가 준비되었을 때 실행되는 함수

          // 지도 컨트롤러를 초기화
          _mapController = controller;

          // 이동하고싶은 카메라 위치 추출 (내 위치)
          NCameraPosition myPosition = await getMyLocation();

          // 추출한 위치를 기반으로 카메라 업데이트 (이동)
          _mapController
              .updateCamera(NCameraUpdate.fromCameraPosition(myPosition));

          // 지도 컨트롤러 완료 신호 전송
          mapControllerCompleter.complete(_mapController);
        },
      ),
    );
  }

  Future<NCameraPosition> getMyLocation() async {
    // 위치 권한을 체크해서 권한 허용이 되어있다면 내 현위치 정보 가져오기
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스를 이용할 수 있는지 체크
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // 위치 권한 현재 상태 체크
    permission = await Geolocator.checkPermission();

    // 만약 위치 권한 허용 팝업을 사용자가 거부했다면
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are denied forever');
    }

    // 현재 디바이스 기준 GPS 센서 값을 활용해서 현재 위치 추출
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // lat: 위도, lng: 경도
    return NCameraPosition(
        target: NLatLng(position.latitude, position.longitude), zoom: 12);
  }
}
