import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motio_client/screens/login_screen.dart';
import 'package:motio_client/services/auth_service.dart';
import '../models/user.dart';

class CarouselAppBar extends StatefulWidget implements PreferredSizeWidget {
  final User? user;
  final PageController pageController;

  const CarouselAppBar({super.key, required this.user, required this.pageController});

  @override
  State<CarouselAppBar> createState() => _CarouselAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(85);
}

class _CarouselAppBarState extends State<CarouselAppBar> {
  int _currentIndex = 0;
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icon/icon.png',
                height: 30,
              ),
              const SizedBox(width: 10),
              const Text('MOTIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26.0)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              _showUserSettings(context);
            },
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: Svg('assets/main/app_bar.svg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: SizedBox(
          height: 30,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCarouselItem(context, 'Powiadomienia', 0),
              _buildCarouselItem(context, 'TODO', 1),
              _buildCarouselItem(context, 'Money Splitter', 2),
              _buildCarouselItem(context, 'Kalendarz', 3),
              _buildCarouselItem(context, 'Przepisy', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        widget.pageController.jumpToPage(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white, width: _currentIndex == index ? 3 : 2),
          ),
        ),
        child: Text(
          title,
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: Colors.white,
            fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
            fontSize: Theme
                .of(context)
                .textTheme
                .bodyMedium
                ?.fontSize != null
                ? Theme
                .of(context)
                .textTheme
                .bodyMedium!
                .fontSize! + (_currentIndex == index ? 5 : 4)
                : 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showUserSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Wyloguj się'),
                onTap: () {
                  authService.logout();
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
