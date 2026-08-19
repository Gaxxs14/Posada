import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/room_model.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoomRepository(apiClient.dio);
});

class RoomRepository {
  final Dio _dio;

  RoomRepository(this._dio);

  Future<List<RoomModel>> getAllRooms({String? status, String? type}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.rooms,
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
          if (type != null && type.isNotEmpty) 'type': type,
        },
      );

      if (response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((item) => RoomModel.fromJson(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Error al cargar habitaciones');
    }
  }

  Future<RoomModel> getRoomById(String id) async {
    final response = await _dio.get('${ApiEndpoints.rooms}/$id');
    if (response.data['success'] == true) {
      return RoomModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Habitación no encontrada');
  }

  Future<void> updateRoomStatus(String id, String status) async {
    final response = await _dio.patch(
      '${ApiEndpoints.rooms}/$id/status',
      data: {'status': status},
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Error al actualizar estado');
    }
  }

  Future<void> createRoom(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.rooms, data: data);
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Error al crear habitación');
    }
  }

  Future<void> deleteRoom(String id) async {
    final response = await _dio.delete('${ApiEndpoints.rooms}/$id');
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Error al eliminar habitación');
    }
  }
}
