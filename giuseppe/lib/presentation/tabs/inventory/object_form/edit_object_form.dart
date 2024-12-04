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
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: Lottie.asset(
                    'assets/lottiefiles/loading1.json',
                    width: 250,
                    height: 250,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
  final ImagePicker _picker = ImagePicker();

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

  final List<String> _categories = [
    'Electrónica',
    'Ropa',
    'Muebles',
    'Deportes',
    'Libros',
  ]; // Lista de categorías disponibles


  Future<void> _pickImage() async {
    if (_localImages.length + _remoteImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 4 imágenes.')),
      );
      return;
    }

    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _localImages.addAll(selectedImages.map((img) => File(img.path)));
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
      child: Form(
        key: _formKey,
        child: Column(
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
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error, size: 120, color: Colors.red);
                              },
                            ),
                            Positioned(
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index, true),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
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
                                onTap: () => _removeImage(index, false),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
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
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Añadir Imágenes"),
              ),
            ),
            const SizedBox(height: 15.0),
            // Campos de texto
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 15.0),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 15.0),
            TextFormField(
              controller: _detailController,
              decoration: const InputDecoration(labelText: 'Detalle'),
            ),
            const SizedBox(height: 15.0),
            // Campo de categoría
            DropdownButtonFormField<String>(
              value: _selectedCategory,
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
              decoration: const InputDecoration(labelText: 'Categoría'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Seleccione una categoría' : null,
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  // Guardar cambios
                }
              },
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
