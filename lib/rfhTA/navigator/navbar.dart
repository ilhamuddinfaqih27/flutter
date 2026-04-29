import 'package:flutter/material.dart';

class ResponsiveNavBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ResponsiveNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;

    return AppBar(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      elevation: 0,
      titleSpacing: 0,
      leading: isLargeScreen
          ? null
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Text(
              "Logo",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isLargeScreen) Expanded(child: _navBarItems()),
          ],
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(child: _ProfileIcon()),
        ),
      ],
    );
  }

  Widget _navBarItems() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _menuItems
            .map(
              (item) => InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16,
                  ),
                  child: Text(item, style: const TextStyle(fontSize: 18)),
                ),
              ),
            )
            .toList(),
      );
}

class ResponsiveDrawer extends StatelessWidget {
  const ResponsiveDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: _menuItems
            .map(
              (item) => ListTile(
                title: Text(item),
                onTap: () => Navigator.pop(context),
              ),
            )
            .toList(),
      ),
    );
  }
}

final List<String> _menuItems = <String>[
  'About',
  'Contact',
  'Settings',
  'Sign Out',
];

enum Menu { itemOne, itemTwo, itemThree }

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      icon: const Icon(Icons.person),
      offset: const Offset(0, 40),
      onSelected: (Menu item) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
        const PopupMenuItem<Menu>(
          value: Menu.itemOne,
          child: Text('Account'),
        ),
        const PopupMenuItem<Menu>(
          value: Menu.itemTwo,
          child: Text('Settings'),
        ),
        const PopupMenuItem<Menu>(
          value: Menu.itemThree,
          child: Text('Sign Out'),
        ),
      ],
    );
  }
}