import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/breakpoints.dart';
import 'widgets/auth_hero_section.dart';
import 'widgets/password_strength_meter.dart';

enum AuthViewMode { login, register, forgotPassword, success }

enum MobileAuthStep { welcome, onboarding1, onboarding2, onboarding3, auth, success }

/// Premium, production-grade authentication screen for PuneExplorer
/// featuring desktop 2-column editorial storytelling and a dedicated 7-screen mobile journey.
class AuthScreen extends ConsumerStatefulWidget {
  final String? redirectPath;
  const AuthScreen({super.key, this.redirectPath});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  AuthViewMode _currentMode = AuthViewMode.login;
  MobileAuthStep _mobileStep = MobileAuthStep.auth;

  // Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  final _forgotEmailController = TextEditingController();

  // State flags
  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;
  bool _rememberMe = true;
  bool _agreeTerms = true;
  bool _isLoading = false;
  bool _resetSent = false;
  String? _errorMessage;

  // In-place field validation errors
  String? _regNameError;
  String? _regEmailError;
  String? _regPhoneError;
  String? _regPasswordError;
  String? _regConfirmPasswordError;
  String? _regTermsError;

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0.0);
    HapticFeedback.vibrate();
  }

  void _clearRegErrors() {
    _regNameError = null;
    _regEmailError = null;
    _regPhoneError = null;
    _regPasswordError = null;
    _regConfirmPasswordError = null;
    _regTermsError = null;
  }

  void _switchMode(AuthViewMode mode) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentMode = mode;
      _errorMessage = null;
      _resetSent = false;
      _clearRegErrors();
    });
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      _triggerShake();
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      _triggerShake();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    try {
      final user = await ref.read(authStateProvider.notifier).signIn(email, password);
      if (mounted) {
        final targetRedirect = widget.redirectPath;
        final isAdminTarget = targetRedirect != null &&
            (targetRedirect.contains('/admin') || targetRedirect == '/admin' || targetRedirect == '/admin/dashboard');

        final isAdmin = user.isAdmin ||
            user.role.toLowerCase().contains('admin') ||
            user.role.toLowerCase().contains('editor') ||
            user.role.toLowerCase().contains('support') ||
            email.toLowerCase().startsWith('admin@') ||
            email.toLowerCase() == 'admin@puneexplorer.com' ||
            email.toLowerCase() == 'admin@puneexplorer.in';

        if (isAdminTarget && !isAdmin) {
          setState(() => _errorMessage = 'Access denied: This account does not possess administrator privileges.');
          _triggerShake();
          return;
        }

        if (isAdmin) {
          await ref.read(adminSessionProvider.notifier).reloadSession();
        }

        if (!mounted) return;

        if (isAdmin) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Text('👑', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Expanded(child: Text('Admin authentication successful. Welcome to Command Hub.')),
                ],
              ),
              backgroundColor: AppColors.authPrimaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          final destination = (targetRedirect != null && targetRedirect.isNotEmpty && targetRedirect != '/auth')
              ? targetRedirect
              : '/admin/dashboard';
          context.go(destination);
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Welcome back, ${email.split('@').first}! Ready to explore Pune.')),
                ],
              ),
              backgroundColor: AppColors.authPrimaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go(targetRedirect ?? '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Login failed: ${e.toString().replaceAll("Exception: ", "")}');
        _triggerShake();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final phone = _regPhoneController.text.trim();
    final password = _regPasswordController.text.trim();
    final confirmPassword = _regConfirmPasswordController.text.trim();

    bool hasError = false;
    String? firstErrorMessage;

    setState(() {
      _clearRegErrors();
      _errorMessage = null;

      if (name.isEmpty) {
        _regNameError = 'Name is required';
        firstErrorMessage ??= 'Please provide your full name.';
        hasError = true;
      }

      if (email.isEmpty) {
        _regEmailError = 'Email is required';
        firstErrorMessage ??= 'Please enter your email address.';
        hasError = true;
      } else if (!email.contains('@') || !email.contains('.')) {
        _regEmailError = 'Enter a valid email';
        firstErrorMessage ??= 'Please enter a valid email address.';
        hasError = true;
      }

      if (phone.isNotEmpty && phone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
        _regPhoneError = '10-digit number required';
        firstErrorMessage ??= 'Please enter a valid 10-digit mobile number.';
        hasError = true;
      }

      if (password.isEmpty) {
        _regPasswordError = 'Password is required';
        firstErrorMessage ??= 'Please create a password.';
        hasError = true;
      } else if (password.length < 8) {
        _regPasswordError = 'Min 8 characters';
        firstErrorMessage ??= 'Password must be at least 8 characters with numbers & symbols.';
        hasError = true;
      }

      if (confirmPassword.isEmpty) {
        _regConfirmPasswordError = 'Confirm password';
        firstErrorMessage ??= 'Please confirm your password.';
        hasError = true;
      } else if (password != confirmPassword) {
        _regConfirmPasswordError = 'Passwords do not match';
        firstErrorMessage ??= 'Passwords do not match. Please verify.';
        hasError = true;
      }

      if (!_agreeTerms) {
        _regTermsError = 'Accept terms to proceed';
        firstErrorMessage ??= 'Please accept the PuneExplorer terms & conditions.';
        hasError = true;
      }

      if (hasError) {
        _errorMessage = firstErrorMessage;
      }
    });

    if (hasError) {
      _triggerShake();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    try {
      await ref.read(authStateProvider.notifier).register(name, email, password, phone);
      if (mounted) {
        setState(() {
          _currentMode = AuthViewMode.success;
          _mobileStep = MobileAuthStep.success;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Registration failed: ${e.toString().replaceAll("Exception: ", "")}');
        _triggerShake();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _forgotEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid registered email address.');
      _triggerShake();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // A3: Simulated password reset — replace with real API call when backend is ready.
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _resetSent = true;
      });
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _handleGuest() async {
    HapticFeedback.mediumImpact();
    await ref.read(authStateProvider.notifier).continueAsGuest();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktopMin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.authBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isDesktop ? _buildDesktopLayout(isDark) : _buildMobileLayout(isDark, screenWidth),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // 1. DESKTOP TWO-COLUMN LAYOUT (~55% LEFT / ~45% RIGHT)
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        // Left Column: Immersive Travel Storytelling Panel
        Expanded(
          flex: 55,
          child: AuthHeroSection(
            isCompact: false,
            isRegisterMode: _currentMode == AuthViewMode.register,
          ),
        ),

        // Right Column: Fixed in Place Authentication Card
        Expanded(
          flex: 45,
          child: Container(
            color: isDark ? AppColors.darkBackground : AppColors.authBackground,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _buildAuthCard(isDark, isDesktop: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // 2. MOBILE DEDICATED EXPERIENCE (7 SPECIFICATION SCREENS)
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(bool isDark, double screenWidth) {
    // Check if on onboarding step
    switch (_mobileStep) {
      case MobileAuthStep.welcome:
        return _buildMobileWelcome(isDark);
      case MobileAuthStep.onboarding1:
        return _buildMobileOnboarding(
          isDark: isDark,
          stepIndex: 1,
          imageAsset: 'assets/images/auth_bus_darshan_hd.jpg',
          title: 'Official Darshan Tours',
          subtitle: 'Travel comfortably with PMPML & MTDC official AC buses.',
          onNext: () => setState(() => _mobileStep = MobileAuthStep.onboarding2),
        );
      case MobileAuthStep.onboarding2:
        return _buildMobileOnboarding(
          isDark: isDark,
          stepIndex: 2,
          imageAsset: 'assets/images/auth_fort_heritage_hd.jpg',
          title: 'Explore Heritage & Forts',
          subtitle: 'Discover iconic landmarks, historical forts and hidden gems.',
          onNext: () => setState(() => _mobileStep = MobileAuthStep.onboarding3),
        );
      case MobileAuthStep.onboarding3:
        return _buildMobileOnboarding(
          isDark: isDark,
          stepIndex: 3,
          imageAsset: 'assets/images/auth_ai_bot_guide_hd.jpg',
          title: 'Your AI Travel Guide',
          subtitle: 'Get smart recommendations, plan trips and explore like a local.',
          onNext: () => setState(() => _mobileStep = MobileAuthStep.auth),
        );
      case MobileAuthStep.success:
        return _buildSuccessScreen(isDark);
      case MobileAuthStep.auth:
        return _buildMobileAuthFlow(isDark, screenWidth);
    }
  }

  /// Mobile Welcome Screen (Screen 1 in specification)
  Widget _buildMobileWelcome(bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBrandHeaderSmall(isDark),
                TextButton(
                  onPressed: () => setState(() => _mobileStep = MobileAuthStep.auth),
                  child: const Text('Skip', style: TextStyle(color: AppColors.authPrimaryGreen, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Headline
            const Text(
              'Pune Awaits You',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Forts, culture, spirituality and stories — discover the real Pune with PuneExplorer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: AppColors.authSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Hero Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/auth_hero_sinhagad_hd.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: AppColors.authPrimaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dots Indicator
            _buildDotsIndicator(0),
            const SizedBox(height: 20),

            // Get Started CTA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => setState(() => _mobileStep = MobileAuthStep.onboarding1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.authPrimaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Get Started →', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile Onboarding Screen (Screens 2, 3, 4)
  Widget _buildMobileOnboarding({
    required bool isDark,
    required int stepIndex,
    required String imageAsset,
    required String title,
    required String subtitle,
    required VoidCallback onNext,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBrandHeaderSmall(isDark),
                TextButton(
                  onPressed: () => setState(() => _mobileStep = MobileAuthStep.auth),
                  child: const Text('Skip', style: TextStyle(color: AppColors.authSecondary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hero Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: AppColors.authPrimaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title & Description
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: AppColors.authSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Dots & Next Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDotsIndicator(stepIndex),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.authPrimaryGreen,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile Authentication Flow (Sign In & Register)
  Widget _buildMobileAuthFlow(bool isDark, double screenWidth) {
    final isSmall = screenWidth < 360;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF071B13),
                  Color(0xFF0F172A),
                  Color(0xFF0D1B1E),
                ]
              : const [
                  Color(0xFFF0FDF4),
                  Color(0xFFF8FAFC),
                  Color(0xFFFFFBEB),
                ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 10 : 16,
              vertical: isSmall ? 6 : 10,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Scenic Brand Header with HD Pune Image & Vibrant Gradient
                  _buildMobileBrandBanner(isDark),
                  SizedBox(height: isSmall ? 6 : 8),

                  // Mini Heritage & Experience Feature Pills
                  _buildMobileFeaturePills(isDark, isSmall),
                  SizedBox(height: isSmall ? 6 : 8),

                  // Premium Auth Card
                  _buildAuthCard(isDark, isDesktop: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Mini Heritage & Experience Feature Pills on Mobile
  Widget _buildMobileFeaturePills(bool isDark, bool isSmall) {
    final pills = [
      (Icons.fort_outlined, '40+ Forts', AppColors.authPrimaryGreen, const Color(0xFFECFDF5)),
      (Icons.directions_bus_outlined, 'Pune Darshan', AppColors.saffron, const Color(0xFFFFFBEB)),
      (Icons.auto_awesome_rounded, 'AI Guide', AppColors.skyBlue, const Color(0xFFF0F9FF)),
    ];

    return Row(
      children: pills.map((p) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            padding: EdgeInsets.symmetric(vertical: isSmall ? 4 : 5.5, horizontal: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : p.$4,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? p.$3.withValues(alpha: 0.3)
                    : p.$3.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(p.$1, size: isSmall ? 11 : 12.5, color: p.$3),
                const SizedBox(width: 3.5),
                Flexible(
                  child: Text(
                    p.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSmall ? 9.5 : 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppColors.authDarkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileBrandBanner(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final isRegister = _currentMode == AuthViewMode.register;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.saffron.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.authPrimaryGreen.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            // Scenic Background Image
            Positioned.fill(
              child: Image.asset(
                isRegister
                    ? 'assets/images/auth_hero_arch_pune_hd.jpg'
                    : 'assets/images/auth_hero_sinhagad_hd.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.authPrimaryGreen),
              ),
            ),

            // Vibrant Pune Gradient Scrim Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.88),
                      const Color(0xFF0D5C3A).withValues(alpha: 0.82),
                      const Color(0xFFD97706).withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 8 : 12,
                vertical: isSmall ? 7 : 9,
              ),
              child: Row(
                children: [
                  // Glowing Saffron Flag Icon
                  Container(
                    width: isSmall ? 30 : 34,
                    height: isSmall ? 30 : 34,
                    decoration: BoxDecoration(
                      gradient: AppColors.saffronGradient,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.saffron.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('🚩', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: isSmall ? 8 : 10),

                  // Brand Text with Pune Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'PuneExplorer',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: isSmall ? 14 : 15.5,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.amber.shade200, width: 0.8),
                              ),
                              child: Text(
                                'पुणे',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Travel & Heritage Platform',
                          style: GoogleFonts.inter(
                            fontSize: isSmall ? 9.5 : 10.5,
                            color: Colors.white.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scenic Landmark Pill (only on screens >= 360 to prevent tight overflow)
                  if (screenWidth >= 360)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isRegister ? Icons.location_city_rounded : Icons.landscape_rounded,
                            size: 11,
                            color: Colors.amber.shade200,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isRegister ? 'Pune City' : 'Sinhagad',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // 3. PREMIUM AUTHENTICATION CARD (SHARED BY DESKTOP & MOBILE)
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildAuthCard(bool isDark, {required bool isDesktop}) {
    final isRegister = _currentMode == AuthViewMode.register;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : AppColors.authPrimaryGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Multi-Color Pune Accent Bar (Emerald -> Saffron -> Gold -> Sky Blue)
            Container(
              height: 3.5,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D5C3A),
                    Color(0xFF10B981),
                    Color(0xFFF59E0B),
                    Color(0xFFFBBF24),
                    Color(0xFF0EA5E9),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : (screenWidth < 360 ? 12 : 18),
                vertical: isDesktop
                    ? (isRegister ? 16 : 20)
                    : (screenWidth < 360 ? 10 : 14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Segmented Tabs [ Sign In ] [ Create Account ]
                  if (_currentMode != AuthViewMode.forgotPassword && _currentMode != AuthViewMode.success)
                    _buildSegmentedTabs(isDark),

                  SizedBox(height: isRegister ? 8 : 12),

                  // Error Message Display (for login / forgot password)
                  if (_errorMessage != null && _currentMode != AuthViewMode.register) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Form Body
                  _buildFormContent(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Segmented Tabs: [ Sign In ] [ Create Account ]
  Widget _buildSegmentedTabs(bool isDark) {
    final isSignIn = _currentMode == AuthViewMode.login;

    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _switchMode(AuthViewMode.login),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 7.5),
                decoration: BoxDecoration(
                  gradient: isSignIn
                      ? const LinearGradient(
                          colors: [Color(0xFF0D5C3A), Color(0xFF059669)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSignIn
                      ? [
                          BoxShadow(
                            color: AppColors.authPrimaryGreen.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign In',
                  style: GoogleFonts.plusJakartaSans(
                    color: isSignIn ? Colors.white : AppColors.authSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _switchMode(AuthViewMode.register),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 7.5),
                decoration: BoxDecoration(
                  gradient: !isSignIn
                      ? const LinearGradient(
                          colors: [Color(0xFF0D5C3A), Color(0xFF059669)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: !isSignIn
                      ? [
                          BoxShadow(
                            color: AppColors.authPrimaryGreen.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Create Account',
                  style: GoogleFonts.plusJakartaSans(
                    color: !isSignIn ? Colors.white : AppColors.authSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(bool isDark) {
    switch (_currentMode) {
      case AuthViewMode.login:
        return _buildSignInForm(isDark);
      case AuthViewMode.register:
        return _buildRegisterForm(isDark);
      case AuthViewMode.forgotPassword:
        return _buildForgotPasswordForm(isDark);
      case AuthViewMode.success:
        return _buildSuccessScreen(isDark);
    }
  }

  /// Sign In Form Content
  Widget _buildSignInForm(bool isDark) {
    return Column(
      key: const ValueKey('signin_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heading & Subtitle
        Text(
          'Welcome back, Punekar Explorer 👋',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.5,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
            color: isDark ? Colors.white : AppColors.authDarkText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Glad to see you again. Continue your journey with PuneExplorer.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.authSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),

        // Email Field
        _buildTextField(
          controller: _loginEmailController,
          label: 'Email Address',
          icon: Icons.mail_outline_rounded,
          iconColor: AppColors.authPrimaryGreen,
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // Password Field
        _buildTextField(
          controller: _loginPasswordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.saffron,
          obscureText: _obscureLoginPassword,
          isDark: isDark,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureLoginPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: AppColors.authSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          ),
        ),
        const SizedBox(height: 6),

        // Remember Me & Forgot Password Row
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.authPrimaryGreen,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _rememberMe = val ?? true),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Remember me',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _switchMode(AuthViewMode.forgotPassword),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.authPrimaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Primary Sign In CTA
        _buildPrimaryButton(
          text: 'Sign In to PuneExplorer',
          icon: Icons.arrow_forward_rounded,
          onPressed: _isLoading ? null : _handleLogin,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 12),

        // Social Login Divider
        _buildOrDivider('OR CONTINUE WITH'),
        const SizedBox(height: 10),

        // Social Login Buttons
        _buildSocialLoginRow(isDark),
        const SizedBox(height: 10),

        // Explore as Guest Card
        _buildGuestCard(isDark),
      ],
    );
  }

  /// Register Form Content
  Widget _buildRegisterForm(bool isDark) {
    return Column(
      key: const ValueKey('register_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heading & Subtitle
        Text(
          'Join PuneExplorer Community 🌟',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17.5,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
            color: isDark ? Colors.white : AppColors.authDarkText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Create an account to book tours, save itineraries and explore the real Pune with us.',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.authSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),

        // Full Name
        _buildTextField(
          controller: _regNameController,
          label: 'Full Name',
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF0D9488),
          errorText: _regNameError,
          onChanged: (_) {
            if (_regNameError != null) setState(() => _regNameError = null);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 6),

        // Email Address
        _buildTextField(
          controller: _regEmailController,
          label: 'Email Address',
          icon: Icons.mail_outline_rounded,
          iconColor: AppColors.authPrimaryGreen,
          keyboardType: TextInputType.emailAddress,
          errorText: _regEmailError,
          onChanged: (_) {
            if (_regEmailError != null) setState(() => _regEmailError = null);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 6),

        // Mobile Number (+91)
        _buildTextField(
          controller: _regPhoneController,
          label: 'Mobile Number (+91)',
          icon: Icons.phone_outlined,
          iconColor: AppColors.skyBlue,
          keyboardType: TextInputType.phone,
          errorText: _regPhoneError,
          onChanged: (_) {
            if (_regPhoneError != null) setState(() => _regPhoneError = null);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 6),

        // Create Password
        _buildTextField(
          controller: _regPasswordController,
          label: 'Create Password',
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.saffron,
          obscureText: _obscureRegPassword,
          errorText: _regPasswordError,
          isDark: isDark,
          onChanged: (_) {
            setState(() {
              if (_regPasswordError != null) _regPasswordError = null;
            });
          },
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRegPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: AppColors.authSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
          ),
        ),
        const SizedBox(height: 3),

        // Subtle Password Strength Meter
        if (_regPasswordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: PasswordStrengthMeter(password: _regPasswordController.text),
          ),

        // Confirm Password
        _buildTextField(
          controller: _regConfirmPasswordController,
          label: 'Confirm Password',
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF10B981),
          obscureText: _obscureRegConfirmPassword,
          errorText: _regConfirmPasswordError,
          isDark: isDark,
          onChanged: (_) {
            if (_regConfirmPasswordError != null) setState(() => _regConfirmPasswordError = null);
          },
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRegConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: AppColors.authSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
          ),
        ),
        const SizedBox(height: 6),

        // Terms Checkbox
        Container(
          padding: _regTermsError != null
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
              : EdgeInsets.zero,
          decoration: _regTermsError != null
              ? BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _agreeTerms,
                      activeColor: AppColors.authPrimaryGreen,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          _agreeTerms = val ?? true;
                          if (_agreeTerms) _regTermsError = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'I agree to the Terms & Conditions and Privacy Policy',
                      style: GoogleFonts.inter(fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
              if (_regTermsError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 2),
                  child: Text(
                    _regTermsError!,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // In-Place Error Alert Banner
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.error,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Primary Create Account CTA
        _buildPrimaryButton(
          text: 'Create Account & Explore',
          icon: Icons.person_add_alt_1_rounded,
          onPressed: _isLoading ? null : _handleRegister,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 10),

        // Divider
        _buildOrDivider('OR SIGN UP WITH'),
        const SizedBox(height: 8),

        // Social Buttons
        _buildSocialLoginRow(isDark),
      ],
    );
  }

  /// Forgot Password Form
  Widget _buildForgotPasswordForm(bool isDark) {
    return Column(
      key: const ValueKey('forgot_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _switchMode(AuthViewMode.login),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Recover Your Explorer Account 🔐',
                style: GoogleFonts.plusJakartaSans(fontSize: 18.5, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your registered email address and we\'ll send a secure password recovery link.',
          style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.authSecondary, height: 1.4),
        ),
        const SizedBox(height: 18),

        if (_resetSent) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.authEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.authEmerald.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Reset Link Sent!',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.authPrimaryGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check your inbox and follow the instructions to reset your password.',
                  style: GoogleFonts.inter(fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildPrimaryButton(
            text: 'Return to Sign In',
            icon: Icons.login_rounded,
            onPressed: () => _switchMode(AuthViewMode.login),
          ),
        ] else ...[
          _buildTextField(
            controller: _forgotEmailController,
            label: 'Email Address',
            icon: Icons.mail_outline_rounded,
            iconColor: AppColors.authPrimaryGreen,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
          ),
          const SizedBox(height: 18),
          _buildPrimaryButton(
            text: 'Send Recovery Link',
            icon: Icons.send_rounded,
            onPressed: _isLoading ? null : _handleForgotPassword,
            isLoading: _isLoading,
          ),
        ],
      ],
    );
  }

  /// Success Confirmation Screen (Screen 7 in specification)
  Widget _buildSuccessScreen(bool isDark) {
    return Center(
      child: Column(
        key: const ValueKey('success_screen'),
        mainAxisSize: MainAxisSize.min,
        children: [
          // Green Circle Checkmark
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.authEmerald,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.authEmerald.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),

          Text(
            'Welcome to PuneExplorer! 🎉',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your account has been created successfully. You can now explore Pune or sign in to access your personal bookings and profile.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.authSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Explore Now CTA
          _buildPrimaryButton(
            text: 'Explore Now',
            icon: Icons.explore_rounded,
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(height: 10),

          // Return to Sign In button
          TextButton(
            onPressed: () => _switchMode(AuthViewMode.login),
            child: Text(
              'Sign In with your credentials',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.authPrimaryGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Monument & Slogan
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/auth_success_heritage_hd.jpg',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Same Trails, New Stories.',
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: FontStyle.italic,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.authPrimaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // HELPER UI WIDGETS
  // ══════════════════════════════════════════════════════════════════════════════

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color? iconColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    required bool isDark,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    final effectiveIconColor = hasError ? AppColors.error : (iconColor ?? AppColors.authSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                color: hasError ? AppColors.error : (isDark ? Colors.white : AppColors.authDarkText),
              ),
            ),
            if (hasError)
              Flexible(
                child: Text(
                  errorText,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.error,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2.5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.authDarkText,
          ),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: Icon(
              icon,
              size: 18,
              color: effectiveIconColor,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
            filled: true,
            fillColor: hasError
                ? AppColors.error.withValues(alpha: isDark ? 0.12 : 0.04)
                : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.authPrimaryGreen,
                width: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: onPressed == null
            ? null
            : const LinearGradient(
                colors: [Color(0xFF0D5C3A), Color(0xFF059669)],
              ),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: AppColors.authPrimaryGreen.withValues(alpha: 0.32),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          disabledForegroundColor: const Color(0xFF64748B),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrDivider(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.authSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }

  Widget _buildSocialLoginRow(bool isDark) {
    return Row(
      children: [
        // Google
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google Sign-In ready')),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('G', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFEA4335))),
                const SizedBox(width: 8),
                Text('Google', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Apple
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Apple Sign-In ready')),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apple_rounded, size: 20),
                const SizedBox(width: 8),
                Text('Apple', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestCard(bool isDark) {
    return InkWell(
      onTap: _handleGuest,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.authPrimaryGreen.withValues(alpha: 0.18),
                    const Color(0xFF1E3A2F).withValues(alpha: 0.25),
                  ]
                : const [
                    Color(0xFFECFDF5),
                    Color(0xFFFEF3C7),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.authPrimaryGreen.withValues(alpha: 0.35)
                : AppColors.authPrimaryGreen.withValues(alpha: 0.3),
            width: 1.1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.authPrimaryGreen.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.explore_rounded, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore as Guest (No Login Required)',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFF34D399) : AppColors.authPrimaryGreen,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'No login required. Start exploring now!',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.authSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: isDark ? const Color(0xFF34D399) : AppColors.authPrimaryGreen,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBrandHeaderSmall(bool isDark) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.authPrimaryGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text('🚩', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 8),
        Text(
          'PuneExplorer',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDotsIndicator(int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.authPrimaryGreen : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
