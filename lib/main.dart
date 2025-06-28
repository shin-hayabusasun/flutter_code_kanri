import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './db/db.dart';
import 'file.dart'; // ルート先ウィジェット
import 'code1.dart'; // ルート先ウィジェット
import 'onecode.dart'; // ルート先ウィジェット

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.init();

  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const File(), // code.dartのFileウィジェット
    ),
    GoRoute(
      path: '/code',
      builder: (context, state) {
        final idStr = state.uri.queryParameters['id'];
        final id = idStr != null ? int.tryParse(idStr) : null;
        return Code(id: id); // idを渡して遷移
      },
    ),
    GoRoute(
      path: '/onecode',
      builder: (context, state) {
        final idStr = state.uri.queryParameters['id'];
        final id = idStr != null ? int.tryParse(idStr) : null;
        return OneCode(id: id); // idを渡して遷移
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'code App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
