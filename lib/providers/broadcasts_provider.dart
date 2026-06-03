import 'dart:collection';

import 'package:bonsoir/bonsoir.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BroadcastedServicesProvider extends ChangeNotifier {
  /// Internal, the active BonsoirBroadcast instances.
  final Set<BonsoirBroadcast> _broadcasts = <BonsoirBroadcast>{};

  /// The active services.
  UnmodifiableListView<BonsoirBroadcast> get broadcasts => UnmodifiableListView(_broadcasts.sortedBy((broadcast) => broadcast.service.name));

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
    BonsoirBroadcast broadcast = BonsoirBroadcast(service: service);

    await broadcast.ready;

    broadcast.eventStream!.listen((event) {
      if (event.type == BonsoirBroadcastEventType.broadcastNameAlreadyExists) {
        print('Service already exists');
        _broadcasts.remove(broadcast);
      } else if (event.type == BonsoirBroadcastEventType.broadcastStopped) {
        print('Service stopped');
      } else if (event.type == BonsoirBroadcastEventType.broadcastStarted) {
        print('Service started');
      } else if (event.type == BonsoirBroadcastEventType.unknown) {
        print('Error: ${event}');
        _broadcasts.remove(broadcast);
      }
      notifyListeners();
    }, onError: (error) {
      print('Error2: ${error}');
    }, onDone: () {
      print('Done');
    });

    await broadcast.start();
    print('--> Broadcasting service: ${broadcast}');
    _broadcasts.add(broadcast);
    notifyListeners();
  }
}
