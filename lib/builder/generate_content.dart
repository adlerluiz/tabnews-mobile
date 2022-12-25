import 'package:flutter/material.dart';
import 'package:tabnews/model/content.dart';
import 'package:tabnews/page/content/content_view_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class GenerateContentBuilder extends StatelessWidget {
  const GenerateContentBuilder({
    super.key,
    required this.contentData,
    required this.index,
    this.showUsername = true,
    this.showComments = true,
    this.showTabcoins = true,
  });

  final Content contentData;
  final int index;
  final bool showUsername;
  final bool showComments;
  final bool showTabcoins;

  @override
  Widget build(BuildContext context) {
    bool isComment = false;
    if (contentData.parentId != null) isComment = true;
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
            builder: (context) => ContentViewPage(
              contentData: contentData,
            ),
          ),
        );
      },
      dense: true,
      leading: Text(
        '${index + 1}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      minLeadingWidth: 16,
      title: Text(
        isComment ? '💬 "${contentData.body}"' : '${contentData.title}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: isComment ? FontWeight.normal : FontWeight.w500,
          fontStyle: isComment ? FontStyle.italic : FontStyle.normal,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
      subtitle: Row(
        children: [
          Visibility(
            visible: showTabcoins,
            child: Text(
              (contentData.tabcoins == 1)
                  ? '${contentData.tabcoins} tabcoin • '
                  : '${contentData.tabcoins} tabcoins • ',
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ),
          Visibility(
            visible: showComments,
            child: Text(
              (contentData.childrenDeepCount == 1)
                  ? '${contentData.childrenDeepCount} comentário • '
                  : '${contentData.childrenDeepCount} comentários • ',
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ),
          Visibility(
            visible: showUsername,
            child: Text(
              '${contentData.ownerUsername} • ',
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ),
          Flexible(
            child: Text(
              timeago.format(DateTime.parse(contentData.publishedAt!),
                  locale: 'pt_BR'),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: true,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          )
        ],
      ),
    );
  }
}
