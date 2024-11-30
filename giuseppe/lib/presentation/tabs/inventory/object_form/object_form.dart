import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:giuseppe/presentation/tabs/tabs_page.dart';
import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/common_widgets/custom_text_form_field.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../../../../models/object_model.dart';
import '../../../../services/firebase_services/firestore_database/object_service.dart';

class ObjectForm extends StatefulWidget {
  const ObjectForm({super.key});

  @override
  State<ObjectForm> createState() => _ObjectFormState();
}

class _ObjectFormState extends State<ObjectForm> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Parte fija
              Stack(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                      child: const Image(
                        image: AssetImage('assets/images/logo.png'),
                        height: 70.0,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 22.0),
                child: const Text(
                  "AÑADIR A INVENTARIO",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),

              // Parte deslizante
              const Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: _NewObjectForm(),
                  ),
                ),
              ),
            ],
          ),

          // Fondo opaco y carga
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

  // Método de cambio de estado
  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }
}

class _NewObjectForm extends StatefulWidget {
  const _NewObjectForm();
  @override
  State<_NewObjectForm> createState() => _NewObjectFormState();
}

class _NewObjectFormState extends State<_NewObjectForm> {
  final _formKey = GlobalKey<FormState>();
  final ObjectService _objectService = ObjectService(); //servicio
  final ImagePicker picker = ImagePicker();
  List<File> _itemImg = []; //imagenes

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  String? _selectedCategory;
  List<String> categories = [
    'Plasticos',
    'Metales',
    'Vidrio',
    'Papel',
    'Otros'
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side:
            const BorderSide(color: AppColors.primaryVariantColor, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      // Carrusel de imágenes
                      Center(
                        child: _itemImg.isEmpty
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
                          items: _itemImg.map((img) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Stack(
                                  children: [
                                    Image.file(
                                      img,
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => removeImage(_itemImg.indexOf(img)),
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
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          style: const ButtonStyle(),
                          onPressed: getImages,
                          child: const Text("Añadir Imágenes"),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Text('Nombre', style: Theme.of(context).textTheme.bodyMedium),
                  CustomTextFormField(
                    formFieldType: FormFieldType.name,
                    hintText: 'Ingrese nombre del item',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 15.0),
                  Text('Cantidad',
                      style: Theme.of(context).textTheme.bodyMedium),
                  CustomTextFormField(
                    formFieldType: FormFieldType.quantity,
                    hintText: 'Ingrese la cantidad en stock',
                    controller: _quantityController,
                  ),
                  const SizedBox(height: 15.0),
                  Text('Detalle',
                      style: Theme.of(context).textTheme.bodyMedium),
                  CustomTextFormField(
                      formFieldType: FormFieldType.description,
                      hintText:
                          'Ingrese Detalles del item (ubicación, dimensiones)',
                      controller: _detailController),
                  const SizedBox(height: 15.0),
                  Text('Categoría',
                      style: Theme.of(context).textTheme.bodyMedium),
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
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Center(
                      child: SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: _saveObject,
                      child: const Text("Añadir"),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void removeImage(int index) {
    setState(() {
      _itemImg.removeAt(index); // Elimina la imagen del índice
    });
  }

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

  Future<void> _saveObject() async {
    if (_itemImg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione imágenes.')),
      );
      return;
    }

    // Validar los campos
    if (_formKey.currentState!.validate()) {
      var parentState = context.findAncestorStateOfType<_ObjectFormState>();
      parentState?.setLoading(true);  // Activar el indicador de carga

      // Crear el objeto y asignar la lista de imágenes
      ObjectModel object = ObjectModel(
        name: _nameController.text,
        quantity: _quantityController.text,
        detail: _detailController.text,
        category: _selectedCategory ?? 'Sin categoría',
        images: [],  // Inicializar la lista de imágenes
      );

      // Guardar el objeto en Firestore
      bool success = await _objectService.saveObjectWithImages(_itemImg, object);

      if (!mounted) return;
      parentState?.setLoading(false);  // Desactivar el indicador de carga

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objeto añadido exitosamente.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TabsPage(isAdmin: true)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al añadir el objeto.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos correctamente.')),
      );
    }
  }
}
