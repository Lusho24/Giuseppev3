import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/common_widgets/custom_text_form_field.dart';
import 'package:giuseppe/presentation/tabs/dispatch_order/order_pdf.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';

class DispatchOrderTab extends StatefulWidget {
  const DispatchOrderTab({super.key});

  @override
  State<DispatchOrderTab> createState() => _DispatchOrderTabState();
}

class _DispatchOrderTabState extends State<DispatchOrderTab> {
  // Simulamos una lista de ordenes
  final List<Map<String, String>> _orders = [
    {"name": "Nombre", "abiable": "999", 'image': 'assets/images/lampara.png'},
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
          // Parte desplazable
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverGrid(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 1.95,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 1.5),
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
                              top: 30.0,
                              left: 100.0,
                              right: 100.0,
                              bottom: 20.0,
                            ),
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => DispatchOrderModal(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Siguiente",
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    SizedBox(width: 20),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                      color: AppColors.primaryColor,
                                    ),
                                  ],
                                ),
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
        padding: const EdgeInsets.all(5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100.0,
              width: 100.0,
              child: Image.asset(
                order['image']!,
                fit: BoxFit.scaleDown,
              ),
            ),
            const SizedBox(width: 5.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order['name']!,
                    style: const TextStyle(
                      color: AppColors.primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 5.0),
                  Row(
                    children: [
                      const Expanded(
                        child: NumberInput(),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(50, 30),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          textStyle: const TextStyle(fontSize: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text("Eliminar"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Observaciones:",
                      hintStyle: const TextStyle(
                        fontSize: 13.0,
                        color: AppColors.hintTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                    ),
                  ),
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
            icon: const Icon(Icons.remove),
            iconSize: 15,
            color: AppColors.primaryColor,
            onPressed: _decrement,
          ),
        ),
        const SizedBox(width: 10.0),

        SizedBox(
          height: 30.0,
          width: 30.0,
          child: TextField(
            enabled: true,
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14.0),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '',
              contentPadding: EdgeInsets.symmetric(vertical: 5.0),
            ),
            onChanged: (text) {
              setState(() {
                _currentValue = int.tryParse(text) ?? 0;
              });
            },
          ),
        ),


        const SizedBox(width: 10.0),

        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: IconButton(
            icon: const Icon(Icons.add),
            iconSize: 15,
            color: AppColors.primaryColor,
            onPressed: _increment,
          ),
        ),
        const SizedBox(width: 10.0),
      ],
    );
  }

}

// * Ventana modal
class DispatchOrderModal extends StatefulWidget {
  const DispatchOrderModal({super.key});

  @override
  State<DispatchOrderModal> createState() => _DispatchOrderModalState();
}

class _DispatchOrderModalState extends State<DispatchOrderModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _eventDate = DateTime.now();

  // Método para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _eventDate) {
      setState(() {
        _eventDate = pickedDate;
        _dateController.text = _eventDate.toLocal().toString().split(' ')[0];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.info_outline,size: 16.0),
                  const SizedBox(width: 10.0),
                  const Expanded(
                    child: Text("DATOS DE ORDEN DE DESPACHO",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close)
                  )
                ],
              ), 
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CLIENTE', style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.client_name,
                      hintText: 'Nombre del Cliente',
                      controller: _clientNameController,
                    ),
                    const SizedBox(height: 10),

                    Text('FECHA DE BODA', style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.event_date,
                      hintText: 'dd/mm/yy',
                      controller: _dateController,
                      onSuffixIconPressed: () => _selectDate(context),
                    ),
                    const SizedBox(height: 10),

                    Text('UBICACIÓN', style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.url_location,
                      hintText: 'Link',
                      controller: _linkController,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String clientName = _clientNameController.text;
                    String link = _linkController.text;
                    String formattedDate = "${_eventDate.day.toString().padLeft(2, '0')}/"
                        "${_eventDate.month.toString().padLeft(2, '0')}/"
                        "${_eventDate.year}";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderPdf(
                              name: clientName,
                              date: formattedDate,
                              link: link)
                      ),
                    );
                  }

                },
                child: const Text("Crear Orden"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
