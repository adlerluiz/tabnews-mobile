import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:tabnews/model/content.dart';
import 'package:tabnews/model/post_template.dart';
import 'package:tabnews/service/api_content.dart';
import 'package:tabnews/service/messenger.dart';

List<PostTemplate> templateList = [
  PostTemplate(
    icon: Icons.info_rounded,
    iconColor: Colors.blue,
    title: 'Ajuda',
    titlePrefix: 'Ajuda: ',
    description: 'Preciso de um auxílio sobre um assunto',
    commentHint: 'Descreva aqui a ajuda que você precisa.',
  ),
  PostTemplate(
    icon: Icons.lightbulb_rounded,
    iconColor: Colors.yellow,
    title: 'Dica',
    titlePrefix: 'Dica: ',
    description: 'Quero publicar alguma dica para ajudar as pessoas',
    commentHint: 'Descreva aqui a sua dica valiosa!',
  ),
  PostTemplate(
    icon: Icons.question_mark,
    iconColor: Colors.redAccent,
    title: 'Dúvida',
    titlePrefix: 'Dúvida: ',
    description: 'Estou incerto sobre algo, preciso tirar uma dúvida',
    commentHint: 'Descreva aqui a dúvida que está te matando.',
  ),
  PostTemplate(
    icon: Icons.local_parking_rounded,
    iconColor: Colors.green,
    title: 'Projeto',
    titlePrefix: 'Pitch: ',
    description: 'Quero apresentar um projeto pessoal',
    commentHint: 'Descreva aqui sobre o seu belo projeto',
  ),
  PostTemplate(
    icon: Icons.mode_comment_outlined,
    iconColor: Colors.black,
    title: 'Texto livre',
    titlePrefix: '',
    description: 'Só quero escrever um texto',
    commentHint: 'Descreva aqui seu texto',
  ),
];

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

  String commentHint = '';

  @override
  void initState() {
    super.initState();

    if (widget.ownerUsername.isNotEmpty) {
      isEdit = true;
      getEditData();
    } else {
      Future.delayed(const Duration(milliseconds: 500), showTemplateDialog);
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

  void showTemplateDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.all(6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text(
          'Que tipo de conteúdo, você deseja publicar?',
          style: TextStyle(fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 355,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: templateList.length,
            itemBuilder: (context, index) => Card(
              elevation: 0,
              surfaceTintColor: templateList[index].iconColor,
              child: ListTile(
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Icon(
                  templateList[index].icon,
                  color: templateList[index].iconColor,
                ),
                minLeadingWidth: 10,
                title: Text(templateList[index].title),
                subtitle: Text(templateList[index].description),
                onTap: () {
                  setState(() {
                    titleTextController.text = templateList[index].titlePrefix;
                    commentHint = templateList[index].commentHint;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
    ).then((value) {
      titleFocusNode.requestFocus();
    });
  }

  Future<void> getEditData() async {
    try {
      final result = await apiContent.get(widget.ownerUsername, widget.slug);
      final Content data = Content.fromJson(result);
      titleTextController.text = data.title!;
      mkdTextController.text = data.body!;
      sourceTextController.text = data.sourceUrl!;
    } catch (e) {
      //print(e);
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
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
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
                        label: commentHint,
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
