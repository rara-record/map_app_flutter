import 'package:daum_postcode_search/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:map_app/widget/appbar.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';

// 다음 주소 검색 API
class SearchAddress extends StatefulWidget {
  const SearchAddress({super.key});

  @override
  State<SearchAddress> createState() => _SearchAddressState();
}

class _SearchAddressState extends State<SearchAddress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CommonAppBar(
          title: '주소 검색',
          isLeading: true,
        ),
        body: DaumPostcodeSearch(
          webPageTitle: '주소 검색',
          initialOption: InAppWebViewGroupOptions(),
          onConsoleMessage: (controller, consoleMessage) {},
          onLoadError: (controller, url, code, message) {},
          onProgressChanged: (controller, progress) {},
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT,
            );
          },
        ));
  }
}
