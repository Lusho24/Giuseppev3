import 'package:flutter/material.dart';
import 'package:giuseppe/models/order_dispatch_model.dart';
import 'package:giuseppe/presentation/tabs/orders_history_admin/order_history_admin_view_model.dart';

import 'package:provider/provider.dart';

class OrderHistoryAdminTab extends StatefulWidget {
  const OrderHistoryAdminTab({super.key});

  @override
  State<OrderHistoryAdminTab> createState() => _OrderHistoryAdminTabState();
}

class _OrderHistoryAdminTabState extends State<OrderHistoryAdminTab> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderHistoryAdminViewModel(),
      child: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                    child: const Image(
                      image: AssetImage('assets/images/logo.png'),
                      height: 70.0,
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      alignment: Alignment.center,
                      child: Text("HISTORIAL DE ORDENES",
                          style: Theme.of(context).textTheme.headlineSmall
                      )
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: const OrderTable(),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}


class OrderTable extends StatefulWidget {
  const OrderTable({super.key});

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<OrderHistoryAdminViewModel>(context, listen: false);
      viewModel.loadAllOrders();
    });
  }

  Future<void> _showConfirmationDialog(OrderDispatchModel selectedOrder, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: const Text("¿Estás seguro de que deseas regresar al inventario?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                final viewModel = Provider.of<OrderHistoryAdminViewModel>(context, listen: false);
                viewModel.returnQuantityToInventory(
                  order: selectedOrder,
                  showMessage: (message){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Orden seleccionada: ${selectedOrder.client}")),
                );
              },
              child: const Text("Sí"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrderHistoryAdminViewModel>(context);
    if (viewModel.isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }
    return DataTable(
      columns: const [
        DataColumn(label: Text('DETALLE'), headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('FECHA'),  headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('OPCIONES'),  headingRowAlignment: MainAxisAlignment.center),
      ],
      rows: List<DataRow>.generate(
        viewModel.ordersList.length, (index) {
          final order = viewModel.ordersList[index];

          return DataRow(
            cells: [
              DataCell(Center(child: Text(order.client,textAlign: TextAlign.center))) ,
              DataCell(Center(child: Text(order.orderDate!,textAlign: TextAlign.center))),
              DataCell(
                Center(
                  child: MenuAnchor(
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () {
                          viewModel.generatePdf(
                              context: context,
                              order: order);
                        },
                        child: const Text("Ver PDF"),
                      ),
                      MenuItemButton(
                        onPressed: () async {
                          _showConfirmationDialog(order, context);
                        },
                        child: const Text("Regresar al inventario"),
                      ),
                    ],
                    builder: (BuildContext context, MenuController controller, Widget? child) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                      );
                    },
                  )
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
