import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:servicetracker_app/pages/home.dart';

class CustomDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomDrawer({super.key, required this.scaffoldKey});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Map<String, String> _userData = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String displayName = _userData['displayName'] ?? 'Technicien';
    String firstLetter =
        displayName.isNotEmpty ? displayName.substring(0, 1) : '?';

    // Define orange color for icons
    final Color iconColor = Colors.orange.shade600;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Service Tracker",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          firstLetter,
                          style: const TextStyle(
                              fontSize: 28, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AutoSizeText(
                          "Name",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          maxLines: 2,
                          minFontSize: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            _buildSectionTitle(
              "General",
            ),
            _buildDrawerItem(
                icon: Icons.home,
                text: "Home",
                iconColor: iconColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }),
            // _buildDrawerItem(
            //     icon: Icons.home,
            //     text: 'Post',
            //     iconColor: iconColor,
            //     onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => const PostsPage()),
            //       );
            //     }),

            const Divider(color: Colors.grey),
            _buildSectionTitle(
              "Services",
            ),
            _buildDrawerItem(
                icon: Icons.health_and_safety,
                text:"Request Form",
                iconColor: iconColor,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => FirstAidTipsPage()),
                  // );
                }),
            _buildDrawerItem(
                icon: Icons.fire_extinguisher,
                text: "Pendings",
                iconColor: iconColor,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => FireSafetyTipsPage()),
                  // );
                }),
       
     
            const Divider(color: Colors.grey),
            _buildSectionTitle(
              "Account",
            ),
            _buildDrawerItem(
                icon: Icons.person,
                text: "Profile",
                iconColor: iconColor,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const ProfilePage()),
                  // );
                }),
            _buildDrawerItem(
                icon: Icons.people,
                text: "Sign Out",
                iconColor: iconColor,
                onTap: () {
                  // Check if user is logged in
                  // if (_dbService.isAuthenticated()) {
                  //   // If logged in, navigate to Friends/Circle page
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => CircleHomePage()),
                  //   );
                  // } else {
                  //   // If not logged in, redirect to login page
                  //   _dbService.redirectToLogin(context);
                  // }
                }),
            // const Divider(color: Colors.grey),

            // _buildSectionTitle(
            //   LocaleData.app.getString(context),
            // ),
            // _buildDrawerItem(
            //     icon: Icons.info,
            //     text: LocaleData.aboutCDRRMO.getString(context),
            //     iconColor: iconColor,
            //     onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => AboutCdrrmoPage()),
            //       );
            //     }),
            // _buildDrawerItem(
            //     icon: Icons.privacy_tip,
            //     text: LocaleData.privacyPolicy.getString(context),
            //     iconColor: iconColor,
            //     onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => PrivacyPolicyPage()),
            //       );
            //     }),
            // _buildDrawerItem(
            //     icon: Icons.info_outline,
            //     text: LocaleData.aboutApp.getString(context),
            //     iconColor: iconColor,
            //     onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => AboutAppPage()),
            //       );
            //     }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      required Color iconColor,
      required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(text, style: const TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
