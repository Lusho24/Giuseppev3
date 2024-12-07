import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/tabs/orders/order_history_admin_view_model.dart';
import 'package:provider/provider.dart';

class OrderHistoryAdminTab extends StatefulWidget {
  const OrderHistoryAdminTab({super.key});

  @override
  State<OrderHistoryAdminTab> createState() => _OrderHistoryAdminTabState();
}

class _OrderHistoryAdminTabState extends State<OrderHistoryAdminTab> {
  late OrderHistoryAdminViewModel _viewModel;
  Order? selectedOrder;

  Future<void> _showConfirmationDialog(Order selectedOrder) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: const Text("¿Estás seguro de que deseas regresar al inventario?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _viewModel.checkOrder(selectedOrder); // Llama a checkOrder con la orden seleccionada
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Orden seleccionada: ${selectedOrder.detail}")),
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
  void initState() {
    super.initState();
    _viewModel = OrderHistoryAdminViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: OrderTable(
                    viewModel: _viewModel,
                    onSelectOrder: (Order order) {
                      setState(() {
                        selectedOrder = order;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(selectedOrder!);
                    },
                    child: const Text("Regresar al inventario"))
              ],
            ),
          ),
        )
    );
  }
}


class OrderTable extends StatefulWidget {
  final OrderHistoryAdminViewModel viewModel;
  final Function(Order) onSelectOrder;
  const OrderTable({
    required this.viewModel,
    required this.onSelectOrder,
    super.key});

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  Order? selectedOrder;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return DataTable(
      columns: const [
        DataColumn(label: Text('DETALLE')),
        DataColumn(label: Text('FECHA')),
        DataColumn(label: Text('ESTADO')),
      ],
      rows: List<DataRow>.generate(
        viewModel.orders.length,
            (index) {
          final order = viewModel.orders[index];

          return DataRow(
            cells: [
              DataCell(Center(child: Text(order.detail))),
              DataCell(Center(child: Text(order.date))),
              DataCell(
                Center(
                  child: Checkbox(
                    value: order.isChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        order.isChecked = newValue ?? false;
                        if (order.isChecked) {
                          selectedOrder = order;
                        } else {
                          if (selectedOrder == order) {
                            selectedOrder = null;
                          }
                        }
                      });
                      if (selectedOrder != null) {
                        widget.onSelectOrder(selectedOrder!);
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}