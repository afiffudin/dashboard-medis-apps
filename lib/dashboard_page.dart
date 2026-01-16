import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import Font Awesome
import 'widgets/dashboard_item.dart';
import 'analytics_page.dart';
import 'tenaga_medis_page.dart';
import 'dokter_page.dart';

class DashboardPage extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const DashboardPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _buildSidebarHeader(),
            SwitchListTile(
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Dark Mode'),
              value: isDarkMode,
              onChanged: onThemeChanged,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                // Tambahkan logika logout di sini
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Last update: 26 Feb 2020',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // MENGGUNAKAN FONT AWESOME UNTUK DOKTER (STETOSKOP)
                DashboardItem(
                  icon: FontAwesomeIcons.userDoctor,
                  title: 'Dokter',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DokterPage()),
                  ),
                ),
                DashboardItem(icon: Icons.inventory, title: 'Inventory'),
                DashboardItem(icon: Icons.search, title: 'Search Machine'),
                DashboardItem(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnalyticsPage(),
                    ),
                  ),
                ),
                // MENGGUNAKAN FONT AWESOME UNTUK TENAGA MEDIS
                DashboardItem(
                  icon: FontAwesomeIcons.userNurse,
                  title: 'Tenaga Medis',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TenagaMedisPage(),
                    ),
                  ),
                ),
                DashboardItem(icon: Icons.contact_mail, title: 'Contact Us'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      height: 170,
      width: double.infinity,
      color: const Color.fromARGB(255, 127, 206, 243),
      padding: const EdgeInsets.only(top: 50, left: 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 35, color: Colors.blue),
          ),
          SizedBox(height: 15),
          Text(
            'Halo, Pengguna!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
