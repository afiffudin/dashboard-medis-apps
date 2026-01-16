import 'package:flutter/material.dart';
import 'widgets/dashboard_item.dart';
import 'analytics_page.dart';

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
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
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
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Last update: 26 Feb 2020',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DashboardItem(icon: Icons.account_circle, title: 'My Account'),
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
                DashboardItem(icon: Icons.receipt, title: 'Request'),
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
      height: 150,
      width: double.infinity,
      color: const Color.fromARGB(255, 127, 206, 243),
      padding: const EdgeInsets.only(top: 40, left: 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(Icons.person),
          ),
          SizedBox(height: 10),
          Text(
            'Halo, Pengguna!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
