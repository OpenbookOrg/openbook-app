import 'package:Okuna/models/community.dart';
import 'package:Okuna/widgets/checkbox.dart';
import 'package:Okuna/widgets/tiles/community_tile.dart';
import 'package:flutter/cupertino.dart';

class OBCommunitySelectableTile extends StatelessWidget {
  final Community community;
  final ValueChanged<Community> onCommunityPressed;
  final bool isSelected;

  const OBCommunitySelectableTile(
      {Key? key,
      required this.community,
      required this.onCommunityPressed,
      required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onCommunityPressed(community);
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: OBCommunityTile(
              community,
              size: OBCommunityTileSize.small,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: OBCheckbox(
              value: isSelected,
            ),
          )
        ],
      ),
    );
  }
}
