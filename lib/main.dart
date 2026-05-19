import 'package:clone_whatsapp_base_code/cubits/login/login_cubit.dart';
import 'package:clone_whatsapp_base_code/firebase_options.dart';
import 'package:clone_whatsapp_base_code/pages/redirection_page.dart';
import 'package:clone_whatsapp_base_code/repositories/api_repository/auth_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('fr_FR', null);
  setPathUrlStrategy();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RedirectionPage()));
}

var kColorScheme = ColorScheme.fromSeed(
  seedColor: Color.fromARGB(255, 180, 34, 63),
  secondary: Color.fromARGB(255, 180, 34, 63),
  primary: Color.fromARGB(255, 180, 34, 63),
);

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold();
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/sign_in',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold();
          },
        ),
      ],
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
          themeMode: ThemeMode.light,
          theme: ThemeData().copyWith(
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFCFCFC)),
            scaffoldBackgroundColor: const Color(0xFFFCFCFC),
            colorScheme: kColorScheme,
            textTheme: const TextTheme().copyWith(
              displayLarge: GoogleFonts.questrial(
                fontSize: 19,
                color: Colors.black,
              ),
              labelLarge: GoogleFonts.questrial(
                fontSize: 20,
                color: Colors.black,
              ),
              displayMedium: GoogleFonts.questrial(
                fontSize: 15,
                color: Colors.black,
              ),
              labelSmall: GoogleFonts.questrial(
                fontSize: 13,
                color: Colors.black,
              ),
              displaySmall: GoogleFonts.questrial(
                fontSize: 11,
                color: Colors.black,
              ),
              labelMedium: GoogleFonts.questrial(
                fontSize: 17,
                color: Colors.black,
              ),
              titleSmall: GoogleFonts.questrial(
                fontSize: 8,
                color: Colors.black,
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
