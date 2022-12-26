import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabnews/builder/generate_user_link.dart';
import 'package:tabnews/builder/loading_content_image.dart';
import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/model/content.dart';
import 'package:tabnews/page/content/content_form_comment_page.dart';
import 'package:tabnews/page/content/content_widgets/box_comments.dart';
import 'package:tabnews/page/content/content_widgets/launch_url_wrapper.dart';
import 'package:tabnews/page/content/content_widgets/markdown_data.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/messenger.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostBody extends StatefulWidget {
  final ScrollController pageScrollController;
  final Content contentData;
  final bool isComment;
  final Content data;

  final ApiContent apiContent;
  final MessengerService messengerService;

  const PostBody({
    required this.pageScrollController,
    required this.contentData,
    required this.isComment,
    required this.data,
    required this.apiContent,
    required this.messengerService,
    super.key,
  });

  @override
  State<PostBody> createState() => _PostBodyState();
}

class _PostBodyState extends State<PostBody> {
  // Used for pinch to zoom better UX
  bool blockScroll = false;

  @override
  Widget build(BuildContext context) => Scrollbar(
        child: SingleChildScrollView(
          physics: blockScroll
              ? const NeverScrollableScrollPhysics()
              : const ScrollPhysics(),
          controller: widget.pageScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 3),
              ),
              Padding(
                padding: EdgeInsets.zero,
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
                  child: widget.isComment
                      ? MarkdownBody(
                          data: '💬 ${widget.data.body}',
                          onTapLink: (text, href, title) {
                            LaunchUrlWrapper.launch(Uri.parse(href!));
                          },
                        )
                      : Text(
                          '${widget.data.title}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: widget.isComment
                                ? FontWeight.normal
                                : FontWeight.w500,
                          ),
                        ),
                ),
              ),
              Visibility(
                visible: !widget.isComment,
                child: MarkdownData(
                  widget.data.body!,
                  twoFingersOn: () => setState(() {
                    blockScroll = true;
                  }),
                  twoFingersOff: () => Future.delayed(
                    PinchZoomReleaseUnzoomWidget.defaultResetDuration,
                    () => setState(() => blockScroll = false),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
              ),
              Visibility(
                visible: widget.data.sourceUrl != null,
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
                          LaunchUrlWrapper.launch(
                              Uri.parse(widget.data.sourceUrl!));
                        },
                        child: Text(
                          ' ${widget.data.sourceUrl}',
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
                        tooltip: 'Adicionar TabCoin',
                        onPressed: () async {
                          await thumbPost('credit');
                        },
                        icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      ),
                      Text(
                        '${widget.data.tabcoins}',
                      ),
                      IconButton(
                        tooltip: 'Subtrair TabCoin',
                        onPressed: () async {
                          await thumbPost('debit');
                        },
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
                    onPressed: () {},
                    icon: const Icon(
                      Icons.mode_comment_outlined,
                      size: 18,
                    ),
                    label: Text(
                      '${widget.data.childrenDeepCount}',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.zero,
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
              /*Visibility(
                      visible: widget.contentData.childrenDeepCount! > 0,
                      child: const Divider(height: 1),
                    ),*/
              SizedBox(
                width: double.infinity,
                height: 42,
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
                          id: widget.contentData.id!,
                          title: widget.contentData.title ??
                              widget.contentData.body!,
                        ),
                      ),
                    );
                  },
                  child: const Text('Responder'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
              ),
              Container(
                //key: commentsKey,
                key: ValueKey(widget.contentData.id),
                //color: Colors.white,
                child: FutureBuilder(
                  future: getCommentList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<dynamic> data = snapshot.data;

                      //if (data.length != 0) {
                      if (data.isNotEmpty) {
                        return BoxComments(
                          data,
                          apiContent: widget.apiContent,
                          messengerService: widget.messengerService,
                        );
                      }

                      return Container();
                    }
                    return const LoadingContentImageBuilder(size: 30);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
              ),
            ],
          ),
        ),
      );

  Future<void> thumbPost(String transactionType) async {
    try {
      await widget.apiContent.postTabcoinTransaction(
        widget.contentData.ownerUsername!,
        widget.contentData.slug!,
        transactionType: transactionType,
      );

      if (!mounted) {
        return;
      }

      widget.messengerService.show(context, text: 'Feito!');
    } catch (e) {
      widget.messengerService.show(context, text: e.toString());
    }
  }

  void share(Content data) {
    final user = data.ownerUsername;
    final slug = data.slug;
    final title = data.title;

    Share.share('${constants.baseUrl}/$user/$slug', subject: '$title');
  }

  Future<dynamic> getCommentList() async {
    final List<dynamic> commentListData = await widget.apiContent.getComments(
        widget.contentData.ownerUsername!, widget.contentData.slug!);
    return commentListData;
  }
}
