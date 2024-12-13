import 'package:flutter/material.dart';
import 'package:giuseppe/models/order_dispatch_model.dart';
import 'package:giuseppe/models/order_item_model.dart';
import 'package:giuseppe/presentation/common_widgets/custom_text_form_field.dart';
import 'package:giuseppe/presentation/tabs/dispatch_order/dispatch_order_view_model.dart';
import 'package:giuseppe/presentation/tabs/dispatch_order/order_pdf/order_pdf.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/cart_service.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/object_service.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';
import 'package:provider/provider.dart';

class DispatchOrderTab extends StatefulWidget {
  const DispatchOrderTab({super.key});

  @override
  State<DispatchOrderTab> createState() => _DispatchOrderTabState();
}

class _DispatchOrderTabState extends State<DispatchOrderTab> {
  final CartService _cartService = CartService();
  final ObjectService _objectService = ObjectService();
  late DispatchOrderViewModel _viewModel;

  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;


  Future<void> _loadCartItems() async {
    try {
      final cartItems = await _cartService.fetchCartItems();
      final objects = await _objectService.getAllItems();

      _cartItems = cartItems.map((cartItem) {
        final object = objects.firstWhere(
              (obj) => obj['id'] == cartItem['itemId'],
          orElse: () => {},
        );
        return {
          ...object,
          'quantityOrder': cartItem['quantityOrder'],
          'observations': cartItem['observations'],
          'quantity': object['quantity'],
        };
      }).toList();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateCartItemObservations(String itemId, String observations) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        _cartItems[index]['observations'] = observations;
      }
    });
  }

  void _updateCartItemQuantity(String itemId, int quantity) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        _cartItems[index]['quantityOrder'] = quantity;
      }
    });
  }



  Future<void> _removeCartItem(String itemId) async {
    try {
      await _cartService.removeItemFromCart(itemId);
      await _loadCartItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ítem eliminado del carrito")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar el ítem: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    _viewModel = DispatchOrderViewModel();
    _loadCartItems();
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DispatchOrderViewModel>.value(
      value: _viewModel,
      child: Scaffold(
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
      
            const SizedBox(
              height: 16.0,
            ),
            const Divider(
              color: AppColors.primaryVariantColor,
              thickness: 1.0,
              indent: 20.0,
              endIndent: 20.0,
            ),
      
            // Parte desplazable
            Expanded(
              child: Stack(
                children: [
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (_cartItems.isEmpty)
                    const Center(
                      child: Text(
                        "Aún no has agregado ningún ítem a tu orden",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryVariantColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    CustomScrollView(
                      slivers: [
                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1.95,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _cartItems[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 5.0, right: 5.0),
                                child: SizedBox(
                                  child: OrderCard(
                                    order: item,
                                    onDelete: () => _removeCartItem(item['id']),
                                    onObservationsChanged: _updateCartItemObservations, // Para observaciones
                                    onQuantityChanged: _updateCartItemQuantity,         // Para cantidades
                                  ),

                                ),
                              );
                            },
                            childCount: _cartItems.length,
                          ),
                        ),
                        if (_cartItems.isNotEmpty)
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
                                        builder: (BuildContext context) => DispatchOrderModal(
                                          cartItems: _cartItems,
                                          viewModel: _viewModel,
                                        ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onDelete;
  final Function(String, String) onObservationsChanged;
  final Function(String, int) onQuantityChanged;

  const OrderCard({
    required this.order,
    required this.onDelete,
    required this.onObservationsChanged,
    required this.onQuantityChanged,
    super.key,

  });

  @override
  Widget build(BuildContext context) {
    final int objectQuantity = order['quantity'] ?? 0;
    final int cartQuantity = order['quantityOrder'] ?? 0;

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
              child: Image.network(
                order['images']?.first ?? '',
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
                    order['name'] ?? 'Nombre desconocido',
                    style: const TextStyle(
                      color: AppColors.primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Disponible: $objectQuantity",
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
                      NumberInput(
                        initialValue: cartQuantity,
                        maxValue: objectQuantity,
                        itemId: order['id'],
                        onDelete: onDelete,
                        onQuantityChanged: onQuantityChanged,
                      ),
                      ElevatedButton(
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(50, 30),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
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
                  ObservationInput(
                    itemId: order['id'],
                    initialObservations: order['observations'] ?? '',
                    onObservationsChanged: onObservationsChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberInput extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final String itemId;
  final VoidCallback onDelete;
  final Function(String, int) onQuantityChanged;

  const NumberInput({
    super.key,
    required this.initialValue,
    required this.maxValue,
    required this.itemId,
    required this.onDelete,
    required this.onQuantityChanged,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  late TextEditingController _controller;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _currentValue.toString());
  }

  void _increment() async {
    if (_currentValue < widget.maxValue) {
      setState(() {
        _currentValue++;
        _controller.text = _currentValue.toString();
      });

      await _updateQuantity();
      widget.onQuantityChanged(widget.itemId, _currentValue);

    }
  }

  void _decrement() async {
    if (_currentValue > 0) {
      setState(() {
        _currentValue--;
        _controller.text = _currentValue.toString();
      });

      await _updateQuantity();
      widget.onQuantityChanged(widget.itemId, _currentValue);
    }
    if (_currentValue == 0) {
      widget.onDelete();
    }
  }

  // Función para actualizar cantidad
  Future<void> _updateQuantity() async {
    try {
      await CartService().updateItemQuantity(widget.itemId, _currentValue);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la cantidad: $e')),
        );
      }
    }
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
          width: 35.0,
          child: TextField(
            readOnly: true,
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 5.0),
            ),
            onChanged: (text) {
              int? value = int.tryParse(text);
              if (value != null && value <= widget.maxValue && value >= 0) {
                setState(() {
                  _currentValue = value;
                });

                _updateQuantity();
              } else {
                _controller.text = _currentValue.toString();
              }
            },
          ),
        ),
        const SizedBox(width: 10.0),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
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

class ObservationInput extends StatefulWidget {
  final String itemId;
  final String initialObservations;
  final Function(String, String) onObservationsChanged;

  const ObservationInput({
    super.key,
    required this.itemId,
    required this.initialObservations,
    required this.onObservationsChanged,
  });

  @override
  ObservationInputState createState() => ObservationInputState();
}

class ObservationInputState extends State<ObservationInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialObservations);
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateObservations(String observations) async {
    await CartService().updateItemObservations(widget.itemId, observations);
    widget.onObservationsChanged(widget.itemId, observations);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300),
      decoration: InputDecoration(
        hintText: widget.initialObservations.isEmpty ? "Observaciones:" : null,
        hintStyle: const TextStyle(fontSize: 14.0, color: Colors.grey, fontWeight: FontWeight.w300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      ),
      onChanged: _updateObservations,
    );
  }
}


// * Ventana modal
class DispatchOrderModal extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final DispatchOrderViewModel viewModel;

  const DispatchOrderModal({
    required this.cartItems,
    required this.viewModel,
    super.key
  });

  @override
  State<DispatchOrderModal> createState() => _DispatchOrderModalState();
}

class _DispatchOrderModalState extends State<DispatchOrderModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _receiveNameController = TextEditingController();
  final TextEditingController _responsibleNameController = TextEditingController();

  DateTime _eventDate = DateTime.now();

  // Método para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              surface: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _eventDate) {
      setState(() {
        _eventDate = pickedDate;
        _dateController.text = _eventDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _createDispatchOrder() async {
    try {
      late OrderDispatchModel orderDispatch;

      // Toma los datos del item y los convierte a un objeto
      List<OrderItemModel> items = widget.cartItems.map((item) {
        return OrderItemModel(
          name: item['name'],
          observations: item['observations'] ?? '',
          quantity: item['quantityOrder'],
        );
      }).toList();

      //formateo de la fecha de despacho
      String formattedDate =
          "${_eventDate.day.toString().padLeft(2, '0')}/"
          "${_eventDate.month.toString().padLeft(2, '0')}/"
          "${_eventDate.year}";

      //crea la orden de despacho
      orderDispatch = OrderDispatchModel(
          client: _clientNameController.text,
          location: _linkController.text,
          dispachDate: formattedDate,
          driverName: _driverNameController.text,
          deliveryTime: _deliveryTimeController.text,
          receiverName:  _receiveNameController.text,
          responsibleName: _responsibleNameController.text,
          items: items
      );

      widget.viewModel.saveOrderDispatch(orderDispatch);

      //reducir la cantidad del item
      await ObjectService().reduceItemQuantity(widget.cartItems);

      // Vacia el carrito
      await CartService().clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Orden creada con éxito")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderPdf(
                orderDispatch: orderDispatch,
              )
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al crear la orden: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 30, color: Colors.black),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'DATOS DE LA ORDEN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cliente',
                        style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.client_name,
                      hintText: 'Nombre del Cliente',
                      controller: _clientNameController,
                    ),
                    const SizedBox(height: 10),
                    Text('Fecha de despacho',
                        style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.dispatch_date,
                      hintText: 'yyyy-mm-dd',
                      controller: _dateController,
                      onSuffixIconPressed: () => _selectDate(context),
                    ),
                    const SizedBox(height: 10),
                    Text('Chofer',
                        style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.client_name,
                      hintText: 'Nombre del Chofer',
                      controller: _driverNameController,
                    ),
                    const SizedBox(height: 10),
                    Text('Lugar de entrega',
                        style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.url_location,
                      hintText: 'Lugar de entrega',
                      controller: _linkController,
                    ),
                    const SizedBox(height: 10),
                    Text('Hora de entrega',
                        style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.client_name,
                      hintText: 'Hora de entrega',
                      controller: _deliveryTimeController,
                    ),
                    const SizedBox(height: 10),
                    Text('Recibe',
                        style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.client_name,
                      hintText: 'Nombre de quien recibe',
                      controller: _receiveNameController,
                    ),
                    const SizedBox(height: 10),
                    Text('Responsable de despacho',
                        style: Theme.of(context).textTheme.bodyMedium),
                    CustomTextFormField(
                      formFieldType: FormFieldType.client_name,
                      hintText: 'Nombre del responsable',
                      controller: _responsibleNameController,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                    _createDispatchOrder();
/*                  if (_formKey.currentState!.validate()) {
                    String clientName = _clientNameController.text;
                    String link = _linkController.text;
                    String formattedDate =
                        "${_eventDate.day.toString().padLeft(2, '0')}/"
                        "${_eventDate.month.toString().padLeft(2, '0')}/"
                        "${_eventDate.year}";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderPdf(
                              name: clientName,
                              date: formattedDate,
                              link: link)),
                    );
                  }*/
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
