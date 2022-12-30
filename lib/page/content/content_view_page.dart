import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tabnews/builder/loading_content_image.dart';
import 'package:tabnews/model/content.dart';
import 'package:tabnews/page/content/content_form_comment_page.dart';
import 'package:tabnews/page/content/content_form_page.dart';
import 'package:tabnews/page/content/content_widgets/launch_url_wrapper.dart';
import 'package:tabnews/page/content/content_widgets/post_body.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/messenger.dart';
import 'package:tabnews/service/storage.dart';
import 'package:tabnews/service/user_features.dart';

class ContentViewPage extends StatefulWidget {
  const ContentViewPage({
    required this.contentData,
    super.key,
  });

  final Content contentData;

  @override
  State<ContentViewPage> createState() => _ContentViewPageState();
}

class _ContentViewPageState extends State<ContentViewPage> {
  StorageService storage = StorageService();

  MessengerService messengerService = MessengerService();
  UserFeaturesService userFeaturesService = UserFeaturesService();

  ApiContent apiContent = ApiContent();

  final ScrollController pageScrollController = ScrollController();

  ValueNotifier<bool> hasScrolled = ValueNotifier(false);

  int indexFavorite = -1;

  List<dynamic> dataList = [];

  late bool showResponseButton = true;

  bool canEdit = false;

  bool showMessagePreventAccidentalTabcoinTapPost = false;
  bool showMessagePreventAccidentalTabcoinTapComment = false;

  @override
  void initState() {
    super.initState();

    pageScrollController.addListener(() {
      if (pageScrollController.offset >= 50) {
        hasScrolled.value = true;
      } else {
        hasScrolled.value = false;
      }
    });
    getParams();
    getFavoriteList();
    LaunchUrlWrapper.getTypeLaunchMode(storage);
  }

  Future<void> getParams() async {
    final String userId = await storage.sharedPreferencesGet('user_id', '');

    final bool canEditAndDeleteContentOthers =
        await userFeaturesService.hasFeature('update:content:others');

    final String preventAccidentalTabcoinTap = await storage
        .sharedPreferencesGetString('prevent_accidental_tabcoin_tap', 'none');

    setState(() {
      showMessagePreventAccidentalTabcoinTapPost =
          preventAccidentalTabcoinTap == 'post' ||
              preventAccidentalTabcoinTap == 'all';

      showMessagePreventAccidentalTabcoinTapComment =
          preventAccidentalTabcoinTap == 'comment' ||
              preventAccidentalTabcoinTap == 'all';
    });

    if (userId == widget.contentData.ownerId! ||
        canEditAndDeleteContentOthers) {
      setState(() {
        canEdit = true;
      });
    }
  }

  Future<void> getFavoriteList() async {
    final result = await storage.sharedPreferencesGet('favorite_list', '[]');

    setState(() {
      dataList = jsonDecode(result);
    });
    indexFavorite = getIndexFromFavorite(widget.contentData.id!);
  }

  Future<void> removeFromFavorite(int index) async {
    dataList.removeAt(index);

    setState(() {
      indexFavorite = -1;
    });

    await storage.sharedPreferencesAddString(
        'favorite_list', jsonEncode(dataList));
  }

  Future<void> addToFavorite(Content content) async {
    dataList.add(content.toJson());
    setState(() {
      indexFavorite = getIndexFromFavorite(widget.contentData.id!);
    });

    await storage.sharedPreferencesAddString(
        'favorite_list', jsonEncode(dataList));
  }

  int getIndexFromFavorite(String id) {
    if (dataList.isNotEmpty) {
      for (var i = 0; i < dataList.length; i++) {
        final Content content = Content.fromJson(dataList[i]);
        if (id == content.id) {
          return i;
        }
      }
    }
    return -1;
  }

  Future<dynamic> getData() async {
    try {
      return await apiContent.get(
          widget.contentData.ownerUsername!, widget.contentData.slug!);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<void> removeContent() async {
    try {
      await apiContent.deleteContent(
          widget.contentData.ownerUsername!, widget.contentData.slug!);

      messengerService.show(context, text: 'Removido com sucesso!');
      Navigator.of(context).pop();
    } catch (e) {
      messengerService.show(context, text: e.toString());
    }
  }

  void selectMenuItem(int value) {
    switch (value) {
      case 0:
        //print(widget.contentData.toJson());
        if (widget.contentData.title == null) {
          Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
              builder: (context) => ContentFormCommentPage(
                id: widget.contentData.parentId!,
                title: '',
                body: widget.contentData.body!,
                slug: widget.contentData.slug!,
                isEdit: true,
              ),
            ),
          ).then((params) {
            setState(() {});
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
              builder: (context) => ContentFormPage(
                ownerUsername: widget.contentData.ownerUsername!,
                slug: widget.contentData.slug!,
              ),
            ),
          ).then((params) {
            setState(() {});
          });
        }
        break;

      case 1:
        showDialog<void>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Você tem certeza?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Você realmente deseja apagar esta publicação?'),
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
                  removeContent();
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
          titleSpacing: 0,
          title: ValueListenableBuilder(
            valueListenable: hasScrolled,
            builder: (context, value, child) => AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: value ? 1 : 0,
              child: Text(
                '${widget.contentData.title ?? widget.contentData.body}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Favorito',
              onPressed: () {
                if (indexFavorite != -1) {
                  removeFromFavorite(indexFavorite);
                } else {
                  addToFavorite(widget.contentData);
                }
              },
              icon: (indexFavorite != -1)
                  ? const Icon(
                      Icons.star_outlined,
                      color: Colors.amber,
                    )
                  : const Icon(
                      Icons.star_border_outlined,
                    ),
            ),
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
                            Icons.edit_outlined,
                            size: 19,
                          ),
                        ),
                        Text('Editar')
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
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
                          'Apagar',
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
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.contentData.title!,
                      textAlign: TextAlign.center,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                    ),
                    Image.asset(
                      'assets/images/error.png',
                      color: (Theme.of(context).brightness == Brightness.light)
                          ? Colors.black
                          : Colors.white,
                      width: 80,
                    ),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasData) {
              final Content data = Content.fromJson(snapshot.data);
              bool isComment = false;
              if (data.parentId != null) {
                isComment = true;
              }
              return PostBody(
                pageScrollController: pageScrollController,
                contentData: widget.contentData,
                isComment: isComment,
                data: data,
                apiContent: apiContent,
                messengerService: messengerService,
                preventAccidentalTabcoinTapPost:
                    showMessagePreventAccidentalTabcoinTapPost,
                preventAccidentalTabcoinTapComment:
                    showMessagePreventAccidentalTabcoinTapComment,
              );
            }
            return const LoadingContentImageBuilder();
          },
        ),
      );
}
