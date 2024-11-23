import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/common_widgets/custom_text_form_field.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class ObjectForm extends StatefulWidget {
  const ObjectForm({super.key});

  @override
  State<ObjectForm> createState() => _ObjectFormState();
}

class _ObjectFormState extends State<ObjectForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
    );
  }
}

class _NewObjectForm extends StatefulWidget {
  const _NewObjectForm();

  @override
  State<_NewObjectForm> createState() => _NewObjectFormState();
}

class _NewObjectFormState extends State<_NewObjectForm> {
  final ImagePicker picker = ImagePicker();
  final List<File> _images = [];

  Future<void> pickImagesFromGallery() async {
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    setState(() {
      _images.addAll(pickedFiles.map((file) => File(file.path)));
    });
    }

  //Eliminar imagen
  void removeImage(int index) {
    setState(() {
      _images.removeAt(index); //
    });
  }

  @override
  Widget build(BuildContext context) {
    String? selectedCategory;
    List<String> categories = ['Plasticos', 'Metales', 'Vidrio', 'Papel', 'Otros'];

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: AppColors.primaryVariantColor, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      // Carrusel de imágenes
                      _images.isNotEmpty
                          ? SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(8.0),
                                  child: Image.file(
                                    _images[index],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => removeImage(index),
                                    //boton para borrar imagenes
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
                        ),
                      )
                          : const Center(
                      ),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          style: ButtonStyle(),
                          onPressed: pickImagesFromGallery,
                          child: const Text("Añadir Imágenes"),

                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Text('ID', style: Theme.of(context).textTheme.bodyMedium),
                  const CustomTextFormField(
                    formFieldType: FormFieldType.id,
                    hintText: 'Ingrese ID del item',
                  ),
                  const SizedBox(height: 15.0),
                  Text('Nombre', style: Theme.of(context).textTheme.bodyMedium),
                  const CustomTextFormField(
                      formFieldType: FormFieldType.name,
                      hintText: 'Ingrese nombre del item'),
                  const SizedBox(height: 15.0),
                  Text('Cantidad', style: Theme.of(context).textTheme.bodyMedium),
                  const CustomTextFormField(
                    formFieldType: FormFieldType.quantity,
                    hintText: 'Ingrese la cantidad en stock',
                  ),
                  const SizedBox(height: 15.0),
                  Text('Detalle', style: Theme.of(context).textTheme.bodyMedium),
                  const CustomTextFormField(
                      formFieldType: FormFieldType.description,
                      hintText: 'Ingrese Detalles del item (ubicación, dimensiones)'),
                  const SizedBox(height: 15.0),
                  Text('Categoría', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6.0),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
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
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Center(
                    child: SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("Añadir"),
                      ),
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
