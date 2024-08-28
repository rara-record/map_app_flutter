import 'package:flutter/material.dart';
import 'package:map_app/model/favorite.dart';
import 'package:map_app/model/food_store.dart';
import 'package:map_app/widget/appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 검색 결과 화면
class SearchResultScreen extends StatefulWidget {
  final List<FoodStoreModel> listFoodStore;

  const SearchResultScreen({super.key, required this.listFoodStore});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final supabase = Supabase.instance.client;
  List<FavoriteModel> listFavorite = []; // 즐겨찾기 정보들

  @override
  void initState() {
    _getMyFavorite();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '검색 결과', isLeading: true),
      body: widget.listFoodStore.isNotEmpty
          ? ListView.builder(
              itemCount: widget.listFoodStore.length,
              itemBuilder: (context, index) {
                FoodStoreModel foodStoreModel = widget.listFoodStore[index];
                return _buildListItemFoodStore(foodStoreModel);
              },
            )
          : const Text('검색 결과가 없습니다.'),
    );
  }

  // 맛집 정보 리스트 아이템 생성
  Widget _buildListItemFoodStore(FoodStoreModel foodStoreModel) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(foodStoreModel.storeName),
              _buildFavoriteIcon(foodStoreModel),
            ],
          ),
        ],
      ),
    );
  }

  // 찜하기 여부 아이콘 생성
  _buildFavoriteIcon(FoodStoreModel foodStoreModel) {
    bool isFavorite = false;

    for (FavoriteModel favoriteModel in listFavorite) {
      // 찜하기 이력 검사
      if (favoriteModel.id == foodStoreModel.id) {
        isFavorite = true;
        break;
      }
    }

    if (!isFavorite) {
      return const Icon(Icons.star_border_outlined, size: 32);
    } else {
      return const Icon(Icons.star, size: 32);
    }
  }

  Future<void> _getMyFavorite() async {
    if (widget.listFoodStore.isEmpty) return;

    // 현재 내 찜하기 이력 가져오기
    final myFavoriteMap = await supabase
        .from('favorite')
        .select()
        .eq('favorite_uid', supabase.auth.currentUser!.id);

    setState(() {
      listFavorite =
          myFavoriteMap.map((e) => FavoriteModel.fromJSON(e)).toList();
    });
  }
}
