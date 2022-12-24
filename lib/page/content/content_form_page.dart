import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:tabnews/model/content.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/messenger.dart';

class ContentFormPage extends StatefulWidget {
  const ContentFormPage({super.key, this.ownerUsername = '', this.slug = ''});

  final String ownerUsername;
  final String slug;

  @override
  State<ContentFormPage> createState() => _ContentFormPageState();
}

class _ContentFormPageState extends State<ContentFormPage> {
  String comment = '';

  MessengerService messengerService = MessengerService();

  TextEditingController titleTextController = TextEditingController();
  TextEditingController mkdTextController = TextEditingController();
  TextEditingController sourceTextController = TextEditingController();

  ApiContent apiContent = ApiContent();

  bool showPreviewText = false;

  bool isSaving = false;

  bool isEdit = false;

  FocusNode titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    titleFocusNode.requestFocus();

    if (widget.ownerUsername.isNotEmpty) {
      isEdit = true;

      getEditData();
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleTextController.dispose();
    mkdTextController.dispose();
    sourceTextController.dispose();
    titleFocusNode.dispose();
  }

  Future<void> getEditData() async {
    try {
      final result = await apiContent.get(widget.ownerUsername, widget.slug);
      final Content data = Content.fromJson(result);
      titleTextController.text = data.title!;
      mkdTextController.text = data.body!;
      sourceTextController.text = data.sourceUrl!;
    } catch (e) {
      print(e);
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
        title: Text(
          '${isEdit ? 'Editar' : 'Publicar novo'} conteúdo',
          style: const TextStyle(fontSize: 18),
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
                    TextField(
                      focusNode: titleFocusNode,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      controller: titleTextController,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        //filled: true,
                        hintText: 'Título',
                        hintStyle: TextStyle(
                          fontSize: 15,
                        ),
                      ),
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
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                    ),
                    TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: sourceTextController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        //filled: true,
                        hintText: 'Fonte (opcional)',
                        helperText: 'Formato https://www.site.com',
                        hintStyle: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: showPreviewText,
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleTextController.value.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      ),
                      MarkdownBody(data: comment)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  Future<void> save() async {
    try {
      if (isEdit) {
        await apiContent.patchContent(
          widget.ownerUsername,
          widget.slug,
          titleTextController.value.text,
          mkdTextController.value.text,
          sourceTextController.value.text,
        );
      } else {
        await apiContent.postContent(
          titleTextController.value.text,
          mkdTextController.value.text,
          sourceTextController.value.text,
        );
      }
      messengerService.show(context, text: 'Conteúdo publicado!');

      Navigator.of(context).pop();
    } catch (e) {
      messengerService.show(context, text: e.toString());
      setState(() {
        isSaving = false;
      });
    }
  }
}
