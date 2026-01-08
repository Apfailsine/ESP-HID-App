import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';
import 'views/pages/_pages.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int currentPageIndex = 0;
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Map<String, Widget>> mainPages = [
    {
      'page': const DevicePage(),
      'nav_bar_element': const NavigationDestination(
        selectedIcon: Icon(Icons.bluetooth_connected),
        icon: Icon(Icons.bluetooth),
        label: 'Device',
        tooltip: '',
      ),
    },
    {
      'page': const ControllerPage(),
      'nav_bar_element': const NavigationDestination(
        selectedIcon: Icon(Icons.sports_esports),
        icon: Icon(Icons.sports_esports_outlined),
        label: 'Controller',
        tooltip: '',
      ),
    },
    {
      'page': const SettingsPage(),
      'nav_bar_element': const NavigationDestination(
        selectedIcon: Icon(Icons.settings),
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
        tooltip: '',
      ),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: mainPages
            .map((page) => Navigator(
                  key: navigatorKeys[mainPages.indexOf(page)],
                  onGenerateRoute: (settings) => MaterialPageRoute(
                    builder: (context) => page['page']!,
                  ),
                ))
            .toList(),
      ),
      bottomNavigationBar: NavigationBar(
        // height: (MediaQuery.of(context).orientation == Orientation.landscape) ? 60 : 60,
        destinations: mainPages.map((page) => page['nav_bar_element']!).toList(),
        onDestinationSelected: (int index) {
          // setState(() {
          //   currentPageIndex = index;
          // });
          if (index == currentPageIndex && index == (mainPages.length - 1)) {
            // Reset the navigator for the settings page
            navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
          } else {
            setState(() {
              currentPageIndex = index;
            });
          }
        },
        indicatorColor: CustomColors.secondary,
        selectedIndex: currentPageIndex,
        backgroundColor: CustomColors.backgroundDirtyWhite,
      ),
    );
  }
}
