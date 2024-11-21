import 'package:dating/providers/interaction_provider/favourite_provider.dart';
import 'package:dating/utils/icons.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class FavouriteButton extends StatefulWidget {
  final String currentUserId;
  final String favUser;
  final bool isCurrentUserVerified;

  const FavouriteButton({
    Key? key,
    required this.currentUserId,
    required this.favUser,
    required this.isCurrentUserVerified,
  }) : super(key: key);

  @override
  _FavouriteButtonState createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    Provider.of<FavouritesProvider>(context, listen: false)
        .getFavourites(widget.currentUserId, 1);
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
    return Consumer<FavouritesProvider>(
      builder: (context, favouriteProvider, child) {
        if (favouriteProvider.isFavoriteLoading) {
          return const CircularProgressIndicator();
        } else {
          bool isFav = favouriteProvider
              .checkIfCurrentProfileIsFavourite(widget.favUser);

          return GestureDetector(
            onTap: () async {
              if (widget.isCurrentUserVerified) {
                // Trigger animation on tap
                if (isFav) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }

                await favouriteProvider.toggleFavStatus(
                    widget.currentUserId, widget.favUser);
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
                      depth: 5,
                      intensity: 0.8,
                    ),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFav
                            ? Colors.yellow.withOpacity(0.2)
                            : Colors.white,
                      ),
                      child: Center(
                        child: isFav
                            ? SvgPicture.asset(
                                AppIcons.starfilled,
                                color: Colors.yellow,
                                height: 28,
                                width: 28,
                              )
                            : const Icon(
                                Icons.star_border_outlined,
                                size: 28,
                                color: Colors.grey,
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
