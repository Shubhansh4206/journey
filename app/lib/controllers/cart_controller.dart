import 'package:get/get.dart';
import '../data/mock_city_catalog.dart';

class CartController extends GetxController {
  // Reactive cart state
  final Rxn<CityCatalog> activeCity = Rxn<CityCatalog>();
  final RxSet<String> selectedItemIds = <String>{}.obs;
  final RxDouble budget = 15000.0.obs;
  final Rx<DateTime> startDate =
      DateTime.now().add(const Duration(days: 21)).obs;
  final Rx<DateTime> endDate =
      DateTime.now().add(const Duration(days: 25)).obs;

  int get itemCount => selectedItemIds.length;
  bool get hasActiveCart => activeCity.value != null || selectedItemIds.isNotEmpty;

  // Progress tracking: 0.0 to 1.0 (Swiggy / Unstop style progress)
  double get progressPercentage {
    if (activeCity.value == null) return 0.0;
    int score = 1; // 1: Destination selected
    if (selectedItemIds.isNotEmpty) score++; // 2: Activities/Hotels picked
    if (selectedItemIds.length >= 3) score++; // 3: Well rounded package
    if (budget.value > 0) score++; // 4: Ready for quote
    return (score / 4.0).clamp(0.0, 1.0);
  }

  String get progressStatusText {
    if (activeCity.value == null) return 'Start Planning';
    if (selectedItemIds.isEmpty) return 'Select Stays & Spots';
    if (selectedItemIds.length < 3) return '${selectedItemIds.length} Picked • Add More';
    return 'Ready to Book (${selectedItemIds.length} items)';
  }

  void setCity(CityCatalog city) {
    if (activeCity.value?.id != city.id) {
      activeCity.value = city;
    }
  }

  void toggleItem(String id) {
    if (selectedItemIds.contains(id)) {
      selectedItemIds.remove(id);
    } else {
      selectedItemIds.add(id);
    }
  }

  void syncItems(Set<String> ids) {
    selectedItemIds.assignAll(ids);
  }

  void clearCart() {
    selectedItemIds.clear();
    activeCity.value = null;
  }
}
