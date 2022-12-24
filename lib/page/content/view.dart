import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:share_plus/share_plus.dart';
import 'package:tabnews/builder/generate_user_link.dart';
import 'package:tabnews/builder/image_view.dart';
import 'package:tabnews/builder/loading_content_image.dart';
import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/model/content.dart';
import 'package:tabnews/page/content/form.dart';
import 'package:tabnews/page/content/form_comment.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/messenger.dart';
import 'package:tabnews/service/storage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

//GlobalKey commentsKey = GlobalKey();

class ContentViewPage extends StatefulWidget {
  const ContentViewPage({super.key, required this.contentData});

  final Content contentData;

  @override
  State<ContentViewPage> createState() => _ContentViewPageState();
}

class _ContentViewPageState extends State<ContentViewPage> {
  StorageService storage = StorageService();

  MessengerService messengerService = MessengerService();

  ApiContent apiContent = ApiContent();

  final ScrollController? pageScrollController = ScrollController();

  ValueNotifier<bool> hasScrolled = ValueNotifier(false);

  int indexFavorite = -1;

  List dataList = [];

  late bool showResponseButton = true;

  ValueNotifier<bool> canComment = ValueNotifier(false);

  LaunchMode launchUrlMode = LaunchMode.inAppWebView;

  bool canEdit = false;

  @override
  void initState() {
    super.initState();

    pageScrollController!.addListener(() {
      if (pageScrollController!.offset >= 50) {
        hasScrolled.value = true;
      } else {
        hasScrolled.value = false;
      }
    });
    getParams();
    getFavoriteList();
    getTypeLaunchMode();
  }

  Future<void> getParams() async {
    final String userId = await storage.sharedPreferencesGet('user_id', '');
    if (userId == widget.contentData.ownerId!) {
      setState(() {
        canEdit = true;
      });
    }
  }

  Future<void> getTypeLaunchMode() async {
    final typeLaunchUrlMode =
        await storage.sharedPreferencesGet('launch_url_mode', 'internal');

    if (typeLaunchUrlMode == 'internal') {
      launchUrlMode = LaunchMode.inAppWebView;
    } else {
      launchUrlMode = LaunchMode.externalApplication;
    }
  }

  getFavoriteList() async {
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
      canComment.value = true;
      return await apiContent.get(
          widget.contentData.ownerUsername!, widget.contentData.slug!);
    } catch (e) {
      canComment.value = false;
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

  Future<dynamic> getCommentList() async {
    final List commentListData = await apiContent.getComments(
        widget.contentData.ownerUsername!, widget.contentData.slug!);
    return commentListData;
  }

  void selectMenuItem(value) {
    switch (value) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentFormPage(
              ownerUsername: widget.contentData.ownerUsername!,
              slug: widget.contentData.slug!,
            ),
          ),
        ).then((params) {
          setState(() {});
        });
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
            if (data.parentId != null) isComment = true;

            return Scrollbar(
              child: SingleChildScrollView(
                controller: pageScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(),
                      child: Row(
                        children: [
                          GenerateUserLinkBuilder(
                              ownerUsername: widget.contentData.ownerUsername!),
                          const Text(' • '),
                          Text(
                            timeago.format(
                                DateTime.parse(widget.contentData.publishedAt!),
                                locale: 'pt_BR'),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.grey),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 4),
                        child: isComment
                            ? MarkdownBody(
                                data: '💬 ${data.body}',
                                onTapLink: (text, href, title) {
                                  _launchUrl(Uri.parse(href!));
                                },
                              )
                            : Text(
                                '${data.title}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: isComment
                                      ? FontWeight.normal
                                      : FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                    Visibility(
                      visible: !isComment,
                      child: showMarkdownData(data.body!),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                    ),
                    Visibility(
                      visible: data.sourceUrl != null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.link_rounded,
                              size: 18,
                            ),
                          ),
                          const Text(
                            'Fonte:',
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _launchUrl(Uri.parse(data.sourceUrl!));
                              },
                              child: Text(
                                ' ${data.sourceUrl}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                ),
                                softWrap: true,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    /*const Padding(
                      padding: EdgeInsets.only(top: 2),
                    ),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Creditar TabCoin',
                              onPressed: () async {
                                await thumbPost('credit');
                              },
                              icon: const Icon(Icons.keyboard_arrow_up_rounded),
                            ),
                            Text(
                              '${data.tabcoins}',
                            ),
                            IconButton(
                              tooltip: 'Debitar TabCoin',
                              onPressed: () async {
                                await thumbPost('debit');
                              },
                              icon:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          style: ButtonStyle(
                            textStyle: const MaterialStatePropertyAll(
                              TextStyle(fontSize: 13),
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              (Theme.of(context).brightness == Brightness.light)
                                  ? Colors.black
                                  : Colors.white70,
                            ),
                          ),
                          onPressed: () {
                            /*Scrollable.ensureVisible(
                              commentsKey.currentContext!,
                              curve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 300),
                            );*/
                          },
                          icon: const Icon(
                            Icons.mode_comment_outlined,
                            size: 18,
                          ),
                          label: Text(
                            '${data.childrenDeepCount}',
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(),
                        ),
                        IconButton(
                          style: const ButtonStyle(
                            textStyle: MaterialStatePropertyAll(
                              TextStyle(fontSize: 13),
                            ),
                          ),
                          onPressed: () {
                            share(widget.contentData);
                          },
                          icon: const Icon(
                            Icons.share,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: widget.contentData.childrenDeepCount! > 0,
                      child: const Divider(height: 1),
                    ),
                    Container(
                      //key: commentsKey,
                      key: ValueKey(widget.contentData.id),
                      //color: Colors.white,
                      child: FutureBuilder(
                        future: getCommentList(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final data = snapshot.data;

                            if (data.length != 0) {
                              return boxCommentList(data);
                            }

                            return Container();
                          }
                          return const LoadingContentImageBuilder(size: 30);
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 55),
                    ),
                  ],
                ),
              ),
            );
          }
          return const LoadingContentImageBuilder();
        },
      ),
      bottomSheet: ValueListenableBuilder(
        valueListenable: canComment,
        builder: (context, value, child) => Visibility(
            visible: value,
            child: SizedBox(
              height: 50,
              width: screenWidth,
              child: boxComment(),
            ),
          ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: launchUrlMode)) {
      throw 'Erro ao abrir $url';
    }
  }

  Widget boxComment() => GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentFormCommentPage(
              id: widget.contentData.id!,
              title: widget.contentData.title!,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(6),
          ),
          border: Border.all(
            color: const Color.fromARGB(30, 158, 158, 158),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.only(left: 15, top: 15),
          child: Text(
            'Responder',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );

  Widget boxCommentList(data, {isChild = false}) => ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = Content.fromJson(data[index]);
        final hasChildren = item.children!.isNotEmpty;

        return Card(
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isChild
                      ? const Color.fromARGB(100, 158, 158, 158)
                      : Colors.transparent,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 39,
                  child: Column(
                    children: [
                      IconButton(
                        tooltip: 'Creditar TabCoin',
                        onPressed: () async {
                          await thumbComment(item, 'credit');
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_up_rounded,
                        ),
                      ),
                      Text(
                        '${item.tabcoins}',
                        softWrap: true,
                      ),
                      IconButton(
                        tooltip: 'Debitar TabCoin',
                        onPressed: () async {
                          await thumbComment(item, 'debit');
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                      ),
                      Row(
                        children: [
                          GenerateUserLinkBuilder(
                              ownerUsername: item.ownerUsername!),
                          const Text(' • '),
                          Expanded(
                            child: Text(
                              timeago.format(DateTime.parse(item.publishedAt!),
                                  locale: 'pt_BR'),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: true,
                              style: const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      showMarkdownData(item.body!),
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                      ),
                      SizedBox(
                        height: 32,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContentFormCommentPage(
                                  id: item.id!,
                                  title: item.body!,
                                ),
                              ),
                            );
                          },
                          child: const Text('Responder'),
                        ),
                      ),
                      Visibility(
                        visible: hasChildren,
                        child: boxCommentList(item.children, isChild: true),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 3),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

  void share(Content data) {
    final user = data.ownerUsername;
    final slug = data.slug;
    final title = data.title;

    Share.share('${constants.baseUrl}/$user/$slug', subject: '$title');
  }

  Widget showMarkdownData(body) => MarkdownBody(
      data: body,
      selectable: true,
      onTapLink: (text, href, title) {
        _launchUrl(Uri.parse(href!));
      },
      blockSyntaxes: [
        ...md.ExtensionSet.gitHubWeb.blockSyntaxes,
        ...md.ExtensionSet.gitHubFlavored.blockSyntaxes
      ],
      inlineSyntaxes: [
        ...md.ExtensionSet.gitHubWeb.inlineSyntaxes,
        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
      ],
      imageBuilder: (uri, title, alt) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageViewBuilder(
                  url: '$uri',
                  title: '$title',
                ),
              ),
            );
          },
          child: Image.network(
            uri.toString(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return const Padding(
                padding: EdgeInsets.all(5),
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(),
                ),
              );
              //return const LoadingContentImageHelper(size: 40);
            },
            errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Image.asset('assets/images/error.png', width: 60),
                      const Text(
                        'Não foi possível carregar esta imagem!',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ),
        ),
    );

  Future<void> thumbPost(String transactionType) async {
    try {
      await apiContent.postTabcoinTransaction(
        widget.contentData.ownerUsername!,
        widget.contentData.slug!,
        transactionType: transactionType,
      );

      messengerService.show(context, text: 'Feito!');
    } catch (e) {
      messengerService.show(context, text: e.toString());
    }
  }

  Future<void> thumbComment(Content item, String transactionType) async {
    try {
      await apiContent.postTabcoinTransaction(
        item.ownerUsername!,
        item.slug!,
        transactionType: transactionType,
      );
      messengerService.show(context, text: 'Feito!');
    } catch (e) {
      messengerService.show(context, text: e.toString());
    }
  }
}
