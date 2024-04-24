import 'package:dating/pages/chatpage.dart';
import 'package:dating/pages/favouritespage.dart';
import 'package:dating/pages/homepage.dart';
import 'package:dating/pages/likespage.dart';
import 'package:dating/pages/viewpage.dart';
import 'package:dating/utils/icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int _selectedIndex = 0; // Index of the selected icon

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      child: Container(
        height: 70,
        decoration: BoxDecoration(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // home
              Neumorphic(
                child: Container(
                  height: 50,
                  width: 50,
                  child: NeumorphicButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    style: NeumorphicStyle(
                      depth: 5,
                      intensity: 0.75,
                    ),
                    child: Icon(
                      Icons.home_filled,
                      color: _selectedIndex == 0 ? Colors.blue : Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // chat
              Neumorphic(
                child: Container(
                  height: 50,
                  width: 50,
                  child: NeumorphicButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ChatPage()));
                    },
                    style: NeumorphicStyle(
                      depth: 5,
                      intensity: 0.75,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: _selectedIndex == 1 ? Colors.blue : Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // star
              Neumorphic(
                child: Container(
                  height: 50,
                  width: 50,
                  child: NeumorphicButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => FavouritePage()));
                    },
                    style: NeumorphicStyle(
                      depth: 5,
                      intensity: 0.75,
                    ),
                    child: Icon(
                      Icons.star,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // heart
              Neumorphic(
                child: Container(
                  height: 50,
                  width: 50,
                  child: NeumorphicButton(
                    onPressed: () {
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) => LikePage()));
                    },
                    style: NeumorphicStyle(
                      depth: 5,
                      intensity: 0.75,
                    ),
                    child: SvgPicture.asset(
                      AppIcons.heart,
                      height: 20,
                    ),
                  ),
                ),
              ),

              // eye
              Neumorphic(
                child: Container(
                  height: 50,
                  width: 50,
                  child: NeumorphicButton(
                    onPressed: () {
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) => ViewPage()));
                    },
                    style: NeumorphicStyle(
                      depth: 5,
                      intensity: 0.75,
                    ),
                    child: Icon(
                      Icons.remove_red_eye,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavBarDesktop extends StatefulWidget {
  const NavBarDesktop({super.key});

  @override
  State<NavBarDesktop> createState() => _NavBarDesktopState();
}

class _NavBarDesktopState extends State<NavBarDesktop> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // home
            Neumorphic(
              child: Container(
                height: 50,
                width: 50,
                child: NeumorphicButton(
                  onPressed: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) => HomePage()));
                  },
                  style: NeumorphicStyle(
                    depth: 5,
                    intensity: 0.75,
                  ),
                  child: Icon(
                    Icons.home_filled,
                    size: 20,
                  ),
                ),
              ),
            ),

            // chat
            Neumorphic(
              child: Container(
                height: 50,
                width: 50,
                child: NeumorphicButton(
                  onPressed: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) => ChatPage()));
                  },
                  style: NeumorphicStyle(
                    depth: 5,
                    intensity: 0.75,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                  ),
                ),
              ),
            ),

            // star
            Neumorphic(
              child: Container(
                height: 50,
                width: 50,
                child: NeumorphicButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => FavouritePage()));
                  },
                  style: NeumorphicStyle(
                    depth: 5,
                    intensity: 0.75,
                  ),
                  child: Icon(
                    Icons.star,
                    size: 20,
                  ),
                ),
              ),
            ),

            // heart
            Neumorphic(
              child: Container(
                height: 50,
                width: 50,
                child: NeumorphicButton(
                  onPressed: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) => LikePage()));
                  },
                  style: NeumorphicStyle(
                    depth: 5,
                    intensity: 0.75,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.heart,
                    height: 20,
                  ),
                ),
              ),
            ),

            // eye
            Neumorphic(
              child: Container(
                height: 50,
                width: 50,
                child: NeumorphicButton(
                  onPressed: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) => ViewPage()));
                  },
                  style: NeumorphicStyle(
                    depth: 5,
                    intensity: 0.75,
                  ),
                  child: Icon(
                    Icons.remove_red_eye,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
