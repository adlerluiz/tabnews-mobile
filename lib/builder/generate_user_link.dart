import 'package:flutter/material.dart';
import 'package:tabnews/page/profile/profile_view_page.dart';

class GenerateUserLinkBuilder extends StatelessWidget {
  const GenerateUserLinkBuilder({required this.ownerUsername, super.key});

  final String ownerUsername;

  @override
  Widget build(BuildContext context) => Flexible(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                builder: (context) => ProfileViewPage(
                  ownerUsername: ownerUsername,
                ),
              ),
            );
          },
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 1,
              horizontal: 5,
            ),
            decoration: const BoxDecoration(
              color: Color.fromARGB(50, 33, 149, 243),
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              ownerUsername,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),
          ),
        ),
      );
}
