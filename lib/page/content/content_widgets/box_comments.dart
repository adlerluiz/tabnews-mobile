import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabnews/builder/generate_user_link.dart';
import 'package:tabnews/model/content.dart';
import 'package:tabnews/page/content/content_form_comment_page.dart';
import 'package:tabnews/page/content/content_view_page.dart';
import 'package:tabnews/page/content/content_widgets/markdown_data.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/messenger.dart';
import 'package:timeago/timeago.dart' as timeago;

class BoxComments extends StatelessWidget {
  final List<dynamic> data;
  final bool isChild;

  final ApiContent apiContent;
  final MessengerService messengerService;

  final bool preventAccidentalTabcoinTapComment;

  const BoxComments(
    this.data, {
    required this.apiContent,
    required this.messengerService,
    required this.preventAccidentalTabcoinTapComment,
    this.isChild = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = Content.fromJson(data[index]);
          final hasChildren = item.children!.isNotEmpty;

          return Card(
            elevation: 0,
            child: DecoratedBox(
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
                          tooltip: 'Adicionar TabCoin',
                          onPressed: () async {
                            if (preventAccidentalTabcoinTapComment) {
                              showPreventTabcoinTap(item, 'credit', context);
                            } else {
                              await thumbComment(
                                item,
                                'credit',
                                context,
                              );
                            }
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
                          tooltip: 'Subtrair TabCoin',
                          onPressed: () async {
                            if (preventAccidentalTabcoinTapComment) {
                              showPreventTabcoinTap(item, 'debit', context);
                            } else {
                              await thumbComment(
                                item,
                                'debit',
                                context,
                              );
                            }
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
                              child: Tooltip(
                                message: DateFormat(
                                        "EEEE, dd 'de' MMM 'de' yyyy HH:mm")
                                    .format(DateTime.parse(item.publishedAt!)),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (context) => ContentViewPage(
                                          contentData: item,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    timeago.format(
                                        DateTime.parse(item.publishedAt!),
                                        locale: 'pt_BR'),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        MarkdownData(item.body!),
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
                                MaterialPageRoute<dynamic>(
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
                          child: BoxComments(
                            item.children ?? [],
                            isChild: true,
                            apiContent: apiContent,
                            messengerService: messengerService,
                            preventAccidentalTabcoinTapComment:
                                preventAccidentalTabcoinTapComment,
                          ),
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

  void showPreventTabcoinTap(
      Content item, String transactionType, BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Deseja realmente fazer isso?'),
        content: const Text(
            'Você está vendo isso pois habilitou nas configurações a prevenção de toque acidental de tabcoin.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Não'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Sim'),
            onPressed: () async {
              await thumbComment(item, transactionType, context);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> thumbComment(
      Content item, String transactionType, BuildContext context) async {
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
