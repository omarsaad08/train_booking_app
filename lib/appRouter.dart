import 'package:flutter/material.dart';
import 'package:train_booking/presentation/screens/auth/login.dart';
import 'package:train_booking/presentation/screens/auth/signup.dart';
import 'package:train_booking/presentation/screens/base/home.dart';
import 'package:train_booking/presentation/screens/base/booking_confirmation.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case 'login':
        return MaterialPageRoute(builder: (_) => const Login());
      case 'signup':
        return MaterialPageRoute(builder: (_) => const Signup());
      case 'home':
        return MaterialPageRoute(builder: (_) => const Home());
      case 'booking_confirmation':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingConfirmation(
            userId: args['userId'] as int,
            fromCity: args['fromCity'] as String,
            toCity: args['toCity'] as String,
            scheduleTime: args['scheduleTime'] as String,
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const Home());
    }
  }
}
