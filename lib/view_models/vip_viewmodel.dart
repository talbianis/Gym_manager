import 'package:flutter/material.dart';
import 'package:gym_manager/database/db_helper.dart';
import 'package:gym_manager/models/vipclient.dart';

class VipClientViewModel extends ChangeNotifier {
  List<VipClient> _vipClients = [];
  List<VipClient> _filteredVipClients = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  VipClientFilter currentFilter = VipClientFilter.all;

  List<VipClient> get vipClients => _filteredVipClients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalVipClients => _vipClients.length;

  int get activeVipClients =>
      _vipClients.where((client) => client.isActive).length;

  int get expiredVipClients =>
      _vipClients.where((client) => client.isExpired).length;

  int get expiringInSevenDays => _vipClients
      .where(
        (client) =>
            client.isActive &&
            client.daysRemaining <= 7 &&
            client.daysRemaining > 0,
      )
      .length;

  int get expiringInFifteenDays => _vipClients
      .where(
        (client) =>
            client.isActive &&
            client.daysRemaining <= 15 &&
            client.daysRemaining > 0,
      )
      .length;

  int get expiringInFiveDays => _vipClients
      .where(
        (client) =>
            client.isActive &&
            client.daysRemaining <= 5 &&
            client.daysRemaining > 0,
      )
      .length;

  double get averageAge {
    if (_vipClients.isEmpty) return 0;
    return _vipClients.map((c) => c.age).reduce((a, b) => a + b) /
        _vipClients.length;
  }

  double get averageMembershipDuration {
    if (_vipClients.isEmpty) return 0;
    return _vipClients
            .map((c) => c.endDate.difference(c.startDate).inDays)
            .reduce((a, b) => a + b) /
        _vipClients.length;
  }

  int get clientsWithWeightLoss {
    return _vipClients.where((client) {
      final progress = client.weightProgress;
      return progress != null && progress < 0;
    }).length;
  }

  int get clientsWithWeightGain {
    return _vipClients.where((client) {
      final progress = client.weightProgress;
      return progress != null && progress > 0;
    }).length;
  }

  Future<void> loadVipClients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vipClients = await DBHelper.getAllVipClients();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load VIP clients: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVipClient(VipClient client) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await DBHelper.insertVipClient(client);
      if (id > 0) {
        await loadVipClients();
        return true;
      }
      _errorMessage = 'Failed to add VIP client';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error adding VIP client: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVipClient(VipClient client) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await DBHelper.updateVipClient(client);
      if (result > 0) {
        await loadVipClients();
        return true;
      }
      _errorMessage = 'Failed to update VIP client';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error updating VIP client: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVipClient(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await DBHelper.deleteVipClient(id);
      if (result > 0) {
        await loadVipClients();
        return true;
      }
      _errorMessage = 'Failed to delete VIP client';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error deleting VIP client: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addWeightEntry(int clientId, WeightEntry entry) async {
    try {
      final client = _vipClients.firstWhere((c) => c.id == clientId);
      final updatedWeights = [...client.weights, entry];
      final updatedClient = client.copyWith(weights: updatedWeights);
      return await updateVipClient(updatedClient);
    } catch (e) {
      _errorMessage = 'Error adding weight entry: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWeightEntry(
    int clientId,
    int weightIndex,
    WeightEntry newEntry,
  ) async {
    try {
      final client = _vipClients.firstWhere((c) => c.id == clientId);
      final updatedWeights = [...client.weights];
      updatedWeights[weightIndex] = newEntry;
      final updatedClient = client.copyWith(weights: updatedWeights);
      return await updateVipClient(updatedClient);
    } catch (e) {
      _errorMessage = 'Error updating weight entry: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWeightEntry(int clientId, int weightIndex) async {
    try {
      final client = _vipClients.firstWhere((c) => c.id == clientId);
      final updatedWeights = [...client.weights];
      updatedWeights.removeAt(weightIndex);
      final updatedClient = client.copyWith(weights: updatedWeights);
      return await updateVipClient(updatedClient);
    } catch (e) {
      _errorMessage = 'Error deleting weight entry: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> extendMembership(int clientId, int days) async {
    try {
      final client = _vipClients.firstWhere((c) => c.id == clientId);
      final newEndDate = client.endDate.add(Duration(days: days));
      final updatedClient = client.copyWith(endDate: newEndDate);
      return await updateVipClient(updatedClient);
    } catch (e) {
      _errorMessage = 'Error extending membership: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> renewMembership(int clientId, int durationDays) async {
    try {
      final client = _vipClients.firstWhere((c) => c.id == clientId);
      final now = DateTime.now();
      final newEndDate = now.add(Duration(days: durationDays));
      final updatedClient = client.copyWith(
        startDate: now,
        endDate: newEndDate,
      );
      return await updateVipClient(updatedClient);
    } catch (e) {
      _errorMessage = 'Error renewing membership: $e';
      notifyListeners();
      return false;
    }
  }

  void searchClients(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void filterClients(VipClientFilter filter) {
    currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<VipClient> filtered = List.from(_vipClients);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (client) =>
                client.name.toLowerCase().contains(_searchQuery) ||
                client.phone.contains(_searchQuery),
          )
          .toList();
    }

    switch (currentFilter) {
      case VipClientFilter.active:
        filtered = filtered.where((c) => c.isActive).toList();
        break;
      case VipClientFilter.expired:
        filtered = filtered.where((c) => c.isExpired).toList();
        break;
      case VipClientFilter.expiringSoon:
        filtered = filtered
            .where((c) => c.isActive && c.daysRemaining <= 30)
            .toList();
        break;
      case VipClientFilter.all:
        break;
    }

    _filteredVipClients = filtered;
  }

  void sortClients(VipClientSort sortBy, {bool ascending = true}) {
    switch (sortBy) {
      case VipClientSort.name:
        _filteredVipClients.sort(
          (a, b) =>
              ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
        );
        break;
      case VipClientSort.age:
        _filteredVipClients.sort(
          (a, b) => ascending ? a.age.compareTo(b.age) : b.age.compareTo(a.age),
        );
        break;
      case VipClientSort.startDate:
        _filteredVipClients.sort(
          (a, b) => ascending
              ? a.startDate.compareTo(b.startDate)
              : b.startDate.compareTo(a.startDate),
        );
        break;
      case VipClientSort.endDate:
        _filteredVipClients.sort(
          (a, b) => ascending
              ? a.endDate.compareTo(b.endDate)
              : b.endDate.compareTo(a.endDate),
        );
        break;
      case VipClientSort.daysRemaining:
        _filteredVipClients.sort(
          (a, b) => ascending
              ? a.daysRemaining.compareTo(b.daysRemaining)
              : b.daysRemaining.compareTo(a.daysRemaining),
        );
        break;
      case VipClientSort.weightProgress:
        _filteredVipClients.sort((a, b) {
          final progressA = a.weightProgress ?? 0;
          final progressB = b.weightProgress ?? 0;
          return ascending
              ? progressA.compareTo(progressB)
              : progressB.compareTo(progressA);
        });
        break;
    }
    notifyListeners();
  }

  VipClient? getClientById(int id) {
    try {
      return _vipClients.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<VipClient> getClientsExpiringIn(int days) {
    return _vipClients
        .where(
          (client) =>
              client.isActive &&
              client.daysRemaining <= days &&
              client.daysRemaining > 0,
        )
        .toList();
  }

  Map<String, int> getAgeDistribution() {
    final distribution = <String, int>{
      '18-25': 0,
      '26-35': 0,
      '36-45': 0,
      '46-55': 0,
      '56+': 0,
    };

    for (var client in _vipClients) {
      if (client.age >= 18 && client.age <= 25) {
        distribution['18-25'] = distribution['18-25']! + 1;
      } else if (client.age >= 26 && client.age <= 35) {
        distribution['26-35'] = distribution['26-35']! + 1;
      } else if (client.age >= 36 && client.age <= 45) {
        distribution['36-45'] = distribution['36-45']! + 1;
      } else if (client.age >= 46 && client.age <= 55) {
        distribution['46-55'] = distribution['46-55']! + 1;
      } else {
        distribution['56+'] = distribution['56+']! + 1;
      }
    }

    return distribution;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

enum VipClientFilter { all, active, expired, expiringSoon }

enum VipClientSort {
  name,
  age,
  startDate,
  endDate,
  daysRemaining,
  weightProgress,
}
