// 맛집 정보 모델 클래스

class FoodStoreModel {
  int? id;
  String storeName; // 맛집 명
  String storeAddress; // 맛집 주소
  String storeComment; // 맛집 상세내용
  String? storeImgUrl; // 맛집 이미지 url
  String uid; // supabase user 고유값
  double latitude; // 위도
  double longitude; // 경도
  DateTime createdAt;

  // constructor, Dart에서는 생성자를 클래스 이름과 동일한 메서드로 정의
  // 객체를 생성할 때 호출되며, 생성자에 전달된 인자들을 사용하여 클래스 내부의 속성들이 초기화된다.
  FoodStoreModel({
    this.id,
    required this.storeName,
    required this.storeAddress,
    required this.storeComment,
    required this.storeImgUrl,
    required this.uid,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  // 팩토리 생성자:
  // 1. 클라이언트에서 데이터를 받을 때 사용
  // 2. JSON 데이터를 받아 JSON 데이터를 기반으로 FoodStoreModel 객체를 초기화하여 반환
  // 3. fromJSON 은 관습적으로 많이 사용되는 이름
  factory FoodStoreModel.fromJSON(Map<dynamic, dynamic> json) {
    return FoodStoreModel(
      id: json['id'],
      storeName: json['store_name'],
      storeAddress: json['store_address'],
      storeComment: json['store_comment'],
      storeImgUrl: json['store_img_url'],
      uid: json['uid'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  //  toMap: 클라이언트에서 데이터를 보낼 때 사용
  Map<String, dynamic> toMap() {
    return {
      'store_name': storeName,
      'store_address': storeAddress,
      'store_comment': storeComment,
      'store_img_url': storeImgUrl,
      'uid': uid,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
