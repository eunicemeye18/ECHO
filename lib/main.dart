import 'package:echo_work/cubits/login/login_cubit.dart';
import 'package:echo_work/firebase_options.dart';
import 'package:echo_work/pages/login_pages.dart';
import 'package:echo_work/pages/redirection_page.dart';
import 'package:echo_work/pages/shell_page.dart';
import 'package:echo_work/repositories/api_repository/auth_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Web OAuth client ID (type 3 — Web application)
const String _googleWebClientId =
    '362069540916-9hhstneg0thuum64l4lq5jj6s54u5951.apps.googleusercontent.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    if (kIsWeb) {
      await GoogleSignIn.instance.initialize(clientId: _googleWebClientId);
    } else {
      await GoogleSignIn.instance.initialize();
    }
  } catch (e) {
    debugPrint("Google Sign In initialization failed: $e");
  }
  await initializeDateFormatting('fr_FR', null);
  setPathUrlStrategy();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  runApp(const MainApp());
}

var kColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color(0xFFE50914),
  secondary: const Color(0xFFE50914),
  primary: const Color(0xFFE50914),
  surface: Colors.black,
);

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const RedirectionPage();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPages();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const ShellPage();
      },
    ),
  ],
);

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (context) => AuthRepository())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginCubit>(
            create: (context) =>
                LoginCubit(authRepository: context.read<AuthRepository>()),
          ),
        ],
        child: MaterialApp.router(
          themeMode: ThemeMode.dark,
          theme: ThemeData.dark().copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            scaffoldBackgroundColor: Colors.black,
            colorScheme: kColorScheme,
            textTheme: const TextTheme().copyWith(
              displayLarge: GoogleFonts.questrial(
                fontSize: 19,
                color: Colors.white,
              ),
              labelLarge: GoogleFonts.questrial(
                fontSize: 20,
                color: Colors.white,
              ),
              displayMedium: GoogleFonts.questrial(
                fontSize: 15,
                color: Colors.white,
              ),
              labelSmall: GoogleFonts.questrial(
                fontSize: 13,
                color: Colors.white,
              ),
              displaySmall: GoogleFonts.questrial(
                fontSize: 11,
                color: Colors.white,
              ),
              labelMedium: GoogleFonts.questrial(
                fontSize: 17,
                color: Colors.white,
              ),
              titleSmall: GoogleFonts.questrial(
                fontSize: 8,
                color: Colors.white,
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      ),
    );
  }
}
