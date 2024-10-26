import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Row(
        children: [
          Image.asset(
            'assets/icon/icon.png',
            height: 30,
          ),
          const SizedBox(width: 10),
          const Text('MOTIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26.0)),
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
}
