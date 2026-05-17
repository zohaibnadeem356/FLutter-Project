import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.user;
    final themeMode = appProvider.themeMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await appProvider.refreshAll();
          return Future.value();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ─── Profile Card ───────────────────────────────────
            _sectionLabel('PROFILE'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(isDark),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap edit to change your name',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _editName(context, appProvider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Appearance ──────────────────────────────────────
            _sectionLabel('APPEARANCE'),
            const SizedBox(height: 10),
            Container(
              decoration: _cardDecoration(isDark),
              child: Column(
                children: [
                  _buildThemeOption(
                    context,
                    appProvider,
                    title: 'Light Mode',
                    value: 'light',
                    icon: Icons.wb_sunny_outlined,
                    currentTheme: themeMode,
                    isDark: isDark,
                  ),
                  _divider(isDark),
                  _buildThemeOption(
                    context,
                    appProvider,
                    title: 'Dark Mode',
                    value: 'dark',
                    icon: Icons.nights_stay_outlined,
                    currentTheme: themeMode,
                    isDark: isDark,
                  ),
                  _divider(isDark),
                  _buildThemeOption(
                    context,
                    appProvider,
                    title: 'System Default',
                    value: 'auto',
                    icon: Icons.brightness_auto_outlined,
                    currentTheme: themeMode,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Data Management ─────────────────────────────────
            _sectionLabel('DATA'),
            const SizedBox(height: 10),
            Container(
              decoration: _cardDecoration(isDark),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.history,
                    iconColor: Colors.blue,
                    title: 'Calculation History',
                    subtitle:
                        '${appProvider.calculations.length} saved records',
                    isDark: isDark,
                    onTap: null,
                    trailing: Text(
                      '${appProvider.calculations.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  _divider(isDark),
                  _buildActionTile(
                    icon: Icons.directions_car,
                    iconColor: Colors.green,
                    title: 'Saved Vehicles',
                    subtitle: '${appProvider.vehicles.length} vehicle(s) saved',
                    isDark: isDark,
                    onTap: null,
                    trailing: Text(
                      '${appProvider.vehicles.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  _divider(isDark),
                  _buildActionTile(
                    icon: Icons.delete_sweep_outlined,
                    iconColor: Colors.red,
                    title: 'Clear All History',
                    subtitle: 'Delete all saved calculations',
                    isDark: isDark,
                    onTap: () => _confirmClearHistory(context, appProvider),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Developers ──────────────────────────────────────
            _sectionLabel('DEVELOPERS'),
            const SizedBox(height: 10),
            Container(
              decoration: _cardDecoration(isDark),
              child: Column(
                children: [
                  _buildDeveloperTile(
                    name: 'Muhammad Zohaib',
                    id: '25017119-045',
                    isDark: isDark,
                  ),
                  _divider(isDark),
                  _buildDeveloperTile(
                    name: 'Muhammad Fayyaz',
                    id: '25017119-034',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── About ───────────────────────────────────────────
            _sectionLabel('ABOUT'),
            const SizedBox(height: 10),
            Container(
              decoration: _cardDecoration(isDark),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.blue,
                    title: 'App Version',
                    subtitle: 'Fuel Cost Calculator',
                    isDark: isDark,
                    onTap: null,
                    trailing: Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _divider(isDark),
                  _buildActionTile(
                    icon: Icons.email_outlined,
                    iconColor: Colors.red,
                    title: 'Contact Support',
                    subtitle: 'zohaibnadeem3560.com',
                    isDark: isDark,
                    onTap: () =>
                        _launchUrl('mailto:zohaibnadeem3560@gmail.com'),
                  ),
                  _divider(isDark),
                  _buildActionTile(
                    icon: Icons.code,
                    iconColor: Colors.purple,
                    title: 'GitHub',
                    subtitle: 'View source code',
                    isDark: isDark,
                    onTap: () =>
                        _launchUrl('https://github.com/zohaibnadeem356'),
                  ),
                  _divider(isDark),
                  _buildActionTile(
                    icon: Icons.work_outline,
                    iconColor: const Color(0xFF0077B5),
                    title: 'LinkedIn',
                    subtitle: 'Connect with the team',
                    isDark: isDark,
                    onTap: () => _launchUrl('https://linkedin.com'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Text(
                'Made with ❤️ by Muhammad Zohaib & Fayyaz',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────

  BoxDecoration _cardDecoration(bool isDark) => BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      );

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      );

  Widget _divider(bool isDark) => Divider(
        height: 1,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        indent: 16,
        endIndent: 16,
      );

  // ✅ Theme toggle — no Navigator.pushReplacement, updates instantly
  Widget _buildThemeOption(
    BuildContext context,
    AppProvider provider, {
    required String title,
    required String value,
    required IconData icon,
    required String currentTheme,
    required bool isDark,
  }) {
    final isSelected = currentTheme == value;
    return InkWell(
      onTap: () async {
        await provider.updateThemeMode(value);
        // No pushReplacement needed — Consumer in main.dart handles rebuild
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: isDark ? Colors.white : Colors.black,
                size: 22,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: isDark ? Colors.grey[700] : Colors.grey[400],
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(
                        Icons.chevron_right,
                        color: isDark ? Colors.grey[700] : Colors.grey[400],
                      )
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperTile({
    required String name,
    required String id,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                id,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Dialogs / Actions ───────────────────────────────────────

  Future<void> _editName(BuildContext context, AppProvider provider) async {
    final TextEditingController controller =
        TextEditingController(text: provider.user?.name ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await provider.updateUser(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory(
      BuildContext context, AppProvider provider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'Are you sure you want to delete all saved calculations? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.clearAllCalculations();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All history cleared')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
