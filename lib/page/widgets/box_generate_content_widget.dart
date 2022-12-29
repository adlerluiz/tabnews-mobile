import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tabnews/builder/generate_content.dart';
import 'package:tabnews/builder/loading_content_image.dart';
import 'package:tabnews/model/content.dart';

class BoxGenerateContentWidget extends StatelessWidget {
  final bool showTabCoins;
  final bool showComments;
  final bool showUserName;
  final String filterText;
  final PagingController<int, dynamic> pagingController;

  final WidgetBuilder? noItemsFoundIndicatorBuilder;

  const BoxGenerateContentWidget({
    required this.pagingController,
    super.key,
    this.showTabCoins = true,
    this.showComments = true,
    this.showUserName = true,
    this.filterText = '',
    this.noItemsFoundIndicatorBuilder,
  });

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(
          pagingController.refresh,
        ),
        child: Center(
          child: PagedListView(
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
              noItemsFoundIndicatorBuilder: noItemsFoundIndicatorBuilder,
              firstPageProgressIndicatorBuilder: (context) => const LoadingContentImageBuilder(),
              itemBuilder: (context, data, index) {
                final Content item = Content.fromJson(data);

                if ((filterText.trim().isNotEmpty) && (!item.matchFilter(filterText.trim()))) {
                  return const SizedBox.shrink();
                }

                return GenerateContentBuilder(
                  contentData: item,
                  index: index,
                  showComments: showComments,
                  showTabcoins: showTabCoins,
                  showUsername: showUserName,
                );
              },
            ),
          ),
        ),
      );
}
