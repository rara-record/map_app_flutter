import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_app/model/food_store.dart';
import 'package:map_app/widget/buttons.dart';
import 'package:map_app/widget/text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 홈 화면

// TODO: 비동기 코드 구조화:FutureBuilder를 사용하는 대신, 상태 관리를 통해 비동기 작업을 처리할 수 있습니다.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  late NaverMapController _mapController;
  Completer<NaverMapController> mapControllerCompleter = Completer();

  Future<List<FoodStoreModel>>? _foodStoresFuture;
  List<FoodStoreModel>? _foodStores; // 맛집 정보들

  bool _isLocationPermissionGranted = false; // 위치 권한 허용 여부

  @override
  void initState() {
    _checkAndRequestLocationPermission();
    _foodStoresFuture = fetchFoodStores();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _foodStoresFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error :${snapshot.error}',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          // 데이터를 제공 받은 시점
          _foodStores = snapshot.data;
          return _buildNaverMap();
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.black,
        onPressed: () async {
          var result = await Navigator.pushNamed(context, '/edit');

          // 데이터가 수정되었을 때 지도에 마커 다시 그리기
          if (result != null) {
            if (result == 'completed_edit') {
              _foodStores = await fetchFoodStores(); // 수정된 데이터 다시 가져오기
              _addFoodStoreMarkers(); // 수정된 데이터로 마커 다시 그리기
              setState(() {}); // force update
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _checkAndRequestLocationPermission() async {
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

    // 권한이 허용된 경우
    setState(() {
      _isLocationPermissionGranted = true;
    });
  }

  Widget _buildNaverMap() {
    return NaverMap(
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
        NCameraPosition myPosition = await _getUserLocation();

        // 서버에 등록된 음식점 리스트 정보들을 위경도를 가지고와서 찍기
        _addFoodStoreMarkers();

        // 추출한 위치를 기반으로 카메라 업데이트 (이동)
        _mapController
            .updateCamera(NCameraUpdate.fromCameraPosition(myPosition));

        // 지도 컨트롤러 완료 신호 전송
        mapControllerCompleter.complete(_mapController);
      },
    );
  }

  Future<List<FoodStoreModel>>? fetchFoodStores() async {
    // supaise에서 맛집 정보 가져오기
    final foodListMap = await supabase.from('food_store').select();
    List<FoodStoreModel> lstFoodStore =
        foodListMap.map((el) => FoodStoreModel.fromJSON(el)).toList();
    return lstFoodStore;
  }

  Future<NCameraPosition> _getUserLocation() async {
    if (!_isLocationPermissionGranted) {
      // 권한이 없는 경우 기본 위치 반환 또는 에러 처리
      return const NCameraPosition(
          target: NLatLng(37.5665, 126.9780), zoom: 12); // 서울시청 좌표
    }

    // 현재 디바이스 기준 GPS 센서 값을 활용해서 현재 위치 추출
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // lat: 위도, lng: 경도
    return NCameraPosition(
        target: NLatLng(position.latitude, position.longitude), zoom: 12);
  }

  void _addFoodStoreMarkers() {
    // 마커 생성

    // 마커 초기화
    _mapController.clearOverlays();

    for (FoodStoreModel foodStoreModel in _foodStores!) {
      // 마커 객체 인스턴스 생성
      final marker = NMarker(
        id: foodStoreModel.id.toString(),
        position: NLatLng(foodStoreModel.latitude, foodStoreModel.longitude),
        caption: NOverlayCaption(text: foodStoreModel.storeName),
      );

      // 마커에 클릭 가능 기능 부여
      marker.setOnTapListener((overlay) {
        _showBottomSummaryDialog(foodStoreModel);
      });

      // 네이버 맵에 마커 추가
      _mapController.addOverlay(marker);
    }
  }

  void _showBottomSummaryDialog(FoodStoreModel foodStoreModel) {
    // 맛집 정보를 보여주는 다이얼로그
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SectionText(
                        text: foodStoreModel.storeName,
                        textColor: Colors.black,
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.black,
                        ),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildFoodStoreImage(foodStoreModel),
                  Text(
                    foodStoreModel.storeComment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailButton(
                    () {
                      // 상세보기 페이지로 이동
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/detail',
                          arguments: foodStoreModel);
                    },
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFoodStoreImage(FoodStoreModel foodStoreModel) {
    return foodStoreModel.storeImgUrl?.isNotEmpty == true
        ? CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(
              foodStoreModel.storeImgUrl!,
            ),
          )
        : const Icon(
            Icons.image_not_supported,
            size: 32,
          );
  }

  Widget _buildDetailButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButtonCustom(
        text: '상세 보기',
        backgroundColor: Colors.black,
        textColor: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}
