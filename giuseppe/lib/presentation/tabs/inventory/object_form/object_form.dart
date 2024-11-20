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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                      child: const Image(
                        image: AssetImage('assets/images/logo.png'),
                        height: 75.0,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20.0,
                    left: 10.0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text("Añadir a inventario",
                    style: Theme.of(context).textTheme.headlineSmall
                )
              ),
              const Padding(padding: EdgeInsets.all(20.0), child: _NewObjectForm()),
            ],
          ),
        ),
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
  File? _image;

  Future<void> pickImageFromGallery() async {
    final pickFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickFile != null) {
      setState(() {
        _image = File(pickFile.path);
      });
    }
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
        side: const BorderSide(color: AppColors.primaryVariantColor, width: 1.0), // Borde gris
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
                      Center(
                          child: _image != null
                              ? Image.file(_image!, height: 150, fit: BoxFit.fill)
                              : const Icon(Icons.image,size: 150)
                      ),
                      ElevatedButton(
                        onPressed: (){
                          pickImageFromGallery();
                        },
                        child: const Text("Añadir Imagen"))
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Text('ID', style: Theme.of(context).textTheme.bodyMedium),
                  const CustomTextFormField(
                    formFieldType: FormFieldType.id,
                    hintText: '12345a',
                  ),
                  const SizedBox(height: 15.0),
                  Text('Nombre', style: Theme.of(context).textTheme.bodyMedium),
                  const CustomTextFormField(
                      formFieldType: FormFieldType.name,
                      hintText: 'Nombre objeto'),
                  const SizedBox(height: 15.0),
                  Text('Cantidad', style: Theme.of(context).textTheme.bodyMedium),
                  const CustomTextFormField(
                    formFieldType: FormFieldType.quantity,
                    hintText: '2',
                  ),
                  const SizedBox(height: 15.0),
                  Text('Detalle', style: Theme.of(context).textTheme.bodyMedium),
                  const CustomTextFormField(
                      formFieldType: FormFieldType.description,
                      hintText: 'Nombre objeto'),
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
                    child: ElevatedButton(
                      onPressed: (){},
                      child: const Text("Añadir")
                    ),
                  )
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}

