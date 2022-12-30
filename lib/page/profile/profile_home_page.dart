import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tabnews/builder/loading_content_image.dart';
import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/model/user.dart';
import 'package:tabnews/page/content/content_form_page.dart';
import 'package:tabnews/page/login_page.dart';
import 'package:tabnews/page/settings_page.dart';
import 'package:tabnews/page/widgets/box_generate_content_widget.dart';
import 'package:tabnews/page/widgets/tooltip_tab_counter_widget.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/api_user.dart';
import 'package:tabnews/service/authenticated_http.dart';
import 'package:tabnews/service/storage.dart';

class ProfileHomePage extends StatefulWidget {
  const ProfileHomePage({super.key});

  @override
  State<ProfileHomePage> createState() => _ProfileHomePageState();
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  StorageService storage = StorageService();
  ApiUser apiUser = ApiUser();
  ApiContent apiContent = ApiContent();
  AuthenticatedHttpClient auth = AuthenticatedHttpClient();

  final PagingController<int, dynamic> _contentListController = 
      PagingController(firstPageKey: 1);

  ValueNotifier<bool> valueNotifierIsLogged = ValueNotifier(false);

  late String username = '';

  Future<void> getUsername() async {
    username = await storage.sharedPreferencesGet('user_username', '');
    setState(() {});
  }

  Future<void> checkIsLogged() async {
    valueNotifierIsLogged.value = await auth.isLogged();
  }

  Future<void> _fetchContentList(int pageKey) async {
    try {
      final List<dynamic> contentList = 
          await apiContent.getByUser(username, pagina: pageKey);

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
    getUsername();
    checkIsLogged();
    _contentListController.addPageRequestListener(_fetchContentList);
  }

  Future<dynamic> getData() async {
    try {
      if (!await auth.isLogged()) {
        return;
      }

      valueNotifierIsLogged.value = true;
      return await apiUser.getMe();
    } catch (e) {
      valueNotifierIsLogged.value = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: const Text(
            'Perfil',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            IconButton(
              tooltip: 'Configurações',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: valueNotifierIsLogged,
              builder: (context, value, child) => Visibility(
                visible: value,
                child: IconButton(
                  onPressed: () {
                    auth.logout();
                    valueNotifierIsLogged.value = false;
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.exit_to_app_outlined,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final User data = User.fromJson(snapshot.data);

                return Center(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                      ),
                      SizedBox(
                        width: 65,
                        height: 65,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '${data.username}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${data.email}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TooltipTabCounterWidget(
                            message: 'TabCoins',
                            tabCount: data.tabcoins.toString(),
                            color: Colors.blue,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                          ),
                          TooltipTabCounterWidget(
                            message: 'TabCash',
                            tabCount: data.tabcash.toString(),
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                      ),
                      Expanded(
                        child: BoxGenerateContentWidget(
                          pagingController: _contentListController,
                          showUserName: false,
                          noItemsFoundIndicatorBuilder: (context) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Nenhum conteúdo encontrado',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                    'Você ainda não fez nenhuma publicação.'),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Publicar novo conteúdo'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (context) => const ContentFormPage(),
                                      ),
                                    ).then((params) {
                                      _contentListController.refresh();
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        'Para ver seu perfil, é necessário estar logado'),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (context) => const LoginPage(),
                          ),
                        ).then((_) {
                          _contentListController.refresh();
                          getUsername();
                        });
                      },
                      child: const Text('Logar'),
                    ),
                  ],
                ),
              );
            }

            return const LoadingContentImageBuilder();
          },
        ),
      );
}
