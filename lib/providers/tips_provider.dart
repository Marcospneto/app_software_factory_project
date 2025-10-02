import 'package:flutter/material.dart';
import 'package:meu_tempo/config/local_database.dart';
import 'package:meu_tempo/services/tips_service.dart';
import 'package:meu_tempo/models/tips.dart';

class TipsProvider with ChangeNotifier {
  final TipsService _tipsService = TipsService();
  final LocalDatabase _localDatabase = LocalDatabase();
  bool _loading = false;
  TipResponse? _tip;
  DateTime? _lastTipDate;
  bool _isInitialized = false;

  TipResponse? get tip => _tip;
  bool get loading => _loading;
  DateTime? get lastTipDate => _lastTipDate;
  bool get isInitialized => _isInitialized;
  
    Future<void> initialize() async {
    if (!_isInitialized) {
      await _loadFromLocalDatabase();
      _isInitialized = true;
    }
  }


  Future<void> _loadFromLocalDatabase() async {
    final tipId = await _localDatabase.getData('tipId');
    final tipName = await _localDatabase.getData('tipName');
    final tipDate = await _localDatabase.getData('tipDate');
    
    if (tipName != null && tipId != null) {
      _tip = TipResponse(id: tipId, name: tipName);    
    }

    if (tipDate != null) {
      _lastTipDate = DateTime.fromMillisecondsSinceEpoch(tipDate);
    }
    notifyListeners();
  }

  Future<void> _saveToLocalDatabase() async {
    if (_tip != null) {
      await _localDatabase.saveData(_tip!.id, 'tipId');
      await _localDatabase.saveData(_tip!.name, 'tipName');
    }
    if (_localDatabase != null) {
      await _localDatabase.saveData(_lastTipDate!.millisecondsSinceEpoch, 'tipDate');

    }
  }

  Future<void> fetchTip() async {
    _loading = true;
    notifyListeners();
    
    try {
      _tip = await _tipsService.getTip();
      _lastTipDate = DateTime.now();
      await _saveToLocalDatabase();
    } catch (e) {
      _tip = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool fetchNewTip() {
    if (_tip == null) {
      return true;
    }

    if (_lastTipDate == null) return true;
      
    final now = DateTime.now();
    final lastTipDate = _lastTipDate;
    
    return !(now.day == _lastTipDate!.day &&
        now.month == _lastTipDate!.month &&
        now.year == _lastTipDate!.year);
  }
}