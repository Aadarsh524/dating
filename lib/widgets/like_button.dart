import 'package:dating/providers/interaction_provider/user_interaction_provider.dart';
import 'package:dating/utils/icons.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LikeButton extends StatefulWidget {
  final String currentUserId;
  final String likedUserId;

  const LikeButton({
    Key? key,
    required this.currentUserId,
    required this.likedUserId,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  void initState() {
    super.initState();
    // Load the liked users when the button is initialized
    Provider.of<UserInteractionProvider>(context, listen: false)
        .getUserInteraction(widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInteractionProvider>(
      builder: (context, userInteractionProvider, child) {
        if (userInteractionProvider.isInteractionLoading) {
          return const CircularProgressIndicator();
        } else {
          bool isLiked =
              userInteractionProvider.isUserLiked(widget.likedUserId);

          return Neumorphic(
            style: const NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
              depth: 5,
              intensity: 0.75,
            ),
            child: NeumorphicButton(
              onPressed: () async {
                await userInteractionProvider.toggleLikeStatus(
                    widget.currentUserId, widget.likedUserId);
              },
              child: SizedBox(
                height: 50, 
                width: 50,
                child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: isLiked
                        ? SvgPicture.asset(
                            AppIcons.heartfilled,
                            height: 20,
                            width: 20,
                          )
                        : SvgPicture.asset(
                            AppIcons.heartoutline,
                            height: 20,
                            width: 20,
                          )),
              ),
            ),
          );
        }
      },
    );
  }
}
