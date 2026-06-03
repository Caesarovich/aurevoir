import 'dart:math';

import 'package:collection/collection.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

/// This provider is used to discover the available service types.
/// It also listens to the settings provider to get the user-defined service types.
class ServiceTypeProvider extends ChangeNotifier {
  /// Internal, the user-defined service types.
  Set<String> _userDefinedServiceTypes = {};

  /// Internal, the active BonsoirDiscovery instance.
  BonsoirDiscovery? _serviceTypeDiscovery;

  /// Internal, the available service types.
  final Set<String> _serviceTypes = {};

  /// The available service types.
  UnmodifiableSetView<String> get serviceTypes => UnmodifiableSetView({..._serviceTypes, ..._userDefinedServiceTypes});

  /// This is called when the user settings change.
  void updateUserDefinedServiceTypes(List<String> serviceTypes) {
    // This is to prevent notifying the listeners if the service types are the same.
    if (SetEquality().equals(_userDefinedServiceTypes, serviceTypes.toSet())) return;

    _userDefinedServiceTypes = serviceTypes.toSet();
    notifyListeners();
  }

  // This is needed because the wildcard service discovery returns the service in a different format.
  String _convertServiceType(BonsoirService service) {
    print('Converting service type: $service');
    return '${service.name}.${service.type.split('.').last}';
  }

  /// Start the service type discovery.
  void startServiceTypeDiscovery() async {
    if (_serviceTypeDiscovery != null) {
      return;
    }

    print('🔦 Initializing service discovery');

    _serviceTypeDiscovery = BonsoirDiscovery(type: '_services._dns-sd._udp');
    await _serviceTypeDiscovery!.initialize();
    print('🔦 Service discovery initialized !');

    _serviceTypeDiscovery!.eventStream!.listen((event) {
      print('🔦 Service type discovery event: $event');

      if (event is BonsoirDiscoveryStartedEvent) {
        print('🔦 Service type discovery started');
      } else if (event is BonsoirDiscoveryStoppedEvent) {
        print('🔦 Service type discovery stopped');
      } else if (event is BonsoirDiscoveryServiceFoundEvent) {
        print('🔦 Service type found: ${event.service}');
        String serviceType = _convertServiceType(event.service);
        _serviceTypes.add(serviceType);
      } else if (event is BonsoirDiscoveryServiceLostEvent) {
        print('🔦 Service type lost: ${event.service}');
        String serviceType = _convertServiceType(event.service);
        _serviceTypes.remove(serviceType);
      } else if (event is BonsoirDiscoveryServiceUpdatedEvent) {
        print('🔦 Service type updated: ${event.service}');
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        print('🔦 Service type resolved: ${event.service}');
      } else if (event is BonsoirDiscoveryServiceResolveFailedEvent) {
        print('🔦 Service type resolve failed: ${event.service}');
      } else if (event is BonsoirDiscoveryUnknownEvent) {
        print('🔦 Service type discovery unknown event: $event');
      } else {
        print('🔦 Service type discovery unhandled event: $event');
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
  bool _shouldResolveServices = false;

  /// Internal, the active BonsoirDiscovery instances.
  final Map<String, BonsoirDiscovery> _discoveries = {};

  /// Internal, the available services.
  final List<BonsoirService> _services = [];

  /// Internal, the resolved services.
  final List<BonsoirService> _resolvedServices = [];

  /// The available services.
  UnmodifiableListView<BonsoirService> get services => UnmodifiableListView(_services);

  /// The resolved services.
  UnmodifiableListView<BonsoirService> get resolvedServices => UnmodifiableListView(_resolvedServices);

  void updateServiceTypes(Set<String> serviceTypes) {
    print('🔦 Updating service types: $serviceTypes');
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

  void setShouldResolveServices(bool resolveServices) {
    if (_shouldResolveServices == resolveServices) return;

    _shouldResolveServices = resolveServices;

    print('🔍 Resolve services: $resolveServices');

    if (_shouldResolveServices) {
      for (BonsoirService service in _services) {
        service.resolve(_discoveries[service.type]!.serviceResolver);
      }
    } else {
      _resolvedServices.clear();
    }

    notifyListeners();
  }

  /// Start the service discovery for the given type.
  void startServiceDiscovery(String type) async {
    if (_discoveries.containsKey(type)) {
      return;
    }

    print("🔍 Initializing service discovery for type: $type");

    BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
    await discovery.initialize();

    print("🔍 Service discovery for type $type initialized !");

    discovery.eventStream!.listen((event) {
      if (event is BonsoirDiscoveryStartedEvent) {
        print('🔍 Service discovery for type $type started');
      } else if (event is BonsoirDiscoveryStoppedEvent) {
        print('🔍 Service discovery for type $type stopped');
      } else if (event is BonsoirDiscoveryServiceFoundEvent) {
        _onServiceFound(event.service);
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        _onServiceResolved(event.service);
      } else if (event is BonsoirDiscoveryServiceLostEvent) {
        _onServiceLost(event.service);
      } else if (event is BonsoirDiscoveryServiceResolveFailedEvent) {
        _onServiceResolvedError(event.service);
      } else if (event is BonsoirDiscoveryUnknownEvent) {
        print('🔍 Service discovery for type $type unknown event: $event');
      } else {
        print('🔍 Service discovery for type $type unhandled event: $event');
      }
    });

    _discoveries[type] = discovery;
    discovery.start();
    print("🔍 Service discovery for type $type started !");
  }

  void _onServiceFound(BonsoirService service) {
    print('🔍 Service Found $service');
    _services.add(service);
    notifyListeners();

    if (_shouldResolveServices) service.resolve(_discoveries[service.type]!.serviceResolver);
  }

  void _onServiceResolved(BonsoirService service) {
    print('🔍 Service resolved : ${service.toJson()}');
    _resolvedServices.add(service);
    // _services.remove(service); TODO
    notifyListeners();
  }

  void _onServiceLost(BonsoirService service) {
    print('🔍 Service lost : ${service.toJson()}');
    _services.remove(service);
    _resolvedServices.removeWhere((resolvedService) => resolvedService.name == service.name);
    notifyListeners();
  }

  void _onServiceResolvedError(BonsoirService? service) {
    print('🔍 Service resolved error : ${service?.toJson()}');
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
