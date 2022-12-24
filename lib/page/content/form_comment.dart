import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/messenger.dart';

class ContentFormCommentPage extends StatefulWidget {
  const ContentFormCommentPage(
      {super.key, required this.id, required this.title});

  final String id;
  final String title;

  @override
  State<ContentFormCommentPage> createState() => _ContentFormCommentPageState();
}

class _ContentFormCommentPageState extends State<ContentFormCommentPage> {
  String comment = '';

  TextEditingController mkdTextController = TextEditingController();

  MessengerService messengerService = MessengerService();

  ApiContent apiContent = ApiContent();

  bool showPreviewText = false;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    mkdTextController.dispose();
  }

  save() async {
    try {
      await apiContent.postComment(mkdTextController.value.text, widget.id);

      messengerService.show(context, text: 'Resposta publicadoa!');
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        isSaving = false;
      });

      messengerService.show(context, text: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Responder',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          Visibility(
            visible: !showPreviewText,
            child: IconButton(
              tooltip: 'Visualizar',
              icon: const Icon(Icons.remove_red_eye_outlined),
              onPressed: () {
                setState(() {
                  showPreviewText = !showPreviewText;
                });
              },
            ),
          ),
          Visibility(
            visible: showPreviewText,
            child: IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  showPreviewText = !showPreviewText;
                });
              },
            ),
          ),
          TextButton(
            child: isSaving
                ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Postar'),
            onPressed: () {
              if (!isSaving) {
                save();

                setState(() {
                  isSaving = true;
                });
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              visible: !showPreviewText,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarkdownBody(
                      data: limitText(widget.title),
                      softLineBreak: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                    ),
                    MarkdownTextInput(
                      (String value) {
                        comment = value;
                      },
                      comment,
                      label: 'Seu comentário',
                      actions: MarkdownType.values,
                      controller: mkdTextController,
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: showPreviewText,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: MarkdownBody(data: comment),
              ),
            ),
          ],
        ),
      ),
    );

  String limitText(String text, {int limit = 250}) {
    if (text.length > limit) {
      return '${text.substring(0, limit)}...';
    }
    return text;
  }
}
