import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../models/booking_model.dart';

final myBookingsProvider = FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getMyBookings();
});

final allBookingsFilterStatusProvider = StateProvider<String?>((ref) => null);

final allBookingsProvider = FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final status = ref.watch(allBookingsFilterStatusProvider);
  return repo.getAllBookings(status: status);
});
