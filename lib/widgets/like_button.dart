import 'package:dating/providers/interaction_provider/user_interaction_provider.dart';
import 'package:dating/utils/icons.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LikeButton extends StatefulWidget {
  final String currentUserId;
  final String likedUserId;
  final bool isCurrentUserVerified;

  const LikeButton({
    Key? key,
    required this.currentUserId,
    required this.likedUserId,
    required this.isCurrentUserVerified,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Load liked users when the button is initialized
    Provider.of<UserInteractionProvider>(context, listen: false)
        .getUserInteraction(widget.currentUserId);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $message')));
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

          return GestureDetector(
            onTap: () async {
              if (widget.isCurrentUserVerified == true) {
                // Animate the button on tap
                if (isLiked) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }

                await userInteractionProvider.toggleLikeStatus(
                    widget.currentUserId, widget.likedUserId);
              } else {
                _showErrorSnackBar(
                    "You must be verified to perform this action.");
              }
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + (_animationController.value * 0.1),
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.circle(),
                      depth: 4,
                      intensity: 0.75,
                    ),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLiked
                            ? Colors.red.withOpacity(0.2)
                            : Colors.white,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          isLiked
                              ? AppIcons.heartfilled
                              : AppIcons.heartoutline,
                          color: isLiked ? Colors.red : Colors.grey,
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
