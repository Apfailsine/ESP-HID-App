import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('General Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Text(
              'General Settings',
              style: TextStyle(
                color: CustomColors.onBackgroundWhite,
              ),
            ),
          ),
        ));
  }
}
