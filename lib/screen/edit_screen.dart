import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_app/common/snackbar_uril.dart';
import 'package:map_app/model/food_store.dart';
import 'package:map_app/widget/appbar.dart';
import 'package:map_app/widget/buttons.dart';
import 'package:map_app/widget/text.dart';
import 'package:map_app/widget/text_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daum_postcode_search/data_model.dart';
import 'package:http/http.dart' as http;

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  File? storeImage; // 갤러리에서 새로 선택한 맛집정보 이미지
  DataModel? dataModel; // 주소 검색 결과값을 담는 변수
  final TextEditingController _storeAddressController =
      TextEditingController(); // 주소
  final TextEditingController _storeNameController =
      TextEditingController(); // 별명
  final TextEditingController _storeCommentController =
      TextEditingController(); // 메모

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: '맛집 등록하기',
        isLeading: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 맛집 사진
                GestureDetector(
                    child: _buildStoreImg(),
                    // 맛집 이미지 변경 및 삭체 팝업 띄우기
                    onTap: () {
                      showBottomSheetAboutStoreImg();
                    }),

                const SizedBox(height: 24),

                // 맛집 위치
                const SectionText(
                    text: '맛집 위치(도로명 주소)', textColor: Colors.black),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '클릭하여 주소 입력',
                  isPasswordField: false,
                  isReadOnly: true,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputStoreValidator(value),
                  controller: _storeAddressController,
                  onTap: () async {
                    // 주소 검색 웹뷰 화면으로 이동
                    var result =
                        await Navigator.pushNamed(context, '/search_address');
                    if (result != null) {
                      setState(() {
                        dataModel = result as DataModel;
                        _storeAddressController.text =
                            dataModel?.roadAddress ?? '맛집 주소를 선택 해주세요';
                      });
                    }
                  },
                ),

                const SizedBox(height: 24),

                // 맛집 별명
                const SectionText(text: '맛집 별명', textColor: Colors.black),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '별명을 입력해주세요.',
                  isPasswordField: false,
                  isReadOnly: false,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputNameValidator(value),
                  controller: _storeNameController,
                ),

                const SizedBox(height: 24),

                // 메모
                const SectionText(text: '메모', textColor: Colors.black),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '',
                  isPasswordField: false,
                  isReadOnly: false,
                  maxLines: 5,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputMemoValidator(value),
                  controller: _storeCommentController,
                ),

                const SizedBox(height: 24),

                // 맛집 등록 완료 버튼
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButtonCustom(
                    text: '등록',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () async {
                      // 유효성 검사 체크
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      // supabase db에 insert
                      bool isEditSuccess = await editFoodStore();

                      if (!context.mounted) return;

                      if (!isEditSuccess) {
                        showSnackBar(context, '맛집 등록 중 문제가 발생했습니다');
                        Navigator.pop(context);
                        return;
                      }

                      showSnackBar(context, '맛집 등록을 성공 하였습니다');
                      Navigator.pop(context, 'completed_edit');
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreImg() {
    if (storeImage != null) {
      return Container(
        width: double.infinity,
        height: 140,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Image.file(storeImage!, fit: BoxFit.cover),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 140,
        decoration: ShapeDecoration(
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: const Icon(Icons.image_search, size: 96, color: Colors.white),
      );
    }
  }

  void showBottomSheetAboutStoreImg() {
    showModalBottomSheet(
      context: context,
      // 위젯 뱉어주기
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 사진 촬영 버튼
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  getCameraImage();
                },
                child: const Text('사진 촬영',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
              ),
              // 앨범에서 사진 선택
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  getGalleryImage();
                },
                child: const Text('앨범에서 사진 선택',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
              ),
              // 맛집 사진 삭제
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteProfileImage();
                },
                child: const Text('맛집 사진 삭제',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getCameraImage() async {
    // 카메라로 사진 촬영하여 이미지 파일을 가져오는 함수
    var image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );
    if (image != null) {
      setState(() {
        storeImage = File(image.path);
      });
    }
  }

  Future<void> getGalleryImage() async {
    // 앨범에서 사진 선택하는 함수
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 10,
    );
    if (image != null) {
      setState(() {
        storeImage = File(image.path);
      });
    }
  }

  void deleteProfileImage() {
    // 맛집 사진 삭제
    setState(() {
      storeImage = null;
    });
  }

  inputStoreValidator(value) {
    // 맛집 주소 검증
    if (value.isEmpty) {
      return '주소를 입력해주세요.';
    }
    return null;
  }

  inputNameValidator(value) {
    // 맛집 별명 검증
    if (value.isEmpty) {
      return '별명을 입력해주세요.';
    }
    return null;
  }

  inputMemoValidator(value) {
    // 맛집 메모 검증
    if (value.isEmpty) {
      return '메모를 입력해주세요.';
    }
    return null;
  }

  inputEmailValidator(value) {
    // 이메일 필드 검증 함수
    if (value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    return null;
  }

  Future<bool> editFoodStore() async {
    DateTime nowTime = DateTime.now();

    // 1. 이미지 업로드
    String? imageUrl;

    if (storeImage != null) {
      final imgFile = storeImage;

      // 이미지 파일 업로드
      await supabase.storage.from('food_pick').upload(
            'stores/$nowTime.jpg',
            imgFile!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // 업로드 된 파일의 이미지 url 주소를 취득
      imageUrl = supabase.storage
          .from('food_pick')
          .getPublicUrl('stores/$nowTime.jpg');
    }

    // 2. 네이버 클라우드 플랫폼에서 지원하는 geocoding api을 활용하여 주소 -> 위도, 경도 변환
    // https://api.ncloud-docs.com/docs/ai-naver-mapsgeocoding-geocode
    final String apiUrl =
        'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=${_storeAddressController.text}';
    final apiResponse = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        "X-NCP-APIGW-API-KEY-ID": "pnojo08adn",
        "X-NCP-APIGW-API-KEY": "Hdul1HkVjhWYNyDKfFUiqNXuDILMRjxCYgUpBINc",
      },
    );

    if (apiResponse.statusCode == 200) {
      // api 호출 성공
      Map<String, dynamic> parsedJson = jsonDecode(apiResponse.body);

      if (parsedJson['meta']['totalCount'] == 0) {
        if (!mounted) return false;
        showSnackBar(context, '주소를 다시 입력해주세요.');
        return false;
      }

      // 위도, 경도 취득
      double latitude = double.parse(parsedJson['addresses'][0]['y']); // 위도값 추출
      double longitude =
          double.parse(parsedJson['addresses'][0]['x']); // 경도값 추출

      // supabase db set
      await supabase.from('food_store').insert(
            FoodStoreModel(
              storeName: _storeNameController.text,
              storeAddress: _storeAddressController.text,
              storeComment: _storeCommentController.text,
              uid: supabase.auth.currentUser!.id,
              storeImgUrl: imageUrl,
              latitude: latitude,
              longitude: longitude,
            ).toMap(),
          );

      return true;
    } else {
      // api 호출 실패
      return false;
    }
  }
}
