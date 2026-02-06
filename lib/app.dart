import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/theme/theme.dart';
import 'package:udb_association/src/features/splash/screens/loading_screen.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/localization/localization_providers.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: _Bootstrapper());
  }
}

class _Bootstrapper extends ConsumerStatefulWidget {
  const _Bootstrapper();

  @override
  ConsumerState<_Bootstrapper> createState() => _BootstrapperState();
}

class _BootstrapperState extends ConsumerState<_Bootstrapper> {
  bool _initialized = false;
  bool _showLoadingScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final storage = const TokenStorage();
    final token = await storage.readToken();
    ref.read(authTokenProvider.notifier).state = token;

    // If user is authenticated, we need to determine the correct initial route
    if (token != null) {
      // For authenticated users, we'll let the redirect logic handle the routing
      // But we need to ensure the router is created with the token available
      print('🔐 User is authenticated, token loaded');
    } else {
      print('👤 User is not authenticated');
    }

    // Hide splash and show app
    if (mounted) {
      setState(() {
        _initialized = true;
        _showLoadingScreen = true;
      });
      _startPostSplashDelay();
    }
  }

  void _startPostSplashDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showLoadingScreen = false;
      });
    }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Loading state (shouldn't be visible with the splash screens)
    if (!_initialized) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final locale = ref.watch(localeProvider);

    if (_showLoadingScreen) {
      return LoadingScreen(locale: locale);
    }

    // Main app
    final container = ProviderScope.containerOf(context);
    return MaterialApp.router(
      title: 'UDB Association',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: createRouter(container),
    );
  }
}
