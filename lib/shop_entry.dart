// typedef JsonObject = Map<String, dynamic>;

import 'package:bbc_client/tcp/packets.dart';

sealed class ShopEntry {
  ShopEntry({
    required this.name,
    required this.target,
    required this.description,
  });

  final String name;
  final String target;
  final String description;
}

class SingleEntry extends ShopEntry {
  SingleEntry({
    required super.name,
    required super.target,
    required super.description,
    required this.price,
    this.bought = false,
  });

  final int price;
  bool bought;
}

class TieredEntry extends ShopEntry {
  TieredEntry({
    required super.name,
    required super.target,
    required super.description,
    required this.tiers,
    this.currentLevel = 0,
  });

  final List<UpgradeTier> tiers;
  int currentLevel; // 0 when the player has none

  bool get maxed => currentLevel >= tiers.length;
  UpgradeTier? get nextTier => maxed ? null : tiers[currentLevel];
}

class UpgradeTier {
  UpgradeTier({
    required this.name,
    required this.description,
    required this.price,
  });

  final String name;
  final String description;
  final int price;
}

List<ShopEntry> parseShopEntries(List<JsonObject> raw) {
  return raw.map<ShopEntry>((e) {
    switch (e['type']) {
      case 'single':
        return SingleEntry(
          name: e['name'],
          target: e['target'],
          description: e['description'] ?? '',
          price: e['price'],
        );
      case 'tiered':
        final tiers = (e['tiers'] as List)
            .map((t) => UpgradeTier(
                  name: t['name'] ?? '',
                  description: t['description'] ?? '',
                  price: t['price'],
                ))
            .toList();

        return TieredEntry(
          name: e['name'],
          target: e['target'],
          description: e['description'] ?? '',
          tiers: tiers,
        );
      default:
        throw ArgumentError('Unknown shop entry type ${e['type']}');
    }
  }).toList();
}
