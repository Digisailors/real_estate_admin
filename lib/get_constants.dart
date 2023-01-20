import 'package:flutter/material.dart';

getHeight(BuildContext context) => MediaQuery.of(context).size.height;
getWidth(BuildContext context) => MediaQuery.of(context).size.width;
TextTheme getText(BuildContext context) => Theme.of(context).textTheme;
ColorScheme getColor(BuildContext context) => Theme.of(context).colorScheme;

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 650;
bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1300 && MediaQuery.of(context).size.width >= 650;
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1300;
