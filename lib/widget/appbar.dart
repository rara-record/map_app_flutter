import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isLeading; // 백버튼 존재 여부
  final Function? onTabBackButton; // 뒤로가기 버튼 액션 정의
  final List<Widget>? actions; // 앱바 우측에 버튼이 필요할 때 정의

  const CommonAppBar({
    super.key,
    required this.title,
    required this.isLeading,
    this.onTabBackButton,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 48,
      automaticallyImplyLeading: isLeading, // 뒤로가기 여부
      titleSpacing: isLeading ? 0 : 16,
      scrolledUnderElevation: 3, // 쓰면 조금 부드러움
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: isLeading
          ? GestureDetector(
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onTap: () {
                onTabBackButton != null
                    ? onTabBackButton!.call()
                    : Navigator.pop(context);
              })
          : null, // 커스텀 위젯
      elevation: 1, // 입체감 조정
      actions: actions,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
