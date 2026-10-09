import 'package:flutter/material.dart';
import 'package:mecity_marketplace/models/event.dart';
import 'package:mecity_marketplace/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  final EventService _eventService = EventService();

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EventProvider() {
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _eventService.getAllEvents();
      if (response.success == true && response.events != null) {
        _events = response.events!.map((e) => EventModel.fromApiJson(e.toJson())).toList();
      } else {
        _errorMessage = 'Failed to load events';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
