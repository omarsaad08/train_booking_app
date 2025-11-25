import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:train_booking/appRouter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MainApp(appRouter: AppRouter()));
}

class MainApp extends StatelessWidget {
  final AppRouter appRouter;
  const MainApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return AppView(appRouter: appRouter);
  }
}

class AppView extends StatefulWidget {
  final AppRouter appRouter;
  const AppView({super.key, required this.appRouter});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      title: 'حجز القطار',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'AE')],
      locale: const Locale('ar', 'AE'),
      onGenerateRoute: widget.appRouter.generateRoute,
      initialRoute: 'login',
    );
  }
}
