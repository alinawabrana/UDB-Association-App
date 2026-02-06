import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/navigation_screen.dart';
import 'package:udb_association/src/features/auth/screens/forget_password/forget_password_screen.dart';
import 'package:udb_association/src/features/auth/screens/welcome_screen.dart';
import 'package:udb_association/src/features/auth/screens/auth_screen.dart';
import 'package:udb_association/src/features/directory/screens/directory_screen.dart';
import 'package:udb_association/src/features/documents/screens/documents_screen.dart';
import 'package:udb_association/src/features/events/screens/events_screen.dart';
import 'package:udb_association/src/features/events/screens/events_search_screen.dart';
import 'package:udb_association/src/features/home/screens/home_screen.dart';
import 'package:udb_association/src/features/home/screens/products_by_category_screen.dart';
import 'package:udb_association/src/features/news/screens/news_screen.dart';
import 'package:udb_association/src/features/news/screens/news_search_screen.dart';
import 'package:udb_association/src/features/news/screens/comments_screen.dart';
import 'package:udb_association/src/features/news/models/combined_item_model.dart';
import 'package:udb_association/src/features/news/models/comment_model.dart';
import 'package:udb_association/src/features/profile/screens/edit_profile_screen.dart';
import 'package:udb_association/src/features/profile/screens/profile_screen.dart';
import 'package:udb_association/src/features/projects/screens/projects_screen.dart';
import 'package:udb_association/src/features/shop/screens/cart_screen.dart';
import 'package:udb_association/src/features/shop/screens/order_success_screen.dart';
import 'package:udb_association/src/features/shop/screens/product_checkout_screen.dart';
import 'package:udb_association/src/features/shop/screens/product_detail_screen.dart';
import 'package:udb_association/src/features/shop/screens/shop_screen.dart';
import 'package:udb_association/src/features/shop/screens/shop_home_screen.dart';
import 'package:udb_association/src/features/shop/screens/wishlist_items_screen.dart';
import 'package:udb_association/src/features/shop/screens/order_detail_screen.dart';
import 'package:udb_association/src/features/shop/screens/orders_screen.dart';
import 'package:udb_association/src/features/subscription/screens/subscription_checkout_screen.dart';
import 'package:udb_association/src/features/subscription/screens/subscription_selection/subscription_selection_screen.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/auth/provider/user_role_fallback_provider.dart';
import 'package:udb_association/src/features/statistics/screens/statistics_screen.dart';
import 'package:udb_association/src/features/statistics/screens/manager_statistics_screen.dart';
import 'package:udb_association/src/features/notifications/screens/notifications_screen.dart';
import 'package:udb_association/src/features/surveys/screens/surveys_screen.dart';
import 'package:udb_association/src/features/surveys/screens/survey_form_screen.dart';
import 'package:udb_association/src/features/surveys/screens/survey_analysis_screen.dart';
import 'package:udb_association/src/features/surveys/screens/all_surveys_screen.dart';
import 'package:udb_association/src/features/surveys/models/survey_simple.dart';
import 'package:udb_association/src/features/branches/screens/companies_screen.dart';
import 'package:udb_association/src/features/chat/screens/chat_list_screen.dart';
import 'package:udb_association/src/features/chat/screens/new_chat_screen.dart';
import 'package:udb_association/src/features/directory/screens/chat_screen.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';

// Router refresh notifier to handle token and profile changes
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this._container) {
    _tokenSubscription = _container.listen<String?>(authTokenProvider, (_, __) {
      print('🔄 Router refresh triggered by token change');
      notifyListeners();
    }, fireImmediately: false);

    _profileSubscription = _container.listen(profileProvider, (_, __) {
      print('🔄 Router refresh triggered by profile change');
      notifyListeners();
    }, fireImmediately: false);

    _roleSubscription = _container.listen(effectiveUserRoleProvider, (_, __) {
      print('🔄 Router refresh triggered by role change');
      notifyListeners();
    }, fireImmediately: false);

    _subscriptionStatusSubscription = _container.listen(
      userHasApprovedSubscriptionProvider,
      (_, __) {
        print('🔄 Router refresh triggered by subscription status change');
        notifyListeners();
      },
      fireImmediately: false,
    );
  }

  final ProviderContainer _container;
  late final ProviderSubscription<String?> _tokenSubscription;
  late final ProviderSubscription _profileSubscription;
  late final ProviderSubscription _roleSubscription;
  late final ProviderSubscription _subscriptionStatusSubscription;

  @override
  void dispose() {
    _tokenSubscription.close();
    _profileSubscription.close();
    _roleSubscription.close();
    _subscriptionStatusSubscription.close();
    super.dispose();
  }
}

// Route names
class AppRouteNames {
  // Auth
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgetPassword = 'forget_password';
  static const String guest = 'guest';

  // navigation
  static const String navigation = 'navigation';
  static const String appImages = 'app_images';
  static const String home = 'home';
  static const String productsByCategory = 'products_by_category';
  static const String shop = 'shop';
  static const String shopDetail = 'shop_detail';
  static const String statistics = 'statistics';
  static const String managerStatistics = 'manager_statistics';
  static const String surveyAnalysis = 'survey_analysis';
  static const String allSurveys = 'all_surveys';
  static const String profile = 'profile';
  static const String favorites = 'favorites';
  static const String allBranchesDetail = 'all_branches_detail';

  // Profile
  static const String editProfile = 'edit_profile';
  static const String subscriptionSelection = 'subscription_selection';
  static const String subscriptionCheckout = 'subscription_checkout';

  // Products
  static const String productDetail = 'product_detail';
  static const String shopProductDetail = 'shop_product_detail';
  static const String productCheckout = 'product_checkout';
  static const String orderSuccess = 'order_success';
  static const String cart = 'cart';
  static const String homeCart = 'home_cart';
  static const String shopCart = 'shop_cart';
  static const String orderDetail = 'order_detail';
  static const String orders = 'orders';

  // App Images Routes
  static const String appNews = 'app_news';
  static const String newsSearch = 'news_search';
  static const String comments = 'comments';
  static const String appEvents = 'app_events';
  static const String eventsSearch = 'events_search';
  static const String appProjects = 'app_projects';
  static const String appNotifications = 'app_notifications';
  static const String appDirectory = 'app_directory';
  static const String appDocuments = 'app_documents';
  static const String appSurveys = 'app_survey';
  static const String appShopProducts = 'app_shop_products';
  static const String appProductDetail = 'app_product_detail';
  static const String appProductCheckout = 'app_product_checkout';
  static const String appOrderSuccess = 'app_order_success';
  static const String appCart = 'app_cart';

  // Drawer Menu
  static const String news = 'news';
  static const String events = 'events';
  static const String projects = 'projects';
  static const String managerProjects = 'manager_projects';
  static const String managerNotifications = 'manager_notifications';
  static const String shopProducts = 'shop_products';

  // Manager-specific drawer routes (within shell)
  static const String managerNews = 'manager_news';
  static const String managerEvents = 'manager_events';
  static const String managerDirectory = 'manager_directory';
  static const String managerDocuments = 'manager_documents';
  static const String managerShopProducts = 'manager_shop_products';
  static const String managerProductDetail = 'manager_product_detail';
  static const String managerProductCheckout = 'manager_product_checkout';
  static const String managerOrderSuccess = 'manager_order_success';
  static const String managerCart = 'manager_cart';
  static const String directory = 'directory';
  static const String documents = 'documents';
  static const String surveys = 'surveys';
  static const String notifications = 'notifications';

  // Member specific routes
  static const String memberProjects = 'member_projects';
  static const String memberNotifications = 'member_notifications';

  // member-specific drawer routes (within shell)
  static const String memberNews = 'member_news';
  static const String memberEvents = 'member_events';
  static const String memberDirectory = 'member_directory';
  static const String memberDocuments = 'member_documents';
  static const String memberShopProducts = 'member_shop_products';
  static const String memberProductDetail = 'member_product_detail';
  static const String memberProductCheckout = 'member_product_checkout';
  static const String memberOrderSuccess = 'member_order_success';
  static const String memberCart = 'member_cart';
  static const String memberSurvey = 'member_survey';

  // Special users
  static const String userNews = 'user_news';
  static const String userProduct = 'user_product';
  static const String userCart = 'user_cart';
  static const String userProductDetail = 'user_product_detail';
  static const String userNotifications = 'user_notifications';

  static final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellKey = GlobalKey<NavigatorState>();
}

// Create router with refresh mechanism
GoRouter createRouter(ProviderContainer container) {
  final refreshNotifier = RouterRefreshNotifier(container);

  return GoRouter(
    navigatorKey: AppRouteNames.rootKey,
    initialLocation: '/app_images',
    // Start at home for authenticated users, redirect logic will handle role-based routing
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final token = container.read(authTokenProvider);

      print(
        '🔄 Router redirect - Path: ${state.fullPath}, Token: ${token != null ? "exists" : "null"}',
      );

      final isAuthRoute =
          state.fullPath == '/' ||
          state.fullPath?.startsWith('/login') == true ||
          state.fullPath?.startsWith('/signup') == true ||
          state.fullPath?.startsWith('/forget_password') == true;

      // If user is not authenticated and trying to access protected routes
      if (token == null) {
        print('❌ No token, checking if protected route...');
        if (state.fullPath?.startsWith('/home') == true ||
            state.fullPath?.startsWith('/app_images') == true ||
            state.fullPath?.startsWith('/survey_analysis') == true ||
            state.fullPath?.startsWith('/manager_statistics') == true ||
            state.fullPath?.startsWith('/manager_projects') == true ||
            state.fullPath?.startsWith('/manager_news') == true ||
            state.fullPath?.startsWith('/manager_events') == true ||
            state.fullPath?.startsWith('/manager_directory') == true ||
            state.fullPath?.startsWith('/manager_documents') == true ||
            state.fullPath?.startsWith('/manager_shop_products') == true ||
            state.fullPath?.startsWith('/projects') == true) {
          print('🚫 Redirecting to login - no token on protected route');
          return '/';
        }
        print('✅ No token but not on protected route, allowing');
        return null;
      }

      print('✅ User has token, checking role-based redirects...');

      // User is authenticated - check role-based redirects
      // If on auth routes, redirect based on role
      if (isAuthRoute) {
        print(
          '🔐 User authenticated on auth route, checking effective role...',
        );
        final effectiveRole = container.read(effectiveUserRoleProvider);
        print('👤 Effective role: $effectiveRole');

        return '/app_images';
      }

      if (state.fullPath == '/home') {
        print(
          '🏠 User trying to access /home, evaluating role-based redirect...',
        );
        final effectiveRole = container.read(effectiveUserRoleProvider);
        final subscriptionStatus = container.read(
          userHasApprovedSubscriptionProvider,
        );
        final isSpecialUser = subscriptionStatus.when(
          data: (value) => value,
          loading: () => false,
          error: (_, __) => false,
        );
        switch (effectiveRole?.toLowerCase()) {
          case 'manager':
            return '/survey_analysis';
          case 'member':
            return '/member_projects';
          case 'user':
            if (isSpecialUser) {
              return '/user_news';
            }
            return null;
          default:
            return null;
        }
      }

      print('✅ No redirect needed for path: ${state.fullPath}');
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: AppRouteNames.welcome,
        builder: (BuildContext context, GoRouterState state) =>
            const WelcomeScreen(),
        routes: [
          GoRoute(
            path: '/login',
            name: AppRouteNames.login,
            builder: (context, state) => const AuthScreen(initialTabIndex: 0),
            routes: [
              GoRoute(
                path: '/forget_password',
                name: AppRouteNames.forgetPassword,
                builder: (context, state) => const ForgetPasswordScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/signup',
            name: AppRouteNames.signup,
            builder: (context, state) => const AuthScreen(initialTabIndex: 1),
          ),
        ],
      ),
      // GoRoute(
      //   path: '/guest',
      //   name: AppRouteNames.guest,
      //   builder: (context, state) =>
      //       const _StubScreen(title: 'Continue as Guest'),
      // ),
      ShellRoute(
        navigatorKey: AppRouteNames.shellKey,
        pageBuilder: (context, state, child) =>
            MaterialPage(child: NavigationScreen(child: child)),
        routes: [
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/app_news',
            name: AppRouteNames.appNews,
            builder: (context, state) => const NewsScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/comments',
                name: AppRouteNames.comments,
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return CommentsScreen(
                    item: args['item'] as CombinedItemModel,
                    targetId: args['targetId'] as int,
                    targetType: args['targetType'] as ContentTargetType,
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/search',
                name: AppRouteNames.newsSearch,
                builder: (context, state) => const NewsSearchScreen(),
              ),
            ],
          ),
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/app_events',
            name: AppRouteNames.appEvents,
            builder: (context, state) => const EventsScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/search',
                name: AppRouteNames.eventsSearch,
                builder: (context, state) => const EventsSearchScreen(),
              ),
            ],
          ),
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/app_directory',
            name: AppRouteNames.appDirectory,
            builder: (context, state) => const DirectoryScreen(),
          ),
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/app_projects',
            name: AppRouteNames.appProjects,
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/app_images',
            name: AppRouteNames.appImages,
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/statistics',
                name: AppRouteNames.statistics,
                builder: (context, state) => const StatisticsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/manager_statistics',
                name: AppRouteNames.managerStatistics,
                builder: (context, state) => const ManagerStatisticsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/survey_analysis',
                name: AppRouteNames.surveyAnalysis,
                builder: (context, state) => const SurveyAnalysisScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: AppRouteNames.rootKey,
                    path: '/all_surveys',
                    name: AppRouteNames.allSurveys,
                    builder: (context, state) => const AllSurveysScreen(),
                  ),
                ],
              ),
              // GoRoute(
              //   parentNavigatorKey: AppRouteNames.rootKey,
              //   path: '/app_events',
              //   name: AppRouteNames.appEvents,
              //   builder: (context, state) => const EventsScreen(),
              // ),
              // GoRoute(
              //   parentNavigatorKey: AppRouteNames.rootKey,
              //   path: '/app_projects',
              //   name: AppRouteNames.appProjects,
              //   builder: (context, state) => const ProjectsScreen(),
              // ),
              // GoRoute(
              //   parentNavigatorKey: AppRouteNames.rootKey,
              //   path: '/app_directory',
              //   name: AppRouteNames.appDirectory,
              //   builder: (context, state) => const DirectoryScreen(),
              // ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/app_documents',
                name: AppRouteNames.appDocuments,
                builder: (context, state) => const DocumentsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/app_surveys',
                name: AppRouteNames.appSurveys,
                builder: (context, state) => const SurveysScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/app_survey_form',
                name: 'app_survey_form',
                builder: (context, state) {
                  final survey = state.extra as Survey;
                  return SurveyFormScreen(survey: survey);
                },
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/app_notifications',
                name: AppRouteNames.appNotifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/app_shop_products',
                name: AppRouteNames.appShopProducts,
                builder: (context, state) =>
                    const ProductsByCategoryScreen(isManagerDrawerRoute: true),
                routes: [
                  // a routes - placed as siblings under survey_analysis for accessibility from both shop_products and a_shop_products
                  GoRoute(
                    parentNavigatorKey: AppRouteNames.rootKey,
                    path: '/app_cart',
                    name: AppRouteNames.appCart,
                    builder: (context, state) => const CartScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: AppRouteNames.rootKey,
                        path: '/app_product_checkout',
                        name: AppRouteNames.appProductCheckout,
                        builder: (context, state) =>
                            const ProductCheckoutScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: AppRouteNames.rootKey,
                    path: '/app_product_detail/:productId',
                    name: AppRouteNames.appProductDetail,
                    builder: (context, state) {
                      final productId = int.tryParse(
                        state.pathParameters['productId'] ?? '',
                      );
                      return ProductDetailScreen(productId: productId);
                    },
                  ),
                ],
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/app_order_success',
                name: AppRouteNames.appOrderSuccess,
                builder: (context, state) {
                  final orderData = state.extra as Map<String, dynamic>? ?? {};
                  return OrderSuccessScreen(orderData: orderData);
                },
              ),
            ],
          ),
          // GoRoute(
          //   parentNavigatorKey: AppRouteNames.shellKey,
          //   path: '/app_news',
          //   name: AppRouteNames.appNews,
          //   builder: (context, state) => const NewsScreen(),
          // ),
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/home',
            name: AppRouteNames.home,
            builder: (context, state) => const ProductsByCategoryScreen(),
            routes: [
              GoRoute(
                path: '/cart',
                name: AppRouteNames.homeCart,
                builder: (context, state) => const CartScreen(),
              ),
              GoRoute(
                path: '/product_detail/:productId',
                name: AppRouteNames.productDetail,
                builder: (context, state) {
                  final productId = int.tryParse(
                    state.pathParameters['productId'] ?? '',
                  );
                  return ProductDetailScreen(productId: productId);
                },
              ),
              // Drawer Menu Routes - These use rootKey to navigate outside shell
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/news',
                name: AppRouteNames.news,
                builder: (context, state) => const NewsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/events',
                name: AppRouteNames.events,
                builder: (context, state) => const EventsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/projects',
                name: AppRouteNames.projects,
                builder: (context, state) => const ProjectsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/directory',
                name: AppRouteNames.directory,
                builder: (context, state) => const DirectoryScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/documents',
                name: AppRouteNames.documents,
                builder: (context, state) => const DocumentsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/surveys',
                name: AppRouteNames.surveys,
                builder: (context, state) => const SurveysScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/survey_form',
                name: 'survey_form',
                builder: (context, state) {
                  final survey = state.extra as Survey;
                  return SurveyFormScreen(survey: survey);
                },
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/notifications',
                name: AppRouteNames.notifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/chats',
                name: 'chats',
                builder: (context, state) => const ChatListScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/new_chat',
                name: 'new_chat',
                builder: (context, state) => const NewChatScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/chat',
                name: 'chat',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return ChatScreen(
                    chatId: extra?['chatId'] as int?,
                    recipientId: extra?['recipientId'] as int?,
                    recipientName: extra?['recipientName'] as String?,
                    recipientProfession:
                        extra?['recipientProfession'] as String?,
                    recipientImage: extra?['recipientImage'] as String?,
                    chatType: extra?['chatType'] as String?,
                  );
                },
              ),
              // GoRoute(
              //   parentNavigatorKey: AppRouteNames.rootKey,
              //   path: '/shop_products',
              //   name: AppRouteNames.shopProducts,
              //   builder: (context, state) => const ProductsByCategoryScreen(),
              // ),
            ],
          ),
          // GoRoute(
          //   parentNavigatorKey: AppRouteNames.shellKey,
          //   path: '/survey_analysis',
          //   name: AppRouteNames.surveyAnalysis,
          //   builder: (context, state) => const SurveyAnalysisScreen(),
          //   routes: [
          //     GoRoute(
          //       parentNavigatorKey: AppRouteNames.rootKey,
          //       path: '/shop_products',
          //       name: AppRouteNames.shopProducts,
          //       builder: (context, state) => const ProductsByCategoryScreen(),
          //     ),
          //     GoRoute(
          //       parentNavigatorKey: AppRouteNames.rootKey,
          //       path: '/manager_notifications',
          //       name: AppRouteNames.managerNotifications,
          //       builder: (context, state) => const NotificationsScreen(),
          //     ),
          //     // Manager-specific drawer routes (within shell for proper back navigation)
          //     GoRoute(
          //       parentNavigatorKey: AppRouteNames.rootKey,
          //       path: '/manager_news',
          //       name: AppRouteNames.managerNews,
          //       builder: (context, state) => const NewsScreen(),
          //     ),
          //     GoRoute(
          //       parentNavigatorKey: AppRouteNames.rootKey,
          //       path: '/manager_events',
          //       name: AppRouteNames.managerEvents,
          //       builder: (context, state) => const EventsScreen(),
          //     ),
          //     GoRoute(
          //       parentNavigatorKey: AppRouteNames.rootKey,
          //       path: '/manager_directory',
          //       name: AppRouteNames.managerDirectory,
          //       builder: (context, state) => const DirectoryScreen(),
          //     ),
          //     GoRoute(
          //       parentNavigatorKey: AppRouteNames.rootKey,
          //       path: '/manager_documents',
          //       name: AppRouteNames.managerDocuments,
          //       builder: (context, state) => const DocumentsScreen(),
          //     ),
          //     GoRoute(
          //       parentNavigatorKey: AppRouteNames.rootKey,
          //       path: '/manager_shop_products',
          //       name: AppRouteNames.managerShopProducts,
          //       builder: (context, state) =>
          //           const ProductsByCategoryScreen(isManagerDrawerRoute: true),
          //       routes: [
          //         // Manager routes - placed as siblings under survey_analysis for accessibility from both shop_products and manager_shop_products
          //         GoRoute(
          //           parentNavigatorKey: AppRouteNames.rootKey,
          //           path: '/manager_cart',
          //           name: AppRouteNames.managerCart,
          //           builder: (context, state) => const CartScreen(),
          //           routes: [
          //             GoRoute(
          //               parentNavigatorKey: AppRouteNames.rootKey,
          //               path: '/manager_product_checkout',
          //               name: AppRouteNames.managerProductCheckout,
          //               builder: (context, state) =>
          //                   const ProductCheckoutScreen(),
          //             ),
          //           ],
          //         ),
          //         GoRoute(
          //           parentNavigatorKey: AppRouteNames.rootKey,
          //           path: '/manager_product_detail/:productId',
          //           name: AppRouteNames.managerProductDetail,
          //           builder: (context, state) {
          //             final productId = int.tryParse(
          //               state.pathParameters['productId'] ?? '',
          //             );
          //             return ProductDetailScreen(productId: productId);
          //           },
          //         ),
          //       ],
          //     ),
          //     GoRoute(
          //       parentNavigatorKey: AppRouteNames.rootKey,
          //       path: '/manager_order_success',
          //       name: AppRouteNames.managerOrderSuccess,
          //       builder: (context, state) {
          //         final orderData = state.extra as Map<String, dynamic>? ?? {};
          //         return OrderSuccessScreen(orderData: orderData);
          //       },
          //     ),
          //     GoRoute(
          //       parentNavigatorKey: AppRouteNames.rootKey,
          //       path: '/all_surveys',
          //       name: AppRouteNames.allSurveys,
          //       builder: (context, state) => const AllSurveysScreen(),
          //     ),
          //   ],
          // ),
          // GoRoute(
          //   parentNavigatorKey: AppRouteNames.shellKey,
          //   path: '/member_news',
          //   name: AppRouteNames.memberNews,
          //   builder: (context, state) => const NewsScreen(),
          // ),
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/member_projects',
            name: AppRouteNames.memberProjects,
            builder: (context, state) => const ProjectsScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/member_notifications',
                name: AppRouteNames.memberNotifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
              // Manager-specific drawer routes (within shell for proper back navigation)
              // GoRoute(
              //   parentNavigatorKey: AppRouteNames.rootKey,
              //   path: '/member_events',
              //   name: AppRouteNames.memberEvents,
              //   builder: (context, state) => const EventsScreen(),
              // ),
              // GoRoute(
              //   parentNavigatorKey: AppRouteNames.rootKey,
              //   path: '/member_directory',
              //   name: AppRouteNames.memberDirectory,
              //   builder: (context, state) => const DirectoryScreen(),
              // ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/member_documents',
                name: AppRouteNames.memberDocuments,
                builder: (context, state) => const DocumentsScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/member_surveys',
                name: AppRouteNames.memberSurvey,
                builder: (context, state) => const SurveysScreen(),
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/member_shop_products',
                name: AppRouteNames.memberShopProducts,
                builder: (context, state) =>
                    const ProductsByCategoryScreen(isManagerDrawerRoute: true),
                routes: [
                  // member routes - placed as siblings under survey_analysis for accessibility from both shop_products and member_shop_products
                  GoRoute(
                    parentNavigatorKey: AppRouteNames.rootKey,
                    path: '/member_cart',
                    name: AppRouteNames.memberCart,
                    builder: (context, state) => const CartScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: AppRouteNames.rootKey,
                        path: '/member_product_checkout',
                        name: AppRouteNames.memberProductCheckout,
                        builder: (context, state) =>
                            const ProductCheckoutScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: AppRouteNames.rootKey,
                    path: '/member_product_detail/:productId',
                    name: AppRouteNames.memberProductDetail,
                    builder: (context, state) {
                      final productId = int.tryParse(
                        state.pathParameters['productId'] ?? '',
                      );
                      return ProductDetailScreen(productId: productId);
                    },
                  ),
                ],
              ),
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/member_order_success',
                name: AppRouteNames.memberOrderSuccess,
                builder: (context, state) {
                  final orderData = state.extra as Map<String, dynamic>? ?? {};
                  return OrderSuccessScreen(orderData: orderData);
                },
              ),
            ],
          ),
          // GoRoute(
          //   parentNavigatorKey: AppRouteNames.shellKey,
          //   path: '/member_news',
          //   name: AppRouteNames.memberNews,
          //   builder: (context, state) => const NewsScreen(),
          // ),
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/user_product',
            name: AppRouteNames.userProduct,
            builder: (context, state) => const ProductsByCategoryScreen(),
            routes: [
              GoRoute(
                path: '/user_cart',
                name: AppRouteNames.userCart,
                builder: (context, state) => const CartScreen(),
              ),
              GoRoute(
                path: '/user_product_detail/:productId',
                name: AppRouteNames.userProductDetail,
                builder: (context, state) {
                  final productId = int.tryParse(
                    state.pathParameters['productId'] ?? '',
                  );
                  return ProductDetailScreen(productId: productId);
                },
              ),
              GoRoute(
                path: '/product_checkout',
                name: AppRouteNames.productCheckout,
                builder: (context, state) => const ProductCheckoutScreen(),
              ),
              GoRoute(
                path: '/order_success',
                name: AppRouteNames.orderSuccess,
                builder: (context, state) {
                  final orderData = state.extra as Map<String, dynamic>? ?? {};
                  return OrderSuccessScreen(orderData: orderData);
                },
              ),
            ],
          ),
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/user_news',
            name: AppRouteNames.userNews,
            builder: (context, state) => const NewsScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: AppRouteNames.rootKey,
                path: '/user_notifications',
                name: AppRouteNames.userNotifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          // GoRoute(
          //   parentNavigatorKey: AppRouteNames.shellKey,
          //   path: '/manager_statistics',
          //   name: AppRouteNames.managerStatistics,
          //   builder: (context, state) => const ManagerStatisticsScreen(),
          // ),
          GoRoute(
            parentNavigatorKey: AppRouteNames.shellKey,
            path: '/manager_projects',
            name: AppRouteNames.managerProjects,
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/shop',
            name: AppRouteNames.shop,
            builder: (context, state) => ShopScreen(),
            routes: [
              GoRoute(
                path: '/:shopId',
                name: AppRouteNames.shopDetail,
                builder: (context, state) {
                  final shopId = int.tryParse(
                    state.pathParameters['shopId'] ?? '',
                  );
                  return ShopHomeScreen(shopId: shopId ?? 0);
                },
                routes: [
                  GoRoute(
                    path: '/cart',
                    name: AppRouteNames.shopCart,
                    builder: (context, state) => const CartScreen(),
                  ),
                  GoRoute(
                    path: '/product_detail/:productId',
                    name: AppRouteNames.shopProductDetail,
                    builder: (context, state) {
                      final productId = int.tryParse(
                        state.pathParameters['productId'] ?? '',
                      );
                      return ProductDetailScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // GoRoute(
          //   path: '/statistics',
          //   name: AppRouteNames.statistics,
          //   builder: (context, state) => const StatisticsScreen(),
          // ),
          // GoRoute(
          //   path: '/product_checkout',
          //   name: AppRouteNames.productCheckout,
          //   builder: (context, state) => const ProductCheckoutScreen(),
          // ),
          // GoRoute(
          //   path: '/order_success',
          //   name: AppRouteNames.orderSuccess,
          //   builder: (context, state) {
          //     final orderData = state.extra as Map<String, dynamic>? ?? {};
          //     return OrderSuccessScreen(orderData: orderData);
          //   },
          // ),
          GoRoute(
            path: '/favorites',
            name: AppRouteNames.favorites,
            builder: (context, state) => WishListItemsScreen(),
          ),
          GoRoute(
            path: '/all_branches_detail',
            name: AppRouteNames.allBranchesDetail,
            builder: (context, state) => const CompaniesScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: AppRouteNames.profile,
            builder: (context, state) => ProfileScreen(),
            routes: [
              GoRoute(
                path: '/edit_profile',
                name: AppRouteNames.editProfile,
                builder: (context, state) => EditProfileScreen(),
              ),
              GoRoute(
                path: '/orders',
                name: AppRouteNames.orders,
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: '/order_detail/:orderId',
                    name: AppRouteNames.orderDetail,
                    builder: (context, state) {
                      final orderId = int.tryParse(
                        state.pathParameters['orderId'] ?? '',
                      );
                      return OrderDetailScreen(orderId: orderId ?? 0);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: '/subscription_selection',
                name: AppRouteNames.subscriptionSelection,
                builder: (context, state) {
                  final subscriptionType = state.uri.queryParameters['type'];
                  return SubscriptionSelectionScreen(
                    subscriptionType: subscriptionType,
                  );
                },
                routes: [
                  GoRoute(
                    path:
                        '/subscription_checkout/:subscriptionId/:billingOption',
                    name: AppRouteNames.subscriptionCheckout,
                    builder: (context, state) {
                      final subscriptionId = int.tryParse(
                        state.pathParameters['subscriptionId'] ?? '',
                      );
                      final billingOption =
                          state.pathParameters['billingOption'] ?? 'monthly';
                      final plansFor = state.uri.queryParameters['plansFor'];
                      return SubscriptionCheckoutScreen(
                        subscriptionId: subscriptionId,
                        billingOption: billingOption,
                        plansFor: plansFor,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _StubScreen extends StatelessWidget {
  final String title;

  const _StubScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title screen coming soon')),
    );
  }
}
