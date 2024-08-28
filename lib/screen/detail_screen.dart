import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_app/model/food_store.dart';
import 'package:map_app/widget/appbar.dart';
import 'package:map_app/widget/text_fields.dart';
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
  final TextEditingController _storeAddressController =
      TextEditingController(); // 주소
  final TextEditingController _userNameController =
      TextEditingController(); // 별명
  final TextEditingController _storeCommentController =
      TextEditingController(); // 메모

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
              children: [
                _buildStoreImg(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
