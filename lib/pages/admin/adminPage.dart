import 'package:dating/auth/db_client.dart';
import 'package:dating/auth/loginScreen.dart';
import 'package:dating/pages/admin/customNav.dart';
import 'package:dating/pages/admin/pages/approvePicture.dart';
import 'package:dating/pages/admin/pages/complaints_page.dart';
import 'package:dating/pages/admin/pages/dashboard_page.dart';
import 'package:dating/pages/admin/pages/messages_page.dart';
import 'package:dating/pages/admin/pages/subscriptions_page.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  TextStyle navStyle = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

// selected text style
  TextStyle selectedStyle = GoogleFonts.poppins(
    color: AppColors.blue,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    ComplaintsPage(),
    MessagesPage(),
    SubscriptionsPage(),
    ApprovePicturesPage(),
  ];

  final List<String> _pageTitles = [
    'Dashboard',
    'Complaints',
    'Messages',
    'Subscriptions',
    'Approve Pictures'
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    return Scaffold(
      body: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // / space
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 40,
                    ),
                    Text(
                      'Dating App',
                      style: GoogleFonts.jaldi(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                // space
                const SizedBox(
                  height: 20,
                ),
                CustomNavigationRailDestination(
                  icon: Icons.dashboard,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onDestinationSelected(0),
                ),
                CustomNavigationRailDestination(
                  icon: Icons.report_problem,
                  selectedIcon: Icons.report_problem,
                  label: 'Complaints',
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onDestinationSelected(1),
                ),
                CustomNavigationRailDestination(
                  icon: Icons.message,
                  selectedIcon: Icons.message,
                  label: 'Messages',
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onDestinationSelected(2),
                ),
                CustomNavigationRailDestination(
                  icon: Icons.star,
                  selectedIcon: Icons.star,
                  label: 'Subscriptions',
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onDestinationSelected(3),
                ),
                CustomNavigationRailDestination(
                  icon: Icons.photo_album_outlined,
                  selectedIcon: Icons.photo_album,
                  label: 'Approve Picture',
                  isSelected: _selectedIndex == 4,
                  onTap: () => _onDestinationSelected(4),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                //  top bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _pageTitles[_selectedIndex],
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1F192F),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        Row(
                          children: [
                            // serch box
                            Container(
                                width: 200, height: 40, child: searchBox()),
                            const SizedBox(
                              width: 20,
                            ),

                            // notification
                            SvgPicture.asset(
                              AppIcons.notification,
                              height: 20,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            // profile picture
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                image: const DecorationImage(
                                  image: AssetImage(
                                    AppImages.profile,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // profile name
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              'Admin',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF54657E),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // dropdown

                            PopupMenuButton<String>(
                              icon: SvgPicture.asset(
                                AppIcons.chevron,
                                height: 6,
                              ),
                              onSelected: (String result) {
                                if (result == 'logout') {
                                  authenticationProvider.signOut();
                                  DbClient().clearAllData();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                } else if (result == 'switch_account') {
                                  // Handle switch account logic
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.logout,
                                          color: AppColors.blue),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Logout',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF1F192F),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'switch_account',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.switch_account,
                                          color: AppColors.blue),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Switch Account',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF1F192F),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        //
                      ]),
                ),

                //

                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextField searchBox() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: GoogleFonts.poppins(
          color: AppColors.blue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

// border color
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 199, 190, 255),
          ),
          borderRadius: BorderRadius.circular(200),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blue),
          borderRadius: BorderRadius.circular(200),
        ),

        suffixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            AppIcons.searchicon,
            color: AppColors.blue,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(200),
          borderSide: const BorderSide(
            width: 1,
            strokeAlign: BorderSide.strokeAlignCenter,
            color: AppColors.blue,
          ),
        ),
      ),
    );
  }
}
