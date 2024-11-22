import 'package:flutter/material.dart';

class OrdersTab extends StatefulWidget {
  final bool isAdmin;
  const OrdersTab({
    required this.isAdmin,
    super.key
  });

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
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
                    height: 75.0,
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
                  child: (!widget.isAdmin) ?
                  const OrderUserTable()
                      :
                  const OrderAdminTable()
                )
              ],
            ),
          ),
        )
    );
  }
}


// Para el usuario
class OrderUserTable extends StatelessWidget {
  const OrderUserTable({super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('DETALLE')),
        DataColumn(label: Text('FECHA')),
      ],
      rows: const [
        DataRow(cells: [
          DataCell(Center(child: Text('Nombre cliente'))),
          DataCell(Center(child: Text('DD/MM/YYYY'))),
        ]),
        DataRow(cells: [
          DataCell(Center(child: Text('Orden 2'))),
          DataCell(Center(child: Text('21/11/24'))),
        ]),
        DataRow(cells: [
          DataCell(Center(child: Text('orden3'))),
          DataCell(Center(child: Text('19/11/24'))),
        ]),
      ],
    );
  }
}


//Para el admin
class OrderAdminTable extends StatefulWidget {
  const OrderAdminTable({super.key});

  @override
  State<OrderAdminTable> createState() => _OrderAdminTableState();
}

class _OrderAdminTableState extends State<OrderAdminTable> {
  List<bool> _checkboxValues = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('DETALLE')),
        DataColumn(label: Text('FECHA')),
        DataColumn(label: Text('ESTADO')),
      ],
      rows: List<DataRow>.generate(
        _checkboxValues.length,
            (index) => DataRow(
          cells: [
            DataCell(Center(child: Text('Orden ${index + 1}'))),
            DataCell(Center(child: Text('21/11/24'))),
            DataCell(
              Center(
                child: Checkbox(
                  value: _checkboxValues[index],
                  onChanged: (bool? newValue) {
                    setState(() {
                      _checkboxValues[index] = newValue ?? false;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



