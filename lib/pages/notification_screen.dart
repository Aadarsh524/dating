import 'dart:convert';
import 'dart:typed_data';

import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  final String? roomId;

  const NotificationScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    print("NotificationScreen initialized with title: ${widget.roomId} ");
    super.initState();
  }

  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 65,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
              padding: const EdgeInsets.only(left: 12, top: 10),
              child: Text("Notifications ",
                  style: GoogleFonts.montserrat(
                      textStyle:
                          const TextStyle(color: Colors.black, fontSize: 20)))),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: double.infinity,
              child: LimitedBox(
                maxHeight: 200,
                child: Card(
                  color: Colors
                      .grey[800], // Set a background color for better contrast
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(widget.roomId!)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
