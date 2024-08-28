import 'package:flutter/material.dart';
import 'package:map_app/model/food_store.dart';
import 'package:map_app/widget/appbar.dart';

// 검색 결과 화면
class SearchResultScreen extends StatefulWidget {
  final List<FoodStoreModel> listFoodStore;
  const SearchResultScreen({super.key, required this.listFoodStore});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CommonAppBar(title: '검색 결과', isLeading: true),
      body: Center(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
