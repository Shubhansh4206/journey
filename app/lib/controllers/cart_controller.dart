import 'package:get/get.dart';
import '../data/mock_city_catalog.dart';

class CartController extends GetxController {
  static CartController get to => Get.find<CartController>();

  // Reactive state
  final Rxn<CityCatalog> activeCity = Rxn<CityCatalog>();
  final RxSet<String> selectedItemIds = <String>{}.obs;
  final RxInt estimatedBudget = 15000.obs;
  final Rx<DateTime> startDate = DateTime.now().add(const Duration(days: 21)).obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 25)).obs;
  final RxBool isSolo = false.obs;

  // Total items in cart
  int get totalItemsCount => selectedItemIds.length;
  bool get hasActiveCart => activeCity.value != null || selectedItemIds.isNotEmpty;

  String get formattedBudget {
    final b = estimatedBudget.value;
    if (b >= 100000) {
      return '₹${(b / 100000).toStringAsFixed(1)}L';
    } else if (b >= 1000) {
      return '₹${(b / 1000).toStringAsFixed(0)}k';
    }
    return '₹$b';
  }

  void setCity(CityCatalog city) {
    if (activeCity.value?.id != city.id) {
      Future.microtask(() {
        activeCity.value = city;
      });
    }
  }

  void toggleItem(String id) {
    if (selectedItemIds.contains(id)) {
      selectedItemIds.remove(id);
    } else {
      selectedItemIds.add(id);
    }
  }

  void setItems(Set<String> ids) {
    Future.microtask(() {
      selectedItemIds.assignAll(ids);
    });
  }

  void updateDates(DateTime start, DateTime end) {
    Future.microtask(() {
      startDate.value = start;
      endDate.value = end;
    });
  }

  void updateBudget(int budget) {
    Future.microtask(() {
      estimatedBudget.value = budget;
    });
  }

  void clearCart() {
    Future.microtask(() {
      selectedItemIds.clear();
      activeCity.value = null;
    });
  }
}
