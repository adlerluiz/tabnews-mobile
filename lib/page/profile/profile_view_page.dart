import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tabnews/builder/generate_content.dart';
import 'package:tabnews/builder/loading_content_image.dart';
import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/model/content.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/api_user.dart';

class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({super.key, required this.ownerUsername});

  final String ownerUsername;

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  ApiUser apiUser = ApiUser();
  ApiContent apiContent = ApiContent();

  final PagingController<int, dynamic> _contentListController =
      PagingController(firstPageKey: 1);

  Future<void> _fetchContentList(int pageKey) async {
    try {
      final contentList =
          await apiContent.getByUser(widget.ownerUsername, pagina: pageKey);

      final isLastPage = contentList.length != constants.pageSize;

      if (isLastPage) {
        _contentListController.appendLastPage(contentList);
      } else {
        final nextPageKey = pageKey + 1;
        _contentListController.appendPage(contentList, nextPageKey);
      }
    } catch (error) {
      _contentListController.error = error;
    }
  }

  @override
  void initState() {
    super.initState();

    _contentListController.addPageRequestListener(_fetchContentList);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Atividades de ${widget.ownerUsername}',
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.fade,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(
            _contentListController.refresh,
          ),
          child: PagedListView(
            pagingController: _contentListController,
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
              firstPageProgressIndicatorBuilder: (context) =>
                  const LoadingContentImageBuilder(),
              itemBuilder: (context, data, index) {
                final Content item = Content.fromJson(data);
                return GenerateContentBuilder(
                  contentData: item,
                  index: index,
                  showUsername: false,
                );
              },
            ),
          ),
        ),
      );
}
