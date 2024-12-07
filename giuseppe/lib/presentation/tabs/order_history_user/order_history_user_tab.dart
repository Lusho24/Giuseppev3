import 'package:flutter/material.dart';

class OrderHistoryUserTab extends StatelessWidget {
  const OrderHistoryUserTab({super.key});

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
                    child: const OrderTable()
                )
              ],
            ),
          ),
        )
    );
  }
}

class OrderTable extends StatelessWidget {
  const OrderTable({super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Center(child: Text('DETALLE'))),
        DataColumn(label: Center(child: Text('FECHA'))),
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