import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';
import 'package:gamerch_shinyhunter/views/widgets/settings_page/_settings_page_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  final String title = 'Settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        child: ListView(
          children: [
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: CustomColors.shadowColor,
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ], borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: const Column(
                children: [
                  ListItem(
                    settingsname: 'General Settings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
