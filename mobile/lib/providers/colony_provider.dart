import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

class Colony {
  final String id;
  final String name;
  final String location;
  final int price;
  final double expectedRoi;
  final int fundedPercentage;
  final String status;
  final double temperature;
  final double humidity;
  final double weight;
  final int investorCount;

  Colony({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.expectedRoi,
    required this.fundedPercentage,
    required this.status,
    required this.temperature,
    required this.humidity,
    required this.weight,
    required this.investorCount,
  });

  factory Colony.fromJson(Map<String, dynamic> json) {
    return Colony(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      price: json['price'] ?? 0,
      expectedRoi: (json['expectedRoi'] ?? 0).toDouble(),
      fundedPercentage: json['fundedPercentage'] ?? 0,
      status: json['status'] ?? 'Faol',
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      investorCount: json['investorCount'] ?? 0,
    );
  }
}

class ColonyProvider with ChangeNotifier {
  final Dio _dio = Dio();
  List<Colony> _colonies = [];
  bool _isLoading = false;

  List<Colony> get colonies => _colonies;
  bool get isLoading => _isLoading;

  ColonyProvider() {
    // Load mock data initially to ensure UI looks good even if backend is down
    _colonies = [
      Colony(id: '1', name: 'Toshkent Oltin Asalxona', location: 'Toshkent viloyati', price: 1500000, expectedRoi: 18.5, fundedPercentage: 72, status: 'Sotuvda', temperature: 34.2, humidity: 62.0, weight: 45.2, investorCount: 12),
      Colony(id: '2', name: "Bo'stonliq Tog' Asalxonasi", location: "Bo'stonliq tumani", price: 2200000, expectedRoi: 22.0, fundedPercentage: 45, status: 'Faol', temperature: 32.8, humidity: 58.0, weight: 38.7, investorCount: 8),
      Colony(id: '3', name: 'Samarqand Vodiysi', location: 'Samarqand viloyati', price: 1800000, expectedRoi: 16.0, fundedPercentage: 88, status: "Yig'im", temperature: 35.1, humidity: 65.0, weight: 52.1, investorCount: 22),
    ];
  }

  Future<void> fetchColonies() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _dio.get(ApiConstants.getColonies);
      if (res.statusCode == 200) {
        final List data = res.data;
        _colonies = data.map((e) => Colony.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Backend ulanish xatosi (API dan ma\'lumot olinmadi, mock qoladi): $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addColony(Colony colony) async {
    _colonies.insert(0, colony); // Optimistic UI update
    notifyListeners();
    try {
      // Backend integratsiyasi
      // await _dio.post(ApiConstants.getColonies, data: colony.toJson());
    } catch (e) {
      debugPrint('Colony qo\'shishda xatolik: $e');
    }
  }

  Future<void> updateColony(Colony colony) async {
    final index = _colonies.indexWhere((c) => c.id == colony.id);
    if (index != -1) {
      _colonies[index] = colony;
      notifyListeners();
      try {
        // await _dio.put('${ApiConstants.getColonies}/${colony.id}', data: colony.toJson());
      } catch (e) {
        debugPrint('Colony tahrirlashda xatolik: $e');
      }
    }
  }

  Future<void> deleteColony(String id) async {
    _colonies.removeWhere((c) => c.id == id);
    notifyListeners();
    try {
      // await _dio.delete('${ApiConstants.getColonies}/$id');
    } catch (e) {
      debugPrint('Colony o\'chirishda xatolik: $e');
    }
  }
}
