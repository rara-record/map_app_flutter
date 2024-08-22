import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isLeading; // 뒤로가기 버튼 존재 여부
  final Function? onTapBackButton; // 뒤로가기 버튼 액션 정의
  final List<Widget>? actions; // 앱바 우측에 버튼들 필요할 때 정의

  const CommonAppBar(
      {super.key,
      required this.title,
      required this.isLeading,
      this.onTapBackButton,
      this.actions});

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        toolbarHeight: 48,
        automaticallyImplyLeading: isLeading,
        titleSpacing: isLeading ? 0 : 16,
        scrolledUnderElevation: 3,
        backgroundColor: Colors.white,
        leading: isLeading
            ? GestureDetector(
                child: const Icon(Icons.arrow_back, color: Colors.black),
                onTap: () {
                  onTapBackButton != null
                      ? onTapBackButton!.call()
                      : Navigator.pop(context);
                },
              )
            : null,
        elevation: 1,
        actions: actions,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ));
  }
}
