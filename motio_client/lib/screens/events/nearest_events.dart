import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class NearestEvents extends StatefulWidget {
  const NearestEvents({super.key});

  @override
  State<NearestEvents> createState() => _NearestEventsState();
}

class _NearestEventsState extends State<NearestEvents> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const Svg('assets/main/home_body.svg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.17), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: const Text(
            "Najbliższe wydarzenia są w\ntrakcie implementacji",
            style: TextStyle(
              fontSize: 24,
              color: Colors.redAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
