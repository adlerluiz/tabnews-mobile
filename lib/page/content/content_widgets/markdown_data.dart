import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';
import 'package:tabnews/page/content/content_widgets/launch_url_wrapper.dart';

class MarkdownData extends StatelessWidget {
  final String body;
  final Function? twoFingersOn;
  final Function? twoFingersOff;

  const MarkdownData(
    this.body, {
    this.twoFingersOn,
    this.twoFingersOff,
    super.key,
  });

  @override
  Widget build(BuildContext context) => MarkdownBody(
        data: body,
        selectable: true,
        onTapLink: (text, href, title) {
          LaunchUrlWrapper.launch(Uri.parse(href!));
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
              MaterialPageRoute<dynamic>(
                builder: (context) => PinchZoomReleaseUnzoomWidget(
                  child: Image.network(
                    uri.toString(),
                  ),
                ),
              ),
            );
          },
          child: PinchZoomReleaseUnzoomWidget(
            twoFingersOn: twoFingersOn,
            twoFingersOff: twoFingersOff,
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
              errorBuilder: (context, error, stackTrace) => ColoredBox(
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
        ),
      );
}
