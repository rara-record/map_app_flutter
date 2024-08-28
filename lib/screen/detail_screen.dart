import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_app/model/food_store.dart';
import 'package:map_app/widget/appbar.dart';
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
  final formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  File? storeImage; // 갤러리에서 새로 선택한 맛집정보 이미지

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.foodStoreModel.storeName,
        isLeading: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoreImg(),
                const SizedBox(height: 16),
                const SectionText(
                    text: '맛집 위치 (도로명 주소)', textColor: Colors.black),
                const SizedBox(height: 8),
                ReadOnlyText(title: widget.foodStoreModel.storeName),
                const SizedBox(height: 16),
                const SectionText(text: '맛집 공유자', textColor: Colors.black),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                const SectionText(text: '메모', textColor: Colors.black),
                const SizedBox(height: 8),
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
}
