import 'package:flutter/material.dart';

class ZoomStateProvider extends ChangeNotifier {
  bool _isZoomOpen = false;

  bool get isZoomOpen => _isZoomOpen;

  void open() {
    if (!_isZoomOpen) {
      _isZoomOpen = true;
      notifyListeners();
    }
  }

  void setZoomOpen(bool value) {
    _isZoomOpen = value;
    notifyListeners();
  }

  void close() {
    if (_isZoomOpen) {
      _isZoomOpen = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isZoomOpen = !_isZoomOpen;
    notifyListeners();
  }
}
