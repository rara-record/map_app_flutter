import 'package:flutter/material.dart';
import 'package:map_app/common/snackbar_uril.dart';
import 'package:map_app/model/favorite.dart';
import 'package:map_app/model/food_store.dart';
import 'package:map_app/model/users.dart';
import 'package:map_app/widget/appbar.dart';
import 'package:map_app/widget/buttons.dart';
import 'package:map_app/widget/text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 상세 화면
class DetailScreen extends StatefulWidget {
  final FoodStoreModel foodStoreModel;
  const DetailScreen({super.key, required this.foodStoreModel});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final supabase = Supabase.instance.client;
  String? _uploaderName; // 맛집 공유자 이름
  bool isFavorite = false; // 사용자 찜하기 여부

  @override
  void initState() {
    _getUploaderUserName();
    _getFavorite();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        Navigator.pop(context, 'back_from_detail');
      },
      child: Scaffold(
        appBar: CommonAppBar(
          title: widget.foodStoreModel.storeName,
          isLeading: true,
          onTabBackButton: () {
            Navigator.pop(context, 'back_from_detail');
          },
        ),
        body: Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지
                _buildStoreImg(),

                // 맛집 정보
                const SizedBox(height: 16),
                const SectionText(
                    text: '맛집 위치 (도로명 주소)', textColor: Colors.black),
                const SizedBox(height: 8),
                ReadOnlyText(title: widget.foodStoreModel.storeName),
                const SizedBox(height: 16),
                const SectionText(text: '맛집 공유자', textColor: Colors.black),
                const SizedBox(height: 8),
                ReadOnlyText(title: _uploaderName ?? ''),
                const SizedBox(height: 16),
                const SectionText(text: '메모', textColor: Colors.black),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      ReadOnlyText(title: widget.foodStoreModel.storeComment),
                ),
                const SizedBox(height: 16),
                // 찜하기 or 취소 버튼
                isFavorite
                    ? SizedBox(
                        width: double.infinity,
                        height: 69,
                        child: ElevatedButtonCustom(
                            text: '찜하기 취소',
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            onPressed: () async {
                              try {
                                // 찜하기 정보 삭제
                                await supabase
                                    .from('favorite')
                                    .delete()
                                    .eq('food_store_id',
                                        widget.foodStoreModel.id!)
                                    .eq('favorite_uid',
                                        supabase.auth.currentUser!.id);
                                // 찜하기 정보 다시 가져오기
                                _getFavorite();
                              } catch (error) {
                                if (!context.mounted) return;
                                showSnackBar(context, '찜하기 취소가 실패했어요.');
                              }
                            }),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 69,
                        child: ElevatedButtonCustom(
                            text: '찜하기',
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            onPressed: () async {
                              // 찜하기 정보 추가
                              try {
                                await supabase
                                    .from('favorite')
                                    .upsert(FavoriteModel(
                                      foodStoreId: widget.foodStoreModel.id!,
                                      favoriteUid:
                                          supabase.auth.currentUser!.id,
                                    ).toMap());

                                // 찜하기 정보 다시 가져오기
                                _getFavorite();
                              } catch (error) {
                                if (!context.mounted) return;
                                showSnackBar(context, '찜하기가 실패했어요');
                              }
                            }),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 맛집 이미지
  Widget _buildStoreImg() {
    if (widget.foodStoreModel.storeImgUrl != null) {
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
        child: Image.network(widget.foodStoreModel.storeImgUrl!,
            fit: BoxFit.cover),
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

  // 공유자 이름 가져오기 TODO: 전역 상태
  Future<void> _getUploaderUserName() async {
    final userMap = await supabase
        .from('user')
        .select()
        .eq('uid', widget.foodStoreModel.uid);
    UserModel userModel =
        userMap.map((user) => UserModel.fromJSON(user)).single;
    setState(() {
      _uploaderName = userModel.name;
    });
  }

  // 찜하기 정보 가져오기
  Future<void> _getFavorite() async {
    // 현재 찜하기 정보 가져오기 (내가 찜한 상태)
    final favoriteMap = await supabase
        .from('favorite')
        .select()
        .eq('food_store_id', widget.foodStoreModel.id!)
        .eq('favorite_uid', supabase.auth.currentUser!.id);

    // 찜하기 정보가 있으면 찜하기 상태로 변경
    setState(() {
      favoriteMap.isNotEmpty ? isFavorite = true : isFavorite = false;
    });
  }
}
