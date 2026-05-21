import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_config.dart';
import '../services/config_service.dart';
import '../services/items_bootstrap_service.dart';

final configServiceProvider = Provider<ConfigService>((Ref ref) {
  return ConfigService();
});

final itemsBootstrapServiceProvider =
    Provider<ItemsBootstrapService>((Ref ref) {
  return ItemsBootstrapService();
});

final appConfigProvider = StreamProvider<AppConfig>((Ref ref) {
  return ref.watch(configServiceProvider).watch();
});
