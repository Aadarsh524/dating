import 'dart:convert';
import 'dart:typed_data';

import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/dashboard_response_model.dart';
import 'package:dating/pages/profilepage.dart';
import 'package:dating/providers/dashboard_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

class UserPost extends StatefulWidget {
  final DashboardResponseModel post;
  final String currentUserId;
  final Function(String postId) onLike;

  const UserPost({
    required this.post,
    required this.currentUserId,
    required this.onLike,
    Key? key,
  }) : super(key: key);

  @override
  _UserPostState createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  late bool hasLiked;

  @override
  void initState() {
    super.initState();
    hasLiked = true;
  }

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  Future<void> _toggleLike() async {
    setState(() {
      hasLiked = !hasLiked;
    });

    // Perform like action
    widget.onLike(widget.post.uid!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfilePage(dashboardresponsemodel: widget.post),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Neumorphic(
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(1000)),
                      ),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: widget.post.image != ''
                            ? Image.memory(base64ToImage(widget.post.image!),
                                fit: BoxFit.cover)
                            : Image.memory(base64ToImage(defaultBase64Avatar),
                                fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.post.name!,
                            style: AppTextStyles()
                                .primaryStyle
                                .copyWith(fontSize: 14)),
                        Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 8, color: AppColors.secondaryColor),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.post.name}, ${widget.post.age}',
                              style: AppTextStyles().secondaryStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.secondaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.green),
                  const SizedBox(width: 5),
                  Text(
                    'online',
                    style: AppTextStyles().secondaryStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.black,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<DashboardProvider>(
                    builder: (context, dashboard, _) {
                      final alluploads = widget.post.uploads;
                      if (alluploads != null && alluploads.isNotEmpty) {
                        List<Uploads> reversedUploads =
                            alluploads.reversed.toList();
                        final upload = reversedUploads[0];
                        return Image.memory(base64ToImage(upload.file!),
                            fit: BoxFit.cover);
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                              hasLiked
                                  ? Icons.thumb_up_sharp
                                  : Icons.thumb_up_off_alt,
                              size: 30),
                          onPressed: _toggleLike,
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.mode_comment_outlined, size: 30),
                      ],
                    ),
                    const Icon(Icons.ios_share_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
