import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tabnews/builder/generate_content.dart';
import 'package:tabnews/builder/loading_content_image.dart';
import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/model/content.dart';
import 'package:tabnews/page/content/content_form_page.dart';
import 'package:tabnews/page/profile/profile_home_page.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/storage.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({
    required this.appName,
    super.key,
  });

  final String appName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  StorageService storage = StorageService();

  TabController? _navigationTabController;

  int _navigationTabPageIndex = 1;

  final PagingController<int, dynamic> _favoritePagingController =
      PagingController(firstPageKey: 1);

  final PagingController<int, dynamic> _relevantPagingController =
      PagingController(firstPageKey: 1);

  final PagingController<int, dynamic> _recentPagingController =
      PagingController(firstPageKey: 1);

  ApiContent apiContent = ApiContent();

  // Filter controller
  TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();

    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());

    _navigationTabController = TabController(
        length: 3, initialIndex: _navigationTabPageIndex, vsync: this);

    _favoritePagingController.addPageRequestListener(_fetchFavoritePage);

    _relevantPagingController.addPageRequestListener(_fetchRelevantPage);

    _recentPagingController.addPageRequestListener(_fetchRecentPage);

    _navigationTabController!.addListener(() {
      setState(() {
        _navigationTabPageIndex = _navigationTabController!.index;

        if (_navigationTabController!.index == 0) {
          _favoritePagingController.refresh();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _navigationTabController!.dispose();
    _favoritePagingController.dispose();
    _relevantPagingController.dispose();
    _recentPagingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _fetchFavoritePage(int pageKey) async {
    try {
      var contentList =
          await storage.sharedPreferencesGet('favorite_list', '[]');

      contentList = jsonDecode(contentList).reversed.toList();

      final isLastPage = contentList.length != constants.pageSize;

      if (isLastPage) {
        _favoritePagingController.appendLastPage(contentList);
      } else {
        final nextPageKey = pageKey + 1;
        _favoritePagingController.appendPage(contentList, nextPageKey);
      }
    } catch (error) {
      _favoritePagingController.error = error;
    }
  }

  Future<void> _fetchRelevantPage(int pageKey) async {
    try {
      final contentList =
          await apiContent.getList(pagina: pageKey, estrategia: 'relevant');

      final isLastPage = contentList.length != constants.pageSize;

      if (isLastPage) {
        _relevantPagingController.appendLastPage(contentList);
      } else {
        final nextPageKey = pageKey + 1;
        _relevantPagingController.appendPage(contentList, nextPageKey);
      }
    } catch (error) {
      _relevantPagingController.error = error;
    }
  }

  Future<void> _fetchRecentPage(int pageKey) async {
    try {
      final contentList = await apiContent.getList(pagina: pageKey);

      final isLastPage = contentList.length != constants.pageSize;

      if (isLastPage) {
        _recentPagingController.appendLastPage(contentList);
      } else {
        final nextPageKey = pageKey + 1;
        _recentPagingController.appendPage(contentList, nextPageKey);
      }
    } catch (error) {
      _recentPagingController.error = error;
    }
  }

  void selectTab(int index) {
    setState(() {
      _navigationTabPageIndex = index;
    });

    if (!mounted) {
      return;
    }

    _navigationTabController?.animateTo(index);
  }

  bool isFiltering = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: isFiltering
              ? IconButton(
                  onPressed: () => setState(() {
                    // Hide and reset filter
                    isFiltering = false;
                    filterController.text = '';
                  }),
                  icon: const Icon(Icons.close),
                )
              : IconButton(
                  onPressed: () => setState(() {
                    isFiltering = true;
                  }),
                  icon: const Icon(Icons.search),
                ),
          title: isFiltering
              ? TextField(
                  controller: filterController,
                  onChanged: (newText) => setState(() {}),
                )
              : Text(widget.appName),
          actions: [
            IconButton(
              tooltip: 'Perfil',
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (context) => const ProfileHomePage(),
                  ),
                );
              },
            )
          ],
        ),
        body: TabBarView(
          controller: _navigationTabController,
          children: [
            RefreshIndicator(
              onRefresh: () => Future.sync(
                _favoritePagingController.refresh,
              ),
              child: PagedListView(
                pagingController: _favoritePagingController,
                builderDelegate: PagedChildBuilderDelegate<dynamic>(
                  noItemsFoundIndicatorBuilder: (context) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Nenhum favorito encontrado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Os favoritos são salvos somente no seu celular',
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                  firstPageProgressIndicatorBuilder: (context) =>
                      const LoadingContentImageBuilder(),
                  itemBuilder: (context, data, index) {
                    final Content item = Content.fromJson(data);
                    return GenerateContentBuilder(
                      contentData: item,
                      index: index,
                      showTabcoins: false,
                      showComments: false,
                    );
                  },
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: () => Future.sync(
                _relevantPagingController.refresh,
              ),
              child: Center(
                child: PagedListView(
                  pagingController: _relevantPagingController,
                  builderDelegate: PagedChildBuilderDelegate<dynamic>(
                    firstPageProgressIndicatorBuilder: (context) =>
                        const LoadingContentImageBuilder(),
                    itemBuilder: (context, data, index) {
                      final Content item = Content.fromJson(data);

                      if (!item.matchFilter(filterController.text)) {
                        return const SizedBox.shrink();
                      }

                      return GenerateContentBuilder(
                        contentData: item,
                        index: index,
                      );
                    },
                  ),
                ),
              ),
            ),
            RefreshIndicator(
              child: Center(
                child: PagedListView(
                  pagingController: _recentPagingController,
                  builderDelegate: PagedChildBuilderDelegate<dynamic>(
                    firstPageProgressIndicatorBuilder: (context) =>
                        const LoadingContentImageBuilder(),
                    itemBuilder: (context, item, index) {
                      item = Content.fromJson(item);

                      return GenerateContentBuilder(
                        contentData: item,
                        index: index,
                      );
                    },
                  ),
                ),
              ),
              onRefresh: () => Future.sync(
                _recentPagingController.refresh,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Publicar novo conteúdo',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                builder: (context) => const ContentFormPage(),
              ),
            );
          },
          child: const Icon(Icons.post_add_outlined),
        ),
        bottomNavigationBar: NavigationBar(
          height: 62,
          onDestinationSelected: selectTab,
          selectedIndex: _navigationTabPageIndex,
          destinations: [
            NavigationDestination(
              icon: (_navigationTabPageIndex == 0)
                  ? const Icon(Icons.star)
                  : const Icon(Icons.star_border),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: (_navigationTabPageIndex == 1)
                  ? const Icon(Icons.radar)
                  : const Icon(Icons.radar_outlined),
              label: 'Relevantes',
            ),
            NavigationDestination(
              icon: (_navigationTabPageIndex == 2)
                  ? const Icon(Icons.timelapse)
                  : const Icon(Icons.timelapse_outlined),
              label: 'Recentes',
            ),
          ],
        ),
      );
}
