import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import 'events/event_list.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AppBar(
            flexibleSpace: Container(
              margin: const EdgeInsets.only(bottom: 1.0),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: Svg('assets/main/app_bar.svg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(-20),
              child: Row(
                children: [
                  _buildCarouselItem(context, 'Najbliższe', 0),
                  _buildCarouselItem(context, 'Kalendarz', 1),
                  _buildCarouselItem(context, 'Lista', 2),
                ],
              ),
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Center(
            child: Text(
              'W trakcie implementacji',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ),
          Center(
            child: Text(
              'W trakcie implementacji',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ),
          const EventList(),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.jumpToPage(index);
      },
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width / 3,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white, width: _currentIndex == index ? 5 : 3),
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
