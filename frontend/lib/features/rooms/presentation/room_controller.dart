import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/room_repository.dart';
import '../models/room_model.dart';

final roomFilterStatusProvider = StateProvider<String?>((ref) => null);
final roomFilterTypeProvider = StateProvider<String?>((ref) => null);

final roomsListProvider = FutureProvider.autoDispose<List<RoomModel>>((ref) async {
  final repo = ref.watch(roomRepositoryProvider);
  final status = ref.watch(roomFilterStatusProvider);
  final type = ref.watch(roomFilterTypeProvider);
  return repo.getAllRooms(status: status, type: type);
});
