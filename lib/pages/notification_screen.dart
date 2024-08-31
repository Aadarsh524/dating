import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  final String? title;
  final String? body;

  const NotificationScreen({Key? key, required this.title, required this.body})
      : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    print(
        "NotificationScreen initialized with title: ${widget.title} and body: ${widget.body}");
    super.initState();
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
                        children: [
                          Text(
                            widget.title!.isNotEmpty
                                ? widget.title!
                                : 'No Title',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            widget.body!.isNotEmpty ? widget.body! : 'No Body',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
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
