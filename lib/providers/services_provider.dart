import 'package:collection/collection.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

import 'package:aurevoir/app_logger.dart';

final _logger = getLogger('ServiceProvider');

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
  UnmodifiableSetView<String> get serviceTypes =>
      UnmodifiableSetView({..._serviceTypes, ..._userDefinedServiceTypes});

  /// This is called when the user settings change.
  void updateUserDefinedServiceTypes(List<String> serviceTypes) {
    // This is to prevent notifying the listeners if the service types are the same.
    if (SetEquality().equals(_userDefinedServiceTypes, serviceTypes.toSet()))
      return;

    _userDefinedServiceTypes = serviceTypes.toSet();
    notifyListeners();
  }

  static const _protocolTypes = ['_tcp', '_udp'];

  // This is needed because the wildcard service discovery returns the service in a different format.
  Set<String> _convertServiceType(BonsoirService service) {
    String type = service.name;

    // If the service type does not end with a protocol, we add both protocols.
    return _protocolTypes.map((protocol) => '$type.$protocol').toSet();
  }

  /// Start the service type discovery.
  void startServiceTypeDiscovery() async {
    if (_serviceTypeDiscovery != null) {
      return;
    }

    _logger.d('🔦 Initializing service discovery');

    _serviceTypeDiscovery = BonsoirDiscovery(type: '_services._dns-sd._udp');
    await _serviceTypeDiscovery!.initialize();
    _logger.i('🔦 Service discovery initialized !');

    _serviceTypeDiscovery!.eventStream!.listen((event) {
      _logger.d('🔦 Service type discovery event: $event');

      if (event is BonsoirDiscoveryStartedEvent) {
        _logger.i('🔦 Service type discovery started');
      } else if (event is BonsoirDiscoveryStoppedEvent) {
        _logger.i('🔦 Service type discovery stopped');
      } else if (event is BonsoirDiscoveryServiceFoundEvent) {
        _logger.i('🔦 Service type found: ${event.service}');
        Set<String> serviceTypes = _convertServiceType(event.service);
        _serviceTypes.addAll(serviceTypes);
      } else if (event is BonsoirDiscoveryServiceLostEvent) {
        _logger.i('🔦 Service type lost: ${event.service}');
        Set<String> serviceTypes = _convertServiceType(event.service);
        _serviceTypes.removeAll(serviceTypes);
      } else if (event is BonsoirDiscoveryServiceUpdatedEvent) {
        _logger.i('🔦 Service type updated: ${event.service}');
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        _logger.i('🔦 Service type resolved: ${event.service}');
      } else if (event is BonsoirDiscoveryServiceResolveFailedEvent) {
        _logger.w('🔦 Service type resolve failed: ${event.service}');
      } else if (event is BonsoirDiscoveryUnknownEvent) {
        _logger.e('🔦 Service type discovery unknown event: $event');
      } else {
        _logger.f('🔦 Service type discovery unhandled event: $event');
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
  UnmodifiableListView<BonsoirService> get services =>
      UnmodifiableListView(_services);

  /// The resolved services.
  UnmodifiableListView<BonsoirService> get resolvedServices =>
      UnmodifiableListView(_resolvedServices);

  void updateServiceTypes(Set<String> serviceTypes) {
    _logger.d('🔦 Updating service types: $serviceTypes');
    for (String type in serviceTypes) {
      try {
        startServiceDiscovery(type);
      } catch (e) {
        _logger.e('Error starting service discovery for $type: $e');
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

    _logger.d('🔍 Resolve services: $resolveServices');

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

    _logger.d("🔍 Initializing service discovery for type: $type");

    BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
    await discovery.initialize();

    _logger.i("🔍 Service discovery for type $type initialized !");

    discovery.eventStream!.listen((event) {
      if (event is BonsoirDiscoveryStartedEvent) {
        _logger.i('🔍 Service discovery for type $type started');
      } else if (event is BonsoirDiscoveryStoppedEvent) {
        _logger.i('🔍 Service discovery for type $type stopped');
      } else if (event is BonsoirDiscoveryServiceFoundEvent) {
        _onServiceFound(event.service);
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        _onServiceResolved(event.service);
      } else if (event is BonsoirDiscoveryServiceUpdatedEvent) {
        _onServiceUpdated(event.service);
      } else if (event is BonsoirDiscoveryServiceLostEvent) {
        _onServiceLost(event.service);
      } else if (event is BonsoirDiscoveryServiceResolveFailedEvent) {
        _onServiceResolvedError(event.service);
      } else if (event is BonsoirDiscoveryUnknownEvent) {
        _logger.e('🔍 Service discovery for type $type unknown event: $event');
      } else {
        _logger
            .f('🔍 Service discovery for type $type unhandled event: $event');
      }
    });

    _discoveries[type] = discovery;
    discovery.start();
    _logger.i("🔍 Service discovery for type $type started !");
  }

  void _onServiceFound(BonsoirService service) {
    _logger.i('🔍 Service Found $service');
    _services.add(service);
    notifyListeners();

    if (_shouldResolveServices) {
      service.resolve(_discoveries[service.type]!.serviceResolver);
    }
  }

  void _onServiceResolved(BonsoirService service) {
    _logger.i('🔍 Service resolved : ${service.toJson()}');
    _resolvedServices.add(service);
    // _services.remove(service); TODO
    notifyListeners();
  }

  void _onServiceLost(BonsoirService service) {
    _logger.i('🔍 Service lost : ${service.toJson()}');
    _services.remove(service);
    _resolvedServices
        .removeWhere((resolvedService) => resolvedService.name == service.name);
    notifyListeners();
  }

  void _onServiceUpdated(BonsoirService service) {
    _logger.i('🔍 Service updated : ${service.toJson()}');
    int index = _services.indexWhere((s) => s.name == service.name);
    if (index != -1) {
      _services[index] = service;
      notifyListeners();
    }
  }

  void _onServiceResolvedError(BonsoirService? service) {
    _logger.e('🔍 Service resolved error : ${service?.toJson()}');
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
