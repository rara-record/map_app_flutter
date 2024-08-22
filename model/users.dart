// 가입된 유저 정보

class UserModel {
  int? id;
  String? profileUrl;
  String name;
  String email;
  String introduce;
  String uid;
  DateTime? createdAt;

  // constructor, Dart에서는 생성자를 클래스 이름과 동일한 메서드로 정의
  // 객체를 생성할 때 호출되며, 생성자에 전달된 인자들을 사용하여 클래스 내부의 속성들이 초기화된다.
  UserModel({
    this.id,
    this.profileUrl,
    required this.name,
    required this.email,
    required this.introduce,
    required this.uid,
    this.createdAt,
  });

  // 팩토리 생성자:
  // 1. 클라이언트에서 데이터를 받을 때 사용
  // 2. JSON 데이터를 받아 JSON 데이터를 기반으로 UserModel 객체를 초기화하여 반환
  // 3. fromJSON 은 관습적으로 많이 사용되는 이름
  factory UserModel.fromJSON(Map<dynamic, dynamic> json) {
    return UserModel(
      id: json['id'],
      profileUrl: json['profile_url'],
      name: json['name'],
      email: json['email'],
      introduce: json['introduce'],
      uid: json['uid'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  //  toMap: 클라이언트에서 데이터를 보낼 때 사용
  Map<String, dynamic> toMap() {
    return {
      'profile_url': profileUrl,
      'name': name,
      'email': email,
      'introduce': introduce,
      'uid': uid,
    };
  }
}
