import 'package:get/get.dart';
import '../data/mock_city_catalog.dart';
import '../services/travel_mode_service.dart';

class CartController extends GetxController {
  // Reactive Group cart state
  final Rxn<CityCatalog> groupActiveCity = Rxn<CityCatalog>();
  final RxSet<String> groupSelectedItemIds = <String>{}.obs;
  final RxDouble groupBudget = 15000.0.obs;
  final Rx<DateTime> groupStartDate =
      DateTime.now().add(const Duration(days: 21)).obs;
  final Rx<DateTime> groupEndDate =
      DateTime.now().add(const Duration(days: 25)).obs;

  // Reactive Solo cart state
  final Rxn<CityCatalog> soloActiveCity = Rxn<CityCatalog>();
  final RxSet<String> soloSelectedItemIds = <String>{}.obs;
  final RxDouble soloBudget = 15000.0.obs;
  final Rx<DateTime> soloStartDate =
      DateTime.now().add(const Duration(days: 21)).obs;
  final Rx<DateTime> soloEndDate =
      DateTime.now().add(const Duration(days: 25)).obs;

  // Mode-specific State Accessors
  Rxn<CityCatalog> activeCityFor([bool? isSolo]) =>
      (isSolo ?? TravelModeService.isSolo) ? soloActiveCity : groupActiveCity;

  RxSet<String> selectedItemIdsFor([bool? isSolo]) =>
      (isSolo ?? TravelModeService.isSolo) ? soloSelectedItemIds : groupSelectedItemIds;

  RxDouble budgetFor([bool? isSolo]) =>
      (isSolo ?? TravelModeService.isSolo) ? soloBudget : groupBudget;

  Rx<DateTime> startDateFor([bool? isSolo]) =>
      (isSolo ?? TravelModeService.isSolo) ? soloStartDate : groupStartDate;

  Rx<DateTime> endDateFor([bool? isSolo]) =>
      (isSolo ?? TravelModeService.isSolo) ? soloEndDate : groupEndDate;

  // Legacy / Direct access properties (fallbacks to current active mode)
  Rxn<CityCatalog> get activeCity => activeCityFor();
  RxSet<String> get selectedItemIds => selectedItemIdsFor();
  RxDouble get budget => budgetFor();
  Rx<DateTime> get startDate => startDateFor();
  Rx<DateTime> get endDate => endDateFor();

  CityCatalog? getActiveCity({bool? isSolo}) => activeCityFor(isSolo).value;
  Set<String> getSelectedItems({bool? isSolo}) => selectedItemIdsFor(isSolo);

  int itemCountFor([bool? isSolo]) => selectedItemIdsFor(isSolo).length;
  int get itemCount => itemCountFor();

  bool hasActiveCartFor([bool? isSolo]) =>
      activeCityFor(isSolo).value != null || selectedItemIdsFor(isSolo).isNotEmpty;
  bool get hasActiveCart => hasActiveCartFor();

  // Progress tracking: 0.0 to 1.0 (Swiggy / Unstop style progress)
  double progressPercentageFor([bool? isSolo]) {
    final city = activeCityFor(isSolo).value;
    final items = selectedItemIdsFor(isSolo);
    final b = budgetFor(isSolo).value;

    if (city == null) return 0.0;
    int score = 1; // 1: Destination selected
    if (items.isNotEmpty) score++; // 2: Activities/Hotels picked
    if (items.length >= 3) score++; // 3: Well rounded package
    if (b > 0) score++; // 4: Ready for quote
    return (score / 4.0).clamp(0.0, 1.0);
  }
  double get progressPercentage => progressPercentageFor();

  String progressStatusTextFor([bool? isSolo]) {
    final city = activeCityFor(isSolo).value;
    final items = selectedItemIdsFor(isSolo);

    if (city == null) return 'Start Planning';
    if (items.isEmpty) return 'Select Stays & Spots';
    if (items.length < 3) return '${items.length} Picked • Add More';
    return 'Ready to Book (${items.length} items)';
  }
  String get progressStatusText => progressStatusTextFor();

  void setCity(CityCatalog city, {bool? isSolo}) {
    final target = activeCityFor(isSolo);
    if (target.value?.id != city.id) {
      target.value = city;
    }
  }

  void toggleItem(String id, {bool? isSolo}) {
    final set = selectedItemIdsFor(isSolo);
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
  }

  void syncItems(Set<String> ids, {bool? isSolo}) {
    selectedItemIdsFor(isSolo).assignAll(ids);
  }

  void clearCart({bool? isSolo}) {
    selectedItemIdsFor(isSolo).clear();
    activeCityFor(isSolo).value = null;
  }
}
