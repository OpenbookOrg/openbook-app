import 'package:Okuna/models/follows_list.dart';
import 'package:Okuna/widgets/follows_lists_horizontal_list/widgets/follows_lists_horizontal_list_item.dart';
import 'package:Okuna/widgets/follows_lists_horizontal_list/widgets/new_follows_list_horizontal_list_item.dart';
import 'package:flutter/material.dart';

class OBFollowsListsHorizontalList extends StatelessWidget {
  final OnFollowsListPressed onFollowsListPressed;
  final List<FollowsList> followsLists;
  final List<FollowsList> selectedFollowsLists;
  final List<FollowsList>? previouslySelectedFollowsLists;
  final VoidCallback onWantsToCreateANewFollowsList;

  OBFollowsListsHorizontalList(this.followsLists,
      {required this.onFollowsListPressed,
      required this.selectedFollowsLists,
      required this.onWantsToCreateANewFollowsList,
      this.previouslySelectedFollowsLists});

  @override
  Widget build(BuildContext context) {
    int itemCount = followsLists.length + 1;

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        Widget listItem;

        bool isLastItem = index == itemCount - 1;

        if (isLastItem) {
          listItem = OBNewFollowsListHorizontalListItem(
            onPressed: onWantsToCreateANewFollowsList,
          );
        } else {
          var followsList = followsLists[index];
          bool isSelected = selectedFollowsLists.contains(followsList);
          bool wasPreviouslySelected = previouslySelectedFollowsLists != null &&
              previouslySelectedFollowsLists!.contains(followsList);
          listItem = OBFollowsListHorizontalListItem(followsList,
              wasPreviouslySelected: wasPreviouslySelected,
              onFollowsListPressed: onFollowsListPressed,
              isSelected: isSelected);
        }

        return Padding(
          padding: EdgeInsets.only(left: 20, right: isLastItem ? 20 : 0),
          child: listItem,
        );
      },
    );
  }
}

typedef void OnFollowsListPressed(FollowsList list);
