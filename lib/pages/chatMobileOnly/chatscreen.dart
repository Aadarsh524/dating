import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class ChatScreemMobile extends StatefulWidget {
  const ChatScreemMobile({super.key});

  @override
  State<ChatScreemMobile> createState() => _ChatScreemMobileState();
}

class _ChatScreemMobileState extends State<ChatScreemMobile> {
  final TextEditingController _message = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    ButtonWithLabel(
                      text: null,
                      labelText: null,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(AppImages.profile),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rehan Ritviz',
                          style: AppTextStyles()
                              .primaryStyle
                              .copyWith(fontSize: 14),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.secondaryColor,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              'Malang, J..',
                              style: AppTextStyles().secondaryStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.secondaryColor),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),

                // settings icon

                ButtonWithLabel(
                  text: null,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.call,
                  ),
                  labelText: null,
                ),
              ],
            ),
          ),

// seperator
          const SizedBox(
            height: 20,
          ),

          Container(
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.50,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ),
          ),

// chats

          Expanded(
            child: ListView(
              children: [
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Neumorphic(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Text(
                          'Hello',
                          style: AppTextStyles()
                              .secondaryStyle
                              .copyWith(color: Colors.black, fontSize: 14),
                        ),
                      )),
                    ],
                  ),
                ),

//
                const SizedBox(
                  height: 25,
                ),
                // receievd

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Neumorphic(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Text(
                          'Hello, how are you',
                          style: AppTextStyles()
                              .secondaryStyle
                              .copyWith(color: Colors.black, fontSize: 14),
                        ),
                      )),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),
                // receievd

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Neumorphic(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Text(
                      'Thank you and sure. I love rock music too! What’s your favorite band?',
                      style: AppTextStyles()
                          .secondaryStyle
                          .copyWith(color: Colors.black, fontSize: 14),
                    ),
                  )),
                ),

                const SizedBox(
                  height: 25,
                ),
                // receievd

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Neumorphic(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Text(
                          'Okay Sure',
                          style: AppTextStyles()
                              .secondaryStyle
                              .copyWith(color: Colors.black, fontSize: 14),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWithLabel(
                  text: null,
                  labelText: null,
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
                Expanded(
                    child: AppTextField(
                  hintText: 'Type your message',
                  inputcontroller: _message,
                )),
                ButtonWithLabel(
                  text: null,
                  labelText: null,
                  onPressed: () {},
                  icon: const Icon(Icons.mic),
                ),
// send

                ButtonWithLabel(
                  text: null,
                  labelText: null,
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 25,
          ),
        ],
      ),
    ));
  }
}

// profile button
class profileButton extends StatelessWidget {
  const profileButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: const NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: SizedBox(
        height: 50,
        width: 50,
        child: Image.asset(
          AppImages.loginimage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
