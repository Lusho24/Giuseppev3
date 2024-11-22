import 'package:flutter/material.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';

class DispatchOrderTab extends StatefulWidget {
  const DispatchOrderTab({super.key});

  @override
  State<DispatchOrderTab> createState() => _DispatchOrderTabState();
}

class _DispatchOrderTabState extends State<DispatchOrderTab> {
  // Simulamos una lista de ordenes
  final List<Map<String, String>> _orders = [
    {
      "name": "Nombrssssssssssssssssssssssssssssssssssssssssssssssse",
      "abiable": "999",
      'image': 'assets/images/lampara.png'
    },
    {"name": "Objeto 1", "abiable": "99", 'image': 'assets/images/mesa.png'},
    {"name": "Objeto 2", "abiable": "99", 'image': 'assets/images/mesa.png'},
    {"name": "Silla", "abiable": "20", 'image': 'assets/images/silla.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Parte fija
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
              "ORDEN DE DESPACHO",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          // Contenido desplazable
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 2.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1.5),
                          ),
                        ),
                        child: OrderCard(order: _orders[index]),
                      );
                    },
                    childCount: _orders.length,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      padding: const EdgeInsets.only(
                          top: 50.0, left: 120.0, right: 120.0, bottom: 20.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Siguiente"),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, String> order;
  const OrderCard({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              order['image']!,
              height: 100.0,
              width: 100.0,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 5.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['name']!,
                    style: const TextStyle(
                      color: AppColors.primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis, // Evitar desbordamiento
                  ),
                  Text(
                    "Disponible: ${order['abiable']!}",
                    style: const TextStyle(
                      color: AppColors.primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      const Expanded(
                        child: NumberInput(),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(50, 30),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          textStyle: TextStyle(fontSize: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text("Eliminar"),
                      ),

                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NumberInput extends StatefulWidget {
  const NumberInput({super.key});

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  TextEditingController _controller = TextEditingController();
  int _currentValue = 0;

  void _increment() {
    setState(() {
      _currentValue++;
      _controller.text = _currentValue.toString();
    });
  }

  void _decrement() {
    setState(() {
      _currentValue--;
      _controller.text = _currentValue.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: IconButton(
            icon: Icon(Icons.remove),
            iconSize: 15,
            color: AppColors.primaryColor,
            padding: EdgeInsets.all(0),
            onPressed: _decrement,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: Container(
            height: 30.0,
            child: TextField(
              enabled: true,
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '',
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              onChanged: (text) {
                setState(() {
                  _currentValue = int.tryParse(text) ?? 0;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: IconButton(
            icon: Icon(Icons.add),
            iconSize: 15,
            color: AppColors.primaryColor,
            padding: EdgeInsets.all(0),
            onPressed: _increment,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
      ],
    );
  }
}
