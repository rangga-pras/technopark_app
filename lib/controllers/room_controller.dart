import 'package:flutter/foundation.dart';

import '../models/room.dart';
import '../services/api_service.dart';

class RoomController extends ChangeNotifier {
  RoomController(this._apiService);

  final ApiService _apiService;

  List<Room> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedCapacity;
  String _searchQuery = '';

  List<Room> get rooms => List.unmodifiable(_rooms);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedCapacity => _selectedCapacity;
  String get searchQuery => _searchQuery;

  List<Room> get filteredRooms {
    return _rooms.where((room) {
      final matchesCapacity =
          _selectedCapacity == null || room.capacity == _selectedCapacity;
      final normalizedQuery = _searchQuery.trim().toLowerCase();
      final matchesQuery =
          normalizedQuery.isEmpty ||
          room.name.toLowerCase().contains(normalizedQuery) ||
          room.capacity.toString().contains(normalizedQuery);
      return matchesCapacity && matchesQuery;
    }).toList();
  }

  Future<void> fetchRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await _apiService.getRooms();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Ruangan tidak dapat dimuat. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCapacityFilter(int? capacity) {
    if (_selectedCapacity == capacity) {
      return;
    }
    _selectedCapacity = capacity;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) {
      return;
    }
    _searchQuery = value;
    notifyListeners();
  }

  void clearFilters() {
    if (_selectedCapacity == null && _searchQuery.isEmpty) {
      return;
    }
    _selectedCapacity = null;
    _searchQuery = '';
    notifyListeners();
  }
}
