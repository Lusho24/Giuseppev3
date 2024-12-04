import 'dart:io';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/object_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class EditObjectForm extends StatefulWidget {
  final Map<String, dynamic> item;
  final ObjectService objectService;

  const EditObjectForm({
    Key? key,
    required this.item,
    required this.objectService,
  }) : super(key: key);

  @override
  State<EditObjectForm> createState() => _EditObjectFormState();
}

class _EditObjectFormState extends State<EditObjectForm> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Cabecera
              Container(
                padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                child: const Image(
                  image: AssetImage('assets/images/logo.png'),
                  height: 70.0,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22.0),
                child: Text(
                  "EDITAR ITEM",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                ),
              ),

              // Formulario deslizante
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _EditObjectFormBody(
                        item: widget.item, objectService: widget.objectService),
                  ),
                ),
              ),
            ],
          ),


          // Fondo opaco y animación de carga
          if (_isLoading)
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.only(top: 40),
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: Lottie.asset(
                    'assets/lottiefiles/loading1.json',
                    width: 250,
                    height: 250,
                    repeat: true,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

}

class _EditObjectFormBody extends StatefulWidget {
  final Map<String, dynamic> item;
  final ObjectService objectService;


  const _EditObjectFormBody({
    Key? key,
    required this.item,
    required this.objectService,
  }) : super(key: key);

  @override
  State<_EditObjectFormBody> createState() => _EditObjectFormBodyState();
}


class _EditObjectFormBodyState extends State<_EditObjectFormBody> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  List<File> _itemImg = []; //imagenes
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _detailController;

  List<String> _remoteImages = [];
  List<File> _localImages = [];
  List<String> _imagesToRemove = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
    _nameController = TextEditingController(text: widget.item['name'] ?? '');
    _quantityController = TextEditingController(text: widget.item['quantity'] ?? '');
    _detailController = TextEditingController(text: widget.item['detail'] ?? '');
    _remoteImages = List<String>.from(widget.item['image'] ?? []);
    _selectedCategory = widget.item['category'];
  }

  List<String> _categories = [
    'Accesorios', //ia
    'Auxiliares',
    'Bases', //ia
    'Candelabros', //ia
    'Electrodomésticos',
    'Herramientas',
    'Lamparas', //ia
    'Mobiliario', //ia
    'Vajilla', //ia
    'Otros',
  ];


  Future getImages() async {
    // Limitar a 4 imágenes
    if (_itemImg.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 4 imágenes.')),
      );
      return;
    }
    // Seleccionar las imágenes
    final List<XFile>? tempImgs = await picker.pickMultiImage();
    if (tempImgs != null) {
      setState(() {
        for (var img in tempImgs) {
          if (_itemImg.length < 4) {
            _itemImg.add(File(img.path));
          }
        }
      });
    }
  }

  void _removeImage(int index, bool isRemote) {
    setState(() {
      if (isRemote) {
        _imagesToRemove.add(_remoteImages[index]);
        _remoteImages.removeAt(index);
      } else {
        _localImages.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(
            color: Colors.blueGrey, // Cambia al color deseado
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carrusel de imágenes
                Center(
                  child: (_remoteImages.isEmpty && _localImages.isEmpty)
                      ? const Text("Seleccione Imágenes")
                      : CarouselSlider(
                    options: CarouselOptions(
                      height: 120.0,
                      enlargeCenterPage: true,
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      aspectRatio: 1.0,
                      viewportFraction: 0.4,
                    ),
                    items: [
                      ..._remoteImages.asMap().entries.map((entry) {
                        int index = entry.key;
                        String url = entry.value;
                        return Builder(
                          builder: (BuildContext context) {
                            return Stack(
                              children: [
                                Image.network(
                                  url,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.error,
                                      size: 120,
                                      color: Colors.red,
                                    );
                                  },
                                ),
                                Positioned(
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _removeImage(index, true),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }).toList(),
                      ..._localImages.asMap().entries.map((entry) {
                        int index = entry.key;
                        File file = entry.value;
                        return Builder(
                          builder: (BuildContext context) {
                            return Stack(
                              children: [
                                Image.file(
                                  file,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _removeImage(index, false),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                Center(
                  child: SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: getImages,
                      child: const Text("Añadir Imágenes"),
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                // Campos de texto
                Text('Nombre', style: Theme.of(context).textTheme.bodyMedium),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: 'Ingrese nombre del item',
                  ),
                  validator: (value) =>
                  value?.isEmpty == true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 15.0),
                Text('Cantidad', style: Theme.of(context).textTheme.bodyMedium),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: 'Ingrese la cantidad en stock',
                  ),
                  validator: (value) =>
                  value?.isEmpty == true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 15.0),
                Text('Detalle', style: Theme.of(context).textTheme.bodyMedium),
                TextFormField(
                  controller: _detailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: 'Ingrese detalles del item',
                  ),
                ),
                const SizedBox(height: 15.0),
                Text('Categoría', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6.0),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.blueGrey,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.blueGrey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  hint: const Text('Seleccione una categoría'),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Seleccione una categoría' : null,
                ),
                const SizedBox(height: 30.0),
                Center(
                  child: SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          // Lógica para guardar
                        }
                      },
                      child: const Text("Guardar Cambios"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
