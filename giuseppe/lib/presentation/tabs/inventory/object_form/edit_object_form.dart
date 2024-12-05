import 'dart:io';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/object_service.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';
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

          // Flecha para retroceder
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onPrimaryColor, size: 30),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Column(
            children: [

              // Parte fija
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

              // Parte deslizante
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
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _detailController;
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

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
    _selectedCategory = widget.item['category'] ?? _categories[0];
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
    if (_localImages.length + _remoteImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 4 imágenes.')),
      );
      return;
    }

    final List<XFile>? tempImgs = await picker.pickMultiImage();
    if (tempImgs != null) {
      setState(() {
        for (var img in tempImgs) {
          if (_localImages.length + _remoteImages.length < 4) {
            _localImages.add(File(img.path));
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
            color: AppColors.primaryVariantColor,
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
                      : Stack(
                    children: [
                      CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          height: 120.0,
                          enlargeCenterPage: true,
                          autoPlay: false,
                          enableInfiniteScroll: false,
                          aspectRatio: 1.0,
                          viewportFraction: 0.7,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                        ),
                        items: [
                          // Imágenes remotas
                          ..._remoteImages.asMap().entries.map((entry) {
                            int index = entry.key;
                            String url = entry.value;
                            return GestureDetector(
                              onTap: () => _showDeleteOption(context, index, false),
                              child: Image.network(
                                url,
                                height: 120,
                                width: 120,
                                fit: BoxFit.contain,
                              ),
                            );
                          }).toList(),
                          // Imágenes locales
                          ..._localImages.asMap().entries.map((entry) {
                            int index = entry.key; // Definimos 'index' aquí
                            File file = entry.value;
                            return GestureDetector(
                              onTap: () => _showDeleteOption(context, index, false),
                              child: Image.file(
                                file,
                                height: 120,
                                width: 120,
                                fit: BoxFit.contain,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      // Flecha izquierda
                      if (_currentImageIndex > 0)
                        Positioned(
                          left: 10,
                          top: 50,
                          child: GestureDetector(
                            onTap: () {
                              _carouselController.previousPage(
                                duration:
                                const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: AppColors.onPrimaryColor,
                                size: 20,
                              ),

                          ),
                        ),
                      // Flecha derecha
                      if (_currentImageIndex <
                          (_remoteImages.length + _localImages.length - 1))
                        Positioned(
                          right: 10,
                          top: 50,
                          child: GestureDetector(
                            onTap: () {
                              _carouselController.nextPage(
                                duration:
                                const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.onPrimaryColor,
                                size: 20,
                              ),
                          ),
                        ),
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
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: AppColors.primaryVariantColor,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: AppColors.primaryVariantColor,
                          width: 1.0,
                        ),
                      ),
                    ),
                    hint: const Text('Seleccione una categoría'),
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCategory = value ?? _categories[0];
                      });
                    },
                    menuMaxHeight: 170.0,
                    dropdownColor: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 30.0),
                Center(
                  child: SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          // Guardar lógica
                        }
                      },
                      child: const Text("Guardar"),
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


// Función para mostrar la opción de eliminar
  void _showDeleteOption(BuildContext context, int index, bool isRemote) {
    showModalBottomSheet(
      backgroundColor: AppColors.primaryColor,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Desea eliminar esta imagen?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar'),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      _removeImage(index, isRemote);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Eliminar'),
                  ),

                ],
              ),
            ],
          ),
        );
      },
    );
  }

}
