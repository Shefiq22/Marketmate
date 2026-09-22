import 'package:flutter/material.dart';

/// App-wide navigator state used to route notification deep links even when
/// the app was launched from a terminated state and no widget context is
/// available yet.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();