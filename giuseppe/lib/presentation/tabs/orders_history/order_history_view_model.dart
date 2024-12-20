import 'package:flutter/material.dart';
import 'package:giuseppe/models/order_dispatch_model.dart';
import 'package:giuseppe/models/order_item_model.dart';
import 'package:giuseppe/presentation/tabs/dispatch_order/order_pdf/order_pdf.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/object_service.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/order_dispatch_service.dart';
import 'package:giuseppe/services/local_storage/session_in_local_storage_service.dart';

class OrderHistoryViewModel extends ChangeNotifier{
  final OrderDispatchService _orderDispatchService = OrderDispatchService();
  final ObjectService _objectService = ObjectService();
  final List<OrderDispatchModel> _ordersList = [];
  final SessionInLocalStorageService _localStorage = SessionInLocalStorageService();
  bool _isLoadingOrders = false;

  Future<void> loadAllOrders() async {
    _ordersList.clear();
    _isLoadingOrders = true;
    notifyListeners();

    List<OrderDispatchModel> ordersData = await _orderDispatchService.findEnableOrdersDispatch();
    _ordersList.addAll(ordersData);

    _isLoadingOrders = false;
    notifyListeners();
  }



  Future<Map<String, dynamic>?> fetchSessionInLocalStorage() async {
    try{
      final Map<String, dynamic>? sessionData= await _localStorage.fetchSession();
      if (sessionData != null) {
        return sessionData;
      }
    } catch(e) {
      return null;
    }
    return null;
  }


  void generatePdf({required BuildContext context, required OrderDispatchModel order}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OrderPdf(
            orderDispatch: order,
          )
      ),
    );
  }

  Future<void> returnQuantityToInventory({required OrderDispatchModel order, required Function(String) showMessage}) async {
    List<OrderItemModel> items = order.items;
    bool response = await _objectService.addItemsQuantity(items);
    if(response) {
      bool updateResponse = await _orderDispatchService.updateAvailableOrderDispatch(order.client);
      if(updateResponse){
        await loadAllOrders();
        showMessage("Los items han sido devueltos al inventario exitosamente.");
      }
      showMessage("Algo ha salido mal al actualizar el estado de la orden.");
    } else {
      showMessage("Hubo un error al devolver los items al al inventario.");
    }
  }


  // GETTERS
  List<OrderDispatchModel> get ordersList => _ordersList;
  bool get isLoadingOrders => _isLoadingOrders;

}
