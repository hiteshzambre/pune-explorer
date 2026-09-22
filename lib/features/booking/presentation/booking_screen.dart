import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/coupon.dart';
import '../../../data/models/tour_package.dart';
import '../../../data/models/tour_customization.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/booking_cutoff_validator.dart';
import '../../../core/widgets/error_boundary.dart';
import '../../../services/booking_service.dart';
import 'widgets/tour_details_view.dart';
import 'widgets/customize_addons_view.dart';
import 'widgets/traveler_details_view.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String tourId;
  final int initialStep;

  const BookingScreen({
    super.key,
    required this.tourId,
    this.initialStep = 0,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late int _currentStep; // 0: Tour Details, 1: Customize & Add-ons, 2: Traveler Details
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _dateInitializedForTour = false;
  int _travelersCount = 1;
  String? _selectedPickupPoint;
  List<String> _selectedSeats = [];
  double _seatExtraTotal = 0.0;
  TourCustomization _customization = const TourCustomization();

  Coupon? _appliedCoupon;

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerEmailController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  final List<TextEditingController> _passengerNameControllers = [];
  final List<TextEditingController> _passengerAgeControllers = [];

  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _syncPassengerControllers();
  }

  void _syncPassengerControllers() {
    while (_passengerNameControllers.length < _travelersCount) {
      final idx = _passengerNameControllers.length;
      _passengerNameControllers.add(TextEditingController(text: idx == 0 ? '' : 'Passenger ${idx + 1}'));
      _passengerAgeControllers.add(TextEditingController());
    }
    while (_passengerNameControllers.length > _travelersCount) {
      _passengerNameControllers.removeLast().dispose();
      _passengerAgeControllers.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    for (var c in _passengerNameControllers) {
      c.dispose();
    }
    for (var c in _passengerAgeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyCoupon(List<Coupon> availableCoupons, String code, double subtotal) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return;

    try {
      final found = availableCoupons.firstWhere(
        (c) => c.code.toUpperCase() == trimmed,
      );

      if (subtotal < found.minBookingAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Min booking amount of ₹${found.minBookingAmount.toInt()} required for ${found.code}.')),
        );
        return;
      }
      if (_travelersCount < found.minTravelers) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coupon requires at least ${found.minTravelers} travelers.')),
        );
        return;
      }

      setState(() => _appliedCoupon = found);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coupon ${found.code} applied successfully!')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coupon code. Try PUNEPASS20')),
      );
    }
  }

  Future<void> _processBookingCheckout(TourPackage tour, PricingBreakdown pricing) async {
    final cutoffError = BookingCutoffValidator.validateBookingDate(date: _selectedDate, tour: tour);
    if (cutoffError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cutoffError),
          backgroundColor: Colors.red.shade800,
        ),
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (_customerNameController.text.trim().isEmpty ||
        _customerEmailController.text.trim().isEmpty ||
        _customerPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your contact information.')),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final List<String> effectiveSeats = List.from(_selectedSeats);
      if (effectiveSeats.length < _travelersCount) {
        // BK2: Fallback seat assignment — used only when user skips seat picker UI.
        // Assigns sequentially from a standard 4-row (A-D) bus layout.
        final defaultSeatPool = ['A1', 'A2', 'A3', 'A4', 'B1', 'B2', 'B3', 'B4', 'C1', 'C2', 'C3', 'C4', 'D1', 'D2'];
        for (final seat in defaultSeatPool) {
          if (!effectiveSeats.contains(seat)) {
            effectiveSeats.add(seat);
            if (effectiveSeats.length >= _travelersCount) break;
          }
        }
      }

      final List<Passenger> passengers = [];
      for (int i = 0; i < _travelersCount; i++) {
        passengers.add(
          Passenger(
            fullName: _passengerNameControllers[i].text.trim(),
            age: int.tryParse(_passengerAgeControllers[i].text.trim()) ?? 25,
            gender: 'Adult',
            seatNumber: i < effectiveSeats.length ? effectiveSeats[i] : 'A${i + 1}',
          ),
        );
      }

      final effectivePickup = (_selectedPickupPoint != null && tour.pickupPoints.contains(_selectedPickupPoint))
          ? _selectedPickupPoint!
          : (tour.pickupPoints.isNotEmpty ? tour.pickupPoints.first : 'Swargate Bus Stand (5:30 AM)');

      // Create booking in pendingPayment state
      final booking = BookingService.createBooking(
        tourId: tour.id,
        tourTitle: tour.title,
        travelDate: DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
        pickupPoint: effectivePickup,
        passengers: passengers,
        selectedSeats: effectiveSeats,
        pricing: pricing,
        customization: _customization.copyWith(travelersCount: _travelersCount),
        appliedCoupon: _appliedCoupon?.code,
        customerName: _customerNameController.text.trim(),
        customerEmail: _customerEmailController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        status: BookingStatus.pendingPayment,
      );

      // Create authoritative PaymentOrder
      final order = await ref.read(paymentOrdersProvider.notifier).createOrder(
        bookingId: booking.id,
        userId: _customerEmailController.text.trim(),
        packageId: tour.id,
        packageName: tour.title,
        amount: pricing.totalAmount,
      );

      // Save the pending booking with orderId linked
      final linkedBooking = booking.copyWith(
        orderId: order.orderId,
        paymentStatus: PaymentStatus.pendingPayment,
        paymentMethod: 'UPI QR',
      );
      await ref.read(userBookingsProvider.notifier).addBooking(linkedBooking);

      if (mounted) {
        context.push('/payment/qr/${order.orderId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not initialize payment order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourPackagesAsync = ref.watch(tourPackagesAsyncProvider);
    final couponsAsync = ref.watch(couponsAsyncProvider);

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      child: tourPackagesAsync.when(
        data: (packages) {
          final tour = packages.where((p) => p.id == widget.tourId).firstOrNull ??
              ((widget.tourId == 'pkg_darshan_royal' || widget.tourId == 'pkg_darshan')
                  ? packages.where((p) => p.id == 'PNE-DAR-01').firstOrNull
                  : null) ??
              (packages.isNotEmpty ? packages.first : null);

          if (tour == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Tour Package')),
              body: const ErrorBoundaryWidget(
                errorMessage: 'Tour package not found. It may have been removed or is no longer available.',
              ),
            );
          }

          final availableCoupons = couponsAsync.value ?? [];
          final effectiveCustomization = _customization.copyWith(travelersCount: _travelersCount);
          final pricing = BookingService.calculatePricing(
            tourPrice: tour.price,
            travelers: _travelersCount,
            seatExtraPrice: _seatExtraTotal,
            customization: effectiveCustomization,
            coupon: _appliedCoupon,
          );

          if (!_dateInitializedForTour) {
            _dateInitializedForTour = true;
            if (!BookingCutoffValidator.isDateSelectable(_selectedDate, tour)) {
              _selectedDate = BookingCutoffValidator.getEarliestSelectableDate(tour);
            }
          }

          switch (_currentStep) {
            case 0:
              // PAGE 1: TOUR DETAILS
              return Scaffold(
                body: SafeArea(
                  child: TourDetailsView(
                    tour: tour,
                    initialDate: _selectedDate,
                    initialTravelers: _travelersCount,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/darshan');
                      }
                    },
                    onContinueToBooking: (date, travelers) {
                      setState(() {
                        _selectedDate = date;
                        _travelersCount = travelers;
                        _syncPassengerControllers();
                        _currentStep = 1;
                      });
                    },
                  ),
                ),
              );

            case 1:
              // PAGE 2: CUSTOMIZE & ADD-ONS
              return Scaffold(
                body: SafeArea(
                  child: CustomizeAddonsView(
                    tour: tour,
                    selectedDate: _selectedDate,
                    travelersCount: _travelersCount,
                    customization: effectiveCustomization,
                    onDateChanged: (d) => setState(() => _selectedDate = d),
                    onTravelersChanged: (t) {
                      setState(() {
                        _travelersCount = t;
                        _syncPassengerControllers();
                      });
                    },
                    onCustomizationChanged: (c) => setState(() => _customization = c),
                    onBack: () => setState(() => _currentStep = 0),
                    onContinue: () => setState(() => _currentStep = 2),
                  ),
                ),
              );

            case 2:
            default:
              // PAGE 3: TRAVELER DETAILS & FARE SUMMARY
              return Scaffold(
                body: SafeArea(
                  child: TravelerDetailsView(
                    tour: tour,
                    travelersCount: _travelersCount,
                    pricing: pricing,
                    availableCoupons: availableCoupons,
                    appliedCoupon: _appliedCoupon,
                    selectedPickupPoint: _selectedPickupPoint,
                    selectedSeats: _selectedSeats,
                    primaryNameController: _customerNameController,
                    primaryEmailController: _customerEmailController,
                    primaryPhoneController: _customerPhoneController,
                    passengerNameControllers: _passengerNameControllers,
                    passengerAgeControllers: _passengerAgeControllers,
                    onPickupChanged: (p) => setState(() => _selectedPickupPoint = p),
                    onSeatsChanged: (seats, extra) {
                      setState(() {
                        _selectedSeats = seats;
                        _seatExtraTotal = extra;
                      });
                    },
                    onApplyCoupon: (code) => _applyCoupon(availableCoupons, code, pricing.subtotal),
                    onRemoveCoupon: () => setState(() => _appliedCoupon = null),
                    onTravelersCountChanged: (t) {
                      setState(() {
                        _travelersCount = t;
                        _syncPassengerControllers();
                      });
                    },
                    onBack: () => setState(() => _currentStep = 1),
                    onProceedToPayment: () => _processBookingCheckout(tour, pricing),
                    isProcessing: _isProcessingPayment,
                  ),
                ),
              );
          }
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: ErrorBoundaryWidget(errorMessage: e.toString())),
      ),
    );
  }
}
