import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/page/widgets/box_generate_content_widget.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/api_user.dart';
import 'package:tabnews/service/messenger.dart';
import 'package:tabnews/service/user_features.dart';

class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({required this.ownerUsername, super.key});

  final String ownerUsername;

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  ApiUser apiUser = ApiUser();
  ApiContent apiContent = ApiContent();
  MessengerService messengerService = MessengerService();
  UserFeaturesService userFeaturesService = UserFeaturesService();

  bool canEdit = false;

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
    getParams();
    _contentListController.addPageRequestListener(_fetchContentList);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getParams() async {
    final bool canEditAndDeleteContentOthers =
        await userFeaturesService.hasFeature('update:content:others');

    if (canEditAndDeleteContentOthers) {
      setState(() {
        canEdit = true;
      });
    }
  }

  Future<void> banUser() async {
    try {
      await apiUser.banUser(widget.ownerUsername);
      _contentListController.refresh();
      messengerService.show(context, text: 'Usuário banido!');
    } catch (e) {
      messengerService.show(context, text: e.toString());
    }
  }

  void selectMenuItem(int value) {
    switch (value) {
      case 0:
        showDialog<void>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Atenção: Você está realizando um Nuke!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Deseja banir o usuário ${widget.ownerUsername} e desfazer todas as suas ações?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Não'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Sim'),
                onPressed: () {
                  Navigator.of(context).pop();
                  banUser();
                },
              ),
            ],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Atividades de ${widget.ownerUsername}',
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.fade,
          ),
          actions: [
            Visibility(
              visible: canEdit,
              child: PopupMenuButton(
                elevation: 3.2,
                onSelected: selectMenuItem,
                tooltip: 'Opções',
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.delete_outlined,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                        Text(
                          'Nuke',
                          style: TextStyle(color: Colors.redAccent),
                        )
                      ],
                    ),
                  ),
                ],
                child: const SizedBox(
                  width: 48,
                  child: Icon(
                    Icons.more_vert_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BoxGenerateContentWidget(
          pagingController: _contentListController,
          showUserName: false,
        ),
      );
}
