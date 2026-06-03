import 'package:collection/collection.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

/// This provider is used to discover the available service types.
/// It also listens to the settings provider to get the user-defined service types.
class ServiceTypeProvider extends ChangeNotifier {
  /// Internal, the user-defined service types.
  List<String> _userDefinedServiceTypes = [];

  /// Internal, the active BonsoirDiscovery instance.
  BonsoirDiscovery? _serviceTypeDiscovery;

  /// Internal, the available service types.
  final List<String> _serviceTypes = [];

  /// The available service types.
  UnmodifiableSetView<String> get serviceTypes => UnmodifiableSetView(Set.from(_serviceTypes + _userDefinedServiceTypes));

  /// This is called when the user settings change.
  void updateUserDefinedServiceTypes(List<String> serviceTypes) {
    // This is to prevent notifying the listeners if the service types are the same.
    if (!const ListEquality().equals(_userDefinedServiceTypes, serviceTypes)) {
      _userDefinedServiceTypes = List.from(serviceTypes);
      notifyListeners();
    }
  }

  // This is needed because the wildcard service discovery returns the service in a different format.
  String _convertServiceType(BonsoirService service) {
    print('Service type: ${service}');
    return '${service.name}.${service.type.split('.').last}';
  }

  /// Start the service type discovery.
  void startServiceTypeDiscovery() async {
    if (_serviceTypeDiscovery != null) {
      return;
    }

    print('🔍Starting service type discovery');

    _serviceTypeDiscovery = BonsoirDiscovery(type: '_services._dns-sd._udp');
    await _serviceTypeDiscovery!.ready;
    print('🔍Started service type discovery');

    _serviceTypeDiscovery!.eventStream!.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        print('🔍Service Found');
        _serviceTypes.add(_convertServiceType(event.service!));
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        _serviceTypes.remove(_convertServiceType(event.service!));
      }
      notifyListeners();
    });

    _serviceTypeDiscovery!.start();
  }

  /// Stop the service type discovery.
  void stopServiceTypeDiscovery() async {
    _serviceTypeDiscovery?.stop();
    _serviceTypeDiscovery = null;
  }

  @override
  void dispose() {
    stopServiceTypeDiscovery();
    super.dispose();
  }

  ServiceTypeProvider() {
    startServiceTypeDiscovery();
  }
}

class ServiceProvider extends ChangeNotifier {
  bool _resolveServices = false;

  void updateServiceTypes(Set<String> serviceTypes) {
    print('🔍Updating service types: $serviceTypes');
    for (String type in serviceTypes) {
      try {
        startServiceDiscovery(type);
      } catch (e) {
        print('Error starting service discovery for $type: $e');
      }
    }

    for (String type in _discoveries.keys) {
      if (!serviceTypes.contains(type)) {
        stopServiceDiscovery(type);
      }
    }
  }

  void setResolveServices(bool resolveServices) {
    if (_resolveServices == resolveServices) return;

    _resolveServices = resolveServices;

    print('🔍Resolve services: $resolveServices');

    if (_resolveServices) {
      for (BonsoirService service in _services) {
        service.resolve(_discoveries[service.type]!.serviceResolver);
      }
    } else {
      _resolvedServices.clear();
    }

    notifyListeners();
  }

  /// Internal, the active BonsoirDiscovery instances.
  final Map<String, BonsoirDiscovery> _discoveries = {};

  /// Internal, the available services.
  final List<BonsoirService> _services = [];

  /// Internal, the resolved services.
  final List<ResolvedBonsoirService> _resolvedServices = [];

  /// The available services.
  UnmodifiableListView<BonsoirService> get services => UnmodifiableListView(_services);

  /// The resolved services.
  UnmodifiableListView<ResolvedBonsoirService> get resolvedServices => UnmodifiableListView(_resolvedServices);

  /// Start the service discovery for the given type.
  void startServiceDiscovery(String type) async {
    if (_discoveries.containsKey(type)) {
      return;
    }

    BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
    await discovery.ready;
    discovery.eventStream!.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        _onServiceFound(event.service!);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        _onServiceLost(event.service!);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        _onServiceResolved(event.service!);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolveFailed) {
        _onServiceResolvedError(event.service);
      }
    });

    _discoveries[type] = discovery;
    discovery.start();
  }

  void _onServiceFound(BonsoirService service) {
    print('❤Service Found');
    print(service);
    _services.add(service);
    notifyListeners();

    if (_resolveServices) service.resolve(_discoveries[service.type]!.serviceResolver);
  }

  void _onServiceResolved(BonsoirService service) {
    print('💦Service resolved : ${service.toJson()}');
    _resolvedServices.add(service as ResolvedBonsoirService);
    // _services.remove(service); TODO
    notifyListeners();
  }

  void _onServiceLost(BonsoirService service) {
    print('💔Service lost : ${service.toJson()}');
    _services.remove(service);
    _resolvedServices.removeWhere((resolvedService) => resolvedService.name == service.name);
    notifyListeners();
  }

  void _onServiceResolvedError(BonsoirService? service) {
    print('💦Service resolved error : ${service?.toJson()}');
  }

  /// Stop the service discovery for the given type.
  void stopServiceDiscovery(String type) async {
    if (!_discoveries.containsKey(type)) {
      return;
    }

    await _discoveries[type]!.stop();
    _discoveries.remove(type);
    _services.removeWhere((service) => service.type == type);
    notifyListeners();
  }

  /// Stop all the service discoveries.
  void stopAllServiceDiscoveries() async {
    for (BonsoirDiscovery discovery in _discoveries.values) {
      await discovery.stop();
    }

    _discoveries.clear();
    _services.clear();
    notifyListeners();
  }

  /// Dispose the model.
  @override
  void dispose() {
    stopAllServiceDiscoveries();
    super.dispose();
  }
}
