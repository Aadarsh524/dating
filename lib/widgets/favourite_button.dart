import 'package:dating/providers/interaction_provider/favourite_provider.dart';
import 'package:dating/providers/interaction_provider/user_interaction_provider.dart';
import 'package:dating/utils/icons.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavouriteButton extends StatefulWidget {
  final String currentUserId;
  final String favUser;

  const FavouriteButton({
    Key? key,
    required this.currentUserId,
    required this.favUser,
  }) : super(key: key);

  @override
  _FavouriteButtonState createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton> {
  @override
  void initState() {
    super.initState();
    // Load the liked users when the button is initialized
    Provider.of<FavouritesProvider>(context, listen: false)
        .getFavourites(widget.currentUserId, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavouritesProvider>(
      builder: (context, favouriteProvider, child) {
        if (favouriteProvider.isLoading) {
          return const CircularProgressIndicator();
        } else {
          bool isFav = favouriteProvider
              .checkIfCurrentProfileIsFavourite(widget.favUser);

          return Neumorphic(
            style: const NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
              depth: 5,
              intensity: 0.75,
            ),
            child: NeumorphicButton(
              onPressed: () async {
                await favouriteProvider.toggleFavStatus(
                    widget.currentUserId, widget.favUser);
              },
              child: SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: isFav
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
