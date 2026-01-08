import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';

ButtonStyle deleteButtonsDataPage = ButtonStyle(
  shape: WidgetStateProperty.all<OutlinedBorder>(
    RoundedRectangleBorder(
      side: BorderSide(color: CustomColors.primary, width: 1.5),
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 16)),
  backgroundColor: WidgetStateProperty.all<Color>(CustomColors.error),
  foregroundColor: WidgetStateProperty.all<Color>(CustomColors.onError),
  overlayColor: WidgetStateProperty.all<Color>(CustomColors.primaryHover),
);
