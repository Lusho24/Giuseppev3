import 'package:flutter/material.dart';
import 'package:giuseppe/models/order_dispatch_model.dart';
import 'package:giuseppe/presentation/tabs/orders_history/order_history_view_model.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';

import 'package:provider/provider.dart';

class OrderHistoryTab extends StatefulWidget {
  const OrderHistoryTab({super.key});

  @override
  State<OrderHistoryTab> createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends State<OrderHistoryTab> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderHistoryViewModel(),
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
                  padding: const EdgeInsets.symmetric(vertical: 22.0),
                  alignment: Alignment.center,
                  child: const Text(
                    "HISTORIAL DE ORDENES",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                    ),
                  )),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: const OrderTable(),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class OrderTable extends StatefulWidget {
  const OrderTable({super.key});

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  late final bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel =
          Provider.of<OrderHistoryViewModel>(context, listen: false);
      Map<String, dynamic>? sessionData =
          await viewModel.fetchSessionInLocalStorage();
      setState(() {
        _isAdmin = sessionData!['isAdmin'];
      });
      viewModel.loadAllOrders();
    });
  }

  Future<void> _showConfirmationDialog(
      OrderDispatchModel selectedOrder, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          backgroundColor: AppColors.primaryColor,
          title: const Center(
            child: Text(
              'Confirmar',
              style: TextStyle(color: AppColors.onPrimaryColor),
            ),
          ),
          content: const Text(
            '¿Proceso de orden completo, desea devolver los items al inventario?',
            textAlign: TextAlign.justify,
            style: TextStyle(color: AppColors.onPrimaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                foregroundColor: AppColors.onPrimaryColor,
              ),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                final viewModel = Provider.of<OrderHistoryViewModel>(context, listen: false);
                viewModel.returnQuantityToInventory(
                    order: selectedOrder,
                    showMessage: (message) {
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
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                backgroundColor: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrderHistoryViewModel>(context);
    if (viewModel.isLoadingOrders && _isAdmin == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return DataTable(
      columns: const [
        DataColumn(
            label: Text(
              'DETALLE',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
            ),
            headingRowAlignment: MainAxisAlignment.center),
        DataColumn(
            label: Text(
              'FECHA',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
            ),
            headingRowAlignment: MainAxisAlignment.center),
        DataColumn(label: Text('')),
      ],
      rows: List<DataRow>.generate(
        viewModel.ordersList.length,
        (index) {
          final order = viewModel.ordersList[index];

          return DataRow(
            cells: [
              DataCell(Center(
                  child: Text(order.client, textAlign: TextAlign.center))),
              DataCell(Center(
                  child: Text(order.orderDate!, textAlign: TextAlign.center))),
              DataCell(
                Center(
                    child: _isAdmin!
                        ? MenuAnchor(
                            menuChildren: [
                              MenuItemButton(
                                onPressed: () {
                                  viewModel.generatePdf(
                                      context: context, order: order);
                                },
                                child: const Text("Ver PDF"),
                              ),
                              MenuItemButton(
                                onPressed: () async {
                                  _showConfirmationDialog(order, context);
                                },
                                child: const Text("Regresar Items"),
                              ),
                            ],
                            builder: (BuildContext context,
                                MenuController controller, Widget? child) {
                              return IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                },
                              );
                            },
                            style: MenuStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  AppColors.primaryColor),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.file_open),
                            onPressed: () {
                              viewModel.generatePdf(
                                  context: context, order: order);
                            },
                          )),
              ),
            ],
          );
        },
      ),
    );
  }
}
