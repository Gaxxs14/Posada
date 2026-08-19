import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/booking_model.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepository(apiClient.dio);
});

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  Future<BookingQuoteModel> getQuote({
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestsCount,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.bookingQuote,
        data: {
          'roomId': roomId,
          'checkInDate': checkInDate.toIso8601String(),
          'checkOutDate': checkOutDate.toIso8601String(),
          'guestsCount': guestsCount,
        },
      );

      if (response.data['success'] == true) {
        return BookingQuoteModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Error al cotizar');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Error al calcular cotización');
    }
  }

  Future<BookingModel> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.bookings, data: data);
      if (response.data['success'] == true) {
        return BookingModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Error al crear reservación');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Error al procesar reservación');
    }
  }

  Future<List<BookingModel>> getMyBookings() async {
    final response = await _dio.get(ApiEndpoints.myBookings);
    if (response.data['success'] == true) {
      final List list = response.data['data'] ?? [];
      return list.map((item) => BookingModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<List<BookingModel>> getAllBookings({String? status, DateTime? date}) async {
    final response = await _dio.get(
      ApiEndpoints.bookings,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (date != null) 'date': date.toIso8601String(),
      },
    );
    if (response.data['success'] == true) {
      final List list = response.data['data'] ?? [];
      return list.map((item) => BookingModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> updateStatus(String bookingId, String status, {String? adminNotes}) async {
    final response = await _dio.patch(
      '${ApiEndpoints.bookings}/$bookingId/status',
      data: {'status': status, 'adminNotes': adminNotes},
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Error al actualizar estado');
    }
  }

  Future<void> checkIn(String bookingId) async {
    final response = await _dio.post('${ApiEndpoints.bookings}/$bookingId/check-in');
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Error al realizar Check-in');
    }
  }

  Future<void> checkOut(String bookingId) async {
    final response = await _dio.post('${ApiEndpoints.bookings}/$bookingId/check-out');
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Error al realizar Check-out');
    }
  }

  Future<void> addPayment(String bookingId, Map<String, dynamic> data) async {
    final response = await _dio.post('${ApiEndpoints.bookings}/$bookingId/payments', data: data);
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Error al registrar pago');
    }
  }

  Future<void> addExtraCharge(String bookingId, Map<String, dynamic> data) async {
    final response = await _dio.post('${ApiEndpoints.bookings}/$bookingId/extra-charges', data: data);
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Error al agregar cargo extra');
    }
  }
}
