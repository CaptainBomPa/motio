import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'add_update_event_screen.dart';
import '../../widgets/event_tile.dart';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  late List<DateTime> _dates;
  int _daysBeforeToday = 10;
  int _daysAfterToday = 10;

  @override
  void initState() {
    super.initState();
    _dates = List.generate(
        21, (index) => DateTime.now().subtract(Duration(days: 10 - index))); // Load 10 days before and 10 days after today
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final firstVisibleIndex = positions
          .where((position) => position.itemLeadingEdge < 1)
          .reduce((min, position) => min.itemLeadingEdge < position.itemLeadingEdge ? min : position)
          .index;
      final lastVisibleIndex = positions
          .where((position) => position.itemTrailingEdge > 0)
          .reduce((max, position) => max.itemTrailingEdge > position.itemTrailingEdge ? max : position)
          .index;

      if (firstVisibleIndex == 0) {
        _loadMoreDaysBefore();
      } else if (lastVisibleIndex == _dates.length - 1) {
        _loadMoreDaysAfter();
      }
    }
  }

  void _loadMoreDaysBefore() {
    setState(() {
      _daysBeforeToday += 10; // Load 10 more days before today
      final newDates = List.generate(10, (index) => DateTime.now().subtract(Duration(days: _daysBeforeToday - index))).toList();
      _dates.insertAll(0, newDates);
      _scrollController.jumpTo(index: 10); // Adjust scroll position
    });
  }

  void _loadMoreDaysAfter() {
    setState(() {
      final newDates = List.generate(10, (index) => DateTime.now().add(Duration(days: _daysAfterToday + index)));
      _daysAfterToday += 10; // Load 10 more days after today
      _dates.addAll(newDates);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Svg('assets/main/home_body.svg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.17), BlendMode.darken),
          ),
        ),
        child: ScrollablePositionedList.builder(
          itemScrollController: _scrollController,
          itemPositionsListener: _itemPositionsListener,
          initialScrollIndex: 10,
          itemCount: _dates.length,
          itemBuilder: (context, index) {
            final date = _dates[index];
            return EventTile(date: date);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddUpdateEventScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }
}
