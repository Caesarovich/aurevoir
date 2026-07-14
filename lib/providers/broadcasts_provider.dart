import 'dart:collection';

import 'package:bonsoir/bonsoir.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:aurevoir/app_logger.dart';

final _logger = getLogger('BroadcastedServicesProvider');

class BroadcastedServicesProvider extends ChangeNotifier {
  /// Internal, the active BonsoirBroadcast instances.
  final Set<BonsoirBroadcast> _broadcasts = <BonsoirBroadcast>{};

  /// The active services.
  UnmodifiableListView<BonsoirBroadcast> get broadcasts => UnmodifiableListView(
      _broadcasts.sortedBy((broadcast) => broadcast.service.name));

  Future<void> resumeBroadcast(BonsoirBroadcast broadcast) async {
    if (broadcast.isReady) return;
    _broadcasts.remove(broadcast);
    await broadcastService(broadcast.service);
  }

  Future<void> stopBroadcast(BonsoirBroadcast broadcast) async {
    if (broadcast.isStopped) return;
    await broadcast.stop();
  }

  Future<void> removeBroadcast(BonsoirBroadcast broadcast) async {
    await stopBroadcast(broadcast);
    _broadcasts.remove(broadcast);
    notifyListeners();
  }

  Future<void> resumeAllBroadcasts() async {
    final List<BonsoirBroadcast> broadcastsCopy = List.from(_broadcasts);

    for (BonsoirBroadcast broadcast in broadcastsCopy) {
      await resumeBroadcast(broadcast);
    }
  }

  Future<void> stopAllBroadcasts() async {
    for (BonsoirBroadcast broadcast in _broadcasts) {
      await stopBroadcast(broadcast);
    }
  }

  Future<void> removeAllBroadcasts() async {
    await stopAllBroadcasts();
    _broadcasts.clear();
    notifyListeners();
  }

  /// Start the service broadcasting.
  Future<void> broadcastService(BonsoirService service) async {
    _logger.d('📡 Initializing broadcast for service: ${service.toJson()}');

    final broadcast = BonsoirBroadcast(service: service);
    await broadcast.initialize();

    _logger.i('📡 Broadcast initialized for service: ${service.toJson()}');

    broadcast.eventStream!.listen((event) {
      if (event is BonsoirBroadcastStartedEvent) {
        _logger.i('📡 Broadcast started for service: ${service.toJson()}');
      } else if (event is BonsoirBroadcastStoppedEvent) {
        _logger.i('📡 Broadcast stopped for service: ${service.toJson()}');
        notifyListeners();
      } else if (event is BonsoirBroadcastNameAlreadyExistsEvent) {
        _logger.w(
            '📡 Broadcast name already exists for service: ${service.toJson()}');
        _broadcasts.remove(broadcast);
        notifyListeners();
      } else if (event is BonsoirBroadcastUnknownEvent) {
        _logger.w(
            '📡 Broadcast unknown event for service: ${service.toJson()} - $event');
      } else {
        _logger.w(
            '📡 Broadcast unhandled event for service: ${service.toJson()} - $event');
      }
    }, onError: (error) {
      _logger.e('📡 Broadcast error for service: ${service.toJson()} - $error');
    }, onDone: () {
      _logger.i('📡 Broadcast done for service: ${service.toJson()}');
    }, cancelOnError: true);

    await broadcast.start();

    _logger.d('📡 Broadcast started for service: ${service.toJson()}');

    _broadcasts.add(broadcast);
    notifyListeners();
  }
}
