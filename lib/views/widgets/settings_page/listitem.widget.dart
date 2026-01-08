import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';
import 'package:gamerch_shinyhunter/views/pages/general_settings.page.dart';

class ListItem extends StatelessWidget {
  final String settingsname;
  static final Map settingPages = {
    'General Settings': {
      'detail_page': const GeneralSettingsPage(),
      'icon': const Icon(
        Icons.settings,
      ),
    },
  };
  const ListItem({super.key, required this.settingsname});

  void _goToDetails(BuildContext context) {
    final destination = settingPages[settingsname]['detail_page'];
    if (destination == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _goToDetails(context);
      },
      style: ButtonStyle(
        shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        foregroundColor: WidgetStateProperty.all<Color>(CustomColors.primary),
        iconColor: WidgetStateProperty.all<Color>(CustomColors.primary),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
        child: Row(
          children: [
            settingPages[settingsname]['icon'],
            const SizedBox(width: 20),
            Text(settingsname),
          ],
        ),
      ),
    );
  }
}
