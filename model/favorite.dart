// 즐겨찾기

class FavoriteModel {
  int? id;
  int foodStoreId;
  String favoriteUid;
  DateTime? createdAt;

  // constructor, Dart에서는 생성자를 클래스 이름과 동일한 메서드로 정의
  // 객체를 생성할 때 호출되며, 생성자에 전달된 인자들을 사용하여 클래스 내부의 속성들이 초기화된다.
  FavoriteModel({
    this.id,
    required this.foodStoreId,
    required this.favoriteUid,
    this.createdAt,
  });

  // 팩토리 생성자:
  // 1. 클라이언트에서 데이터를 받을 때 사용
  // 2. JSON 데이터를 받아 JSON 데이터를 기반으로 FavoriteModel 객체를 초기화하여 반환
  // 3. fromJSON 은 관습적으로 많이 사용되는 이름
  factory FavoriteModel.fromJSON(Map<dynamic, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      foodStoreId: json['food_store_id'],
      favoriteUid: json['favorite_uid'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  //  toMap: 클라이언트에서 데이터를 보낼 때 사용
  Map<String, dynamic> toMap() {
    return {
      'food_store_id': foodStoreId,
      'favorite_uid': favoriteUid,
    };
  }
}
