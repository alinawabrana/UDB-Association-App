import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/features/auth/models/user_model.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/notifications/providers/notification_providers.dart';
import 'package:udb_association/src/features/shop/providers/cart_providers.dart';
import 'package:udb_association/src/features/shop/providers/shop_providers.dart';
import 'package:udb_association/src/features/subscription/providers/subscription_booking_provider.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/src/features/splash/providers/splash_providers.dart';
import 'package:udb_association/src/features/splash/models/splash_image.dart';
import 'package:udb_association/utils/constants/urls.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/localization/language_toggle_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _initializedCalls = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedCalls) {
      _initializedCalls = true;
      _triggerInitialDataFetch();
    }
  }

  Future<void> _triggerInitialDataFetch() async {
    try {
      await ref.read(profileProvider.future);
    } catch (error, stackTrace) {
      debugPrint('HomeScreen profile preload failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) {
      return;
    }

    final fetchTasks = [
      () => ref.read(categoriesProvider.future),
      () => ref.read(productsProvider.future),
      () => ref.read(cartCountProvider.future),
      () => ref.read(subscriptionBookingsProvider.future),
      () => ref.read(userHasApprovedSubscriptionProvider.future),
      () => ref.read(unreadNotificationsCountProvider.future),
      () => ref.read(activeSplashImagesProvider.future),
    ];

    for (final task in fetchTasks) {
      if (!mounted) {
        break;
      }
      try {
        await task();
      } catch (error, stackTrace) {
        debugPrint('HomeScreen preload task failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(profileProvider);
    final unreadNotificationsAsync = ref.watch(
      unreadNotificationsCountProvider,
    );
    final subscriptionStatusAsync = ref.watch(
      userHasApprovedSubscriptionProvider,
    );
    final splashImagesAsync = ref.watch(activeSplashImagesProvider);

    return profileAsync.when(
      data: (user) {
        final navChipData = _buildRoleBasedChips(user.role, l10n);
        final routeState = GoRouterState.of(context);
        final currentLocation =
            routeState.fullPath ?? routeState.uri.toString();

        return Scaffold(
          backgroundColor: const Color(0xFF6B7C32),
          body: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7C32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HomeHeader(
                          user: user,
                          unreadAsync: unreadNotificationsAsync,
                        ),
                        const SizedBox(height: 12),
                        _RoleNavigationRow(
                          chips: navChipData,
                          currentLocation: currentLocation,
                          subscriptionStatusAsync: subscriptionStatusAsync,
                          onChipTap: (chip) => _handleNavChipTap(context, chip),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _HomeHeroSection(splashImagesAsync: splashImagesAsync),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('loading_dashboard_error'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(profileProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7A47),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.translate('retry')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavChipTap(BuildContext context, _RoleNavigationChip chip) {
    final navigatorContext = AppRouteNames.rootKey.currentContext ?? context;
    navigatorContext.goNamed(chip.routeName);
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.user, required this.unreadAsync});

  final User user;
  final AsyncValue<int> unreadAsync;

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = ApiUrls.getProfileImageUrl(user.profileImage);
    final unreadCount = unreadAsync.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth < 400;

        // Adjust sizes based on screen width
        final logoSize = isSmallScreen ? 32.0 : (isMediumScreen ? 35.0 : 38.0);
        final titleFontSize = isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);
        final userNameFontSize = isSmallScreen ? 9.0 : (isMediumScreen ? 10.0 : 11.0);
        final iconSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 22.0);
        final avatarRadius = isSmallScreen ? 15.0 : (isMediumScreen ? 16.5 : 18.0);
        final spacing = isSmallScreen ? 4.0 : (isMediumScreen ? 5.0 : 6.0);
        final horizontalSpacing = isSmallScreen ? 6.0 : (isMediumScreen ? 7.0 : 8.0);
        final badgeSize = isSmallScreen ? 14.0 : 16.0;
        final badgeFontSize = isSmallScreen ? 8.0 : 9.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
              width: logoSize,
              height: logoSize,
          decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(logoSize / 2),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
              padding: EdgeInsets.all(logoSize * 0.15),
          child: Image.asset('assets/icons/UDB_LOGO.jpeg', fit: BoxFit.contain),
        ),
            SizedBox(width: horizontalSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Udb',
                      style: TextStyle(
                            fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Connect',
                      style: TextStyle(
                            fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
                  SizedBox(height: spacing / 2),
              Text(
                user.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: userNameFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.35,
                ),
              ),
            ],
          ),
        ),
            SizedBox(width: spacing),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: iconSize + 16,
                    minHeight: iconSize + 16,
                  ),
              onPressed: () {
                final targetContext =
                    AppRouteNames.rootKey.currentContext ?? context;
                targetContext.goNamed(AppRouteNames.appNotifications);
              },
                  icon: Icon(
                Icons.notifications_none_rounded,
                    size: iconSize,
                color: Colors.white,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                    right: isSmallScreen ? 4 : 6,
                top: 4,
                child: Container(
                      width: badgeSize,
                      height: badgeSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: TextStyle(
                      color: Colors.white,
                          fontSize: badgeFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
            SizedBox(width: spacing),
        const LanguageToggleButton(),
            SizedBox(width: spacing),
        CircleAvatar(
              radius: avatarRadius,
          backgroundColor: const Color(0xFFE5E7EB),
          backgroundImage: profileImageUrl.isNotEmpty
              ? NetworkImage(profileImageUrl)
              : null,
          child: profileImageUrl.isEmpty
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: const Color(0xFF1F2937),
                    fontWeight: FontWeight.w700,
                        fontSize: avatarRadius * 0.7,
                  ),
                )
              : null,
        ),
      ],
        );
      },
    );
  }
}

class _HomeHeroSection extends StatefulWidget {
  const _HomeHeroSection({required this.splashImagesAsync});

  final AsyncValue<List<SplashImage>> splashImagesAsync;

  @override
  State<_HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<_HomeHeroSection> {
  final carousel.CarouselSliderController _carouselController =
      carousel.CarouselSliderController();
  int _currentIndex = 0;
  bool _imagesPreloaded = false;
  List<String>? _preloadedImageUrls;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  void _preloadImages() {
    if (_imagesPreloaded) return;

    // Handle both when data is already available and when it becomes available
    widget.splashImagesAsync.when(
      data: (images) {
        final imageUrls = images
            .map((img) => ApiUrls.getMediaUrl(img.splashUrl))
            .where((url) => url.isNotEmpty)
            .toList();

        if (imageUrls.isEmpty || !mounted) return;

        // Preload all images in parallel
        final futures = imageUrls.map((url) {
          return precacheImage(NetworkImage(url), context);
        }).toList();

        Future.wait(futures)
            .then((_) {
              if (mounted) {
                setState(() {
                  _imagesPreloaded = true;
                  _preloadedImageUrls = imageUrls;
                });
                debugPrint(
                  '[SplashCarousel] All ${imageUrls.length} images preloaded successfully',
                );
              }
            })
            .catchError((error) {
              debugPrint('[SplashCarousel] Error preloading images: $error');
              // Still show carousel even if preload fails - images will load on demand
              if (mounted) {
                setState(() {
                  _imagesPreloaded = true;
                  _preloadedImageUrls = imageUrls;
                });
              }
            });
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Trigger preloading if not already done
    if (!_imagesPreloaded) {
      _preloadImages();
    }

    return widget.splashImagesAsync.when(
      data: (images) {
        final imageUrls = images
            .map((img) => ApiUrls.getMediaUrl(img.splashUrl))
            .where((url) => url.isNotEmpty)
            .toList();
        if (imageUrls.isEmpty) {
          return const _HeroFallback(showLoader: true);
        }
        debugPrint('[SplashCarousel] Image URLs: $imageUrls');

        // Show loading indicator while preloading
        if (!_imagesPreloaded || _preloadedImageUrls == null) {
          return const _HeroFallback(showLoader: true);
        }

        return _HeroCarousel(
          controller: _carouselController,
          imageUrls: _preloadedImageUrls!,
          currentIndex: _currentIndex,
          onIndexChanged: (index) => setState(() => _currentIndex = index),
        );
      },
      loading: () => const _HeroFallback(showLoader: true),
      error: (_, __) => const _HeroFallback(showLoader: true),
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  const _HeroCarousel({
    required this.controller,
    required this.imageUrls,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  final carousel.CarouselSliderController controller;
  final List<String> imageUrls;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.4;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Build all carousel items upfront instead of using builder
            carousel.CarouselSlider(
              carouselController: controller,
              items: imageUrls.map((imageUrl) {
                return _HeroImage(imageUrl: imageUrl);
              }).toList(),
              options: carousel.CarouselOptions(
                height: height,
                viewportFraction: 1,
                enableInfiniteScroll: imageUrls.length > 1,
                autoPlay: imageUrls.length > 1,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 700),
                autoPlayCurve: Curves.easeInOut,
                onPageChanged: (index, __) => onIndexChanged(index),
              ),
            ),
            const _HeroGradientOverlay(),
            if (imageUrls.length > 1)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imageUrls.length, (index) {
                    final isActive = index == currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isActive ? 0.9 : 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        // Show fallback image while loading
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          // Show fallback image with loading indicator
          return Stack(
            fit: StackFit.expand,
            children: [
              // Fallback image while loading
              Image.asset(
                'assets/images/Fallback_home.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF6B7C32),
                  );
                },
              ),
              if (loadingProgress.expectedTotalBytes != null)
                Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!,
                    color: Colors.white70,
                    strokeWidth: 2,
                  ),
                ),
            ],
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const _HeroFallback(showLoader: false);
        },
      ),
    );
  }
}

class _HeroGradientOverlay extends StatelessWidget {
  const _HeroGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00FFFFFF), Color(0x33000000)],
          ),
        ),
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({this.showLoader = false});

  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fallback image
        Image.asset(
          'assets/images/Fallback_home.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) {
            // If asset fails to load, show colored background
            return Container(
              color: const Color(0xFF6B7C32),
            );
          },
        ),
        const _HeroGradientOverlay(),
        if (showLoader)
          const Center(child: CircularProgressIndicator(color: Colors.white70)),
      ],
    );
  }
}

class _RoleNavigationRow extends StatelessWidget {
  const _RoleNavigationRow({
    required this.chips,
    required this.currentLocation,
    required this.subscriptionStatusAsync,
    required this.onChipTap,
  });

  final List<_RoleNavigationChip> chips;
  final String currentLocation;
  final AsyncValue<bool> subscriptionStatusAsync;
  final ValueChanged<_RoleNavigationChip> onChipTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: _CotisationStatusChip(
            subscriptionStatusAsync: subscriptionStatusAsync,
          ),
        ),
        const SizedBox(width: 8),
        if (chips.isEmpty)
          const Expanded(flex: 6, child: SizedBox.shrink())
        else
          Expanded(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                if (availableWidth <= 0) {
                  return const SizedBox.shrink();
                }

                const double minChipWidth = 78;
                const double maxChipWidth = 132;
                const double visibleCount = 2.5;
                double chipWidth = availableWidth / visibleCount;
                chipWidth = chipWidth.clamp(minChipWidth, maxChipWidth);

                return SizedBox(
                  height: 44,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: chips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final chip = chips[index];
                      final width = chipWidth + 25;
                      return SizedBox(
                        width: width,
                        child: _RoleNavigationPill(
                          chip: chip,
                          isSelected: chip.isLocationMatch(currentLocation),
                          onTap: () => onChipTap(chip),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CotisationStatusChip extends StatelessWidget {
  const _CotisationStatusChip({required this.subscriptionStatusAsync});

  final AsyncValue<bool> subscriptionStatusAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool? isApproved = subscriptionStatusAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final bool isLoading = subscriptionStatusAsync.isLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        
        final fontSize = isSmallScreen ? 9.5 : 10.5;
        final iconSize = isSmallScreen ? 16.0 : 18.0;
        final indicatorSize = isSmallScreen ? 12.0 : 14.0;
        final padding = isSmallScreen 
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 7)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 9);
        final spacing = isSmallScreen ? 4.0 : 6.0;
        final dividerHeight = isSmallScreen ? 20.0 : 24.0;

    return Container(
      width: double.infinity,
          padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF3CAB55),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
              Flexible(
                child: Text(
            l10n.translate('cotisations'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
              color: Colors.white,
                    fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
              ),
              SizedBox(width: spacing),
          Container(
            width: 1.2,
                height: dividerHeight,
            color: Colors.white.withOpacity(0.3),
          ),
              SizedBox(width: spacing + 2),
          if (isLoading)
                SizedBox(
                  width: indicatorSize,
                  height: indicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else ...[
            Icon(
              Icons.check_circle,
              color: isApproved == true
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
                  size: iconSize,
            ),
                SizedBox(width: spacing - 2),
            Icon(
              Icons.cancel,
              color: isApproved == false
                  ? const Color(0xFFE53935)
                  : Colors.white.withOpacity(0.45),
                  size: iconSize,
            ),
          ],
        ],
      ),
        );
      },
    );
  }
}

class _RoleNavigationPill extends StatelessWidget {
  const _RoleNavigationPill({
    required this.chip,
    required this.isSelected,
    required this.onTap,
  });

  final _RoleNavigationChip chip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    final Color baseColor = chip.backgroundColor;
    final Color inactiveColor = Color.lerp(baseColor, Colors.white, 0.28)!;

    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final iconInnerSize = isSmallScreen ? 9.0 : 10.0;
    final fontSize = isSmallScreen ? 9.5 : 10.5;
    final padding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 7)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final spacing = isSmallScreen ? 6.0 : 8.0;

    return AnimatedScale(
      scale: isSelected ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: padding,
          decoration: BoxDecoration(
            color: isSelected ? baseColor : inactiveColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: baseColor.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(chip.icon, size: iconInnerSize, color: Colors.white),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Text(
                  chip.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleNavigationChip {
  const _RoleNavigationChip({
    required this.label,
    required this.icon,
    required this.routeName,
    required this.location,
    required this.matchingPrefixes,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final String routeName;
  final String location;
  final List<String> matchingPrefixes;
  final Color backgroundColor;

  bool isLocationMatch(String location) {
    for (final prefix in matchingPrefixes) {
      if (location.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }
}

List<_RoleNavigationChip> _buildRoleBasedChips(
  String? role,
  AppLocalizations l10n,
) {
  final normalizedRole = role?.toLowerCase();
  final chips = <_RoleNavigationChip>[];

  if (normalizedRole == 'member' || normalizedRole == 'manager') {
    chips.add(
      _RoleNavigationChip(
        label: l10n.translate('documents'),
        icon: Icons.folder_open_outlined,
        routeName: AppRouteNames.appDocuments,
        location: '/app_documents',
        matchingPrefixes: const ['/app_documents'],
        backgroundColor: const Color(0xFF2F80ED),
      ),
    );
  }

  if (normalizedRole == 'member') {
    chips.add(
      _RoleNavigationChip(
        label: l10n.translate('surveys'),
        icon: Icons.assignment_outlined,
        routeName: AppRouteNames.appSurveys,
        location: '/app_surveys',
        matchingPrefixes: const ['/app_surveys'],
        backgroundColor: const Color(0xFFEB5757),
      ),
    );
  }

  if (normalizedRole == 'manager') {
    chips.add(
      _RoleNavigationChip(
        label: l10n.translate('drawer_survey_analysis'),
        icon: Icons.bar_chart_outlined,
        routeName: AppRouteNames.surveyAnalysis,
        location: '/survey_analysis',
        matchingPrefixes: const ['/survey_analysis'],
        backgroundColor: const Color(0xFFF2994A),
      ),
    );
  }

  if (normalizedRole == 'manager' || normalizedRole == 'vendor') {
    final statsRoute = normalizedRole == 'manager'
        ? AppRouteNames.managerStatistics
        : AppRouteNames.statistics;
    final statsPrefixes = normalizedRole == 'manager'
        ? const ['/manager_statistics']
        : const ['/statistics'];
    chips.add(
      _RoleNavigationChip(
        label: l10n.translate('statistics'),
        icon: Icons.insights_outlined,
        routeName: statsRoute,
        location: statsPrefixes.first,
        matchingPrefixes: statsPrefixes,
        backgroundColor: const Color(0xFF27AE60),
      ),
    );
  }

  return chips;
}
