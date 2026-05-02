import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../screens/login_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/home_screen.dart';
import '../screens/colony_list_screen.dart';
import '../screens/colony_detail_screen.dart';
import '../screens/investor_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final token = Hive.box('auth').get('accessToken');
    final isAuth = token != null && token.toString().isNotEmpty;
    final isLoginPage = state.matchedLocation == '/login' || state.matchedLocation == '/otp';

    if (!isAuth && !isLoginPage) return '/login';
    if (isAuth && isLoginPage) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
    GoRoute(
      path: '/otp',
      builder: (ctx, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phone: phone);
      },
    ),
    ShellRoute(
      builder: (ctx, state, child) => HomeScreen(child: child),
      routes: [
        GoRoute(path: '/', builder: (ctx, state) => const ColonyListScreen()),
        GoRoute(
          path: '/colony/:id',
          builder: (ctx, state) => ColonyDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(path: '/dashboard', builder: (ctx, state) => const InvestorDashboardScreen()),
      ],
    ),
  ],
);
