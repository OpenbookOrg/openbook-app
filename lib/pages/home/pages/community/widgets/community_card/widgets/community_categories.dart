import 'package:Okuna/models/category.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/widgets/category_badge.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBCommunityCategories extends StatelessWidget {
  final Community community;

  OBCommunityCategories(this.community);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: community,
      stream: community.updateSubject,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        Community community = snapshot.data!;
        if (community.categories == null) return const SizedBox();
        List<Category> categories = community.categories!.categories!;

        List<Widget> connectionItems = [];

        categories.forEach((Category category) {
          connectionItems.add(Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              OBCategoryBadge(
                category: category,
                size: OBCategoryBadgeSize.small,
              )
            ],
          ));
        });

        return Padding(
          padding: EdgeInsets.only(top: 10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: connectionItems,
          ),
        );
      },
    );
  }
}
