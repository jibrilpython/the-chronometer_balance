import 'package:flutter/services.dart';
import 'package:the_chronometer_balance/initial_screen.dart';
import 'package:the_chronometer_balance/providers/user_provider.dart';
import 'package:the_chronometer_balance/screens/add_screen.dart';
import 'package:the_chronometer_balance/screens/info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_chronometer_balance/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_chronometer_balance/screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(ProviderScope(child: MyApp(preferences: preferences)));
}

class MyApp extends ConsumerWidget {
  final SharedPreferences preferences;
  const MyApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProv = ref.watch(userProvider);
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'The Chronometer Balance',
            theme: appTheme,
            home: !userProv.firstTimeUser
                ? const InitialScreen()
                : const MainNavigation(),
            routes: {
              '/home': (context) => const MainNavigation(),
              '/initial_screen': (context) => const InitialScreen(),
              '/add_screen': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>? ??
                    {};
                return AddScreen(
                  isEdit: args['isEdit'] as bool? ?? false,
                  currentIndex: args['currentIndex'] as int? ?? 0,
                );
              },
              '/info_screen': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>? ??
                    {};
                return InfoScreen(index: args['index'] as int? ?? 0);
              },
            },
          ),
        );
      },
    );
  }
}
