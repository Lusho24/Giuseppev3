import 'package:flutter/material.dart';
import 'package:giuseppe/utils/helpers/form_validators.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';

enum FormFieldType{
  // Campos para los formularios de Usuario:
  email, password, identity_card, username, address, phone,
  // Campos para los formularios de Objetos:
  id, name, description, quantity, status, category
}

class CustomTextFormField extends StatelessWidget {
  final FormFieldType formFieldType;
  final String hintText;
  final TextEditingController? controller;
  final double? height;

  const CustomTextFormField({
    super.key,
    required this.formFieldType,
    required this.hintText,
    this.controller,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: TextFormField(
        controller: controller,
        keyboardType: getKeyboardType(formFieldType: formFieldType),
        obscureText: formFieldType == FormFieldType.password ? true : false,
        minLines: formFieldType == FormFieldType.description ? 2 : 1,
        maxLines: formFieldType == FormFieldType.description ? 2 : 1,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.hintTextColor),
          errorMaxLines: 2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: AppColors.primaryVariantColor,
              width: 1.0,
            ),
          ),
          contentPadding: height != null
              ? EdgeInsets.symmetric(
              vertical: height! , horizontal: 8.0)
              : const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
        validator: (value) => validateFormField(value: value, formFieldType: formFieldType),
      ),
    );
  }


  // *Funcion para obtener el tipo de campo
  TextInputType? getKeyboardType({ required FormFieldType formFieldType }) {
    switch (formFieldType) {
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.password:
        return TextInputType.visiblePassword;
      case FormFieldType.identity_card:
      case FormFieldType.quantity:
        return TextInputType.number; // Caso para el identity_card y quentity
      case FormFieldType.username:
      case FormFieldType.name:
        return TextInputType.name; // Caso para el username y el name
      case FormFieldType.phone:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  // *Funcion para validacion de los campos
  String? validateFormField({ required String? value, required FormFieldType formFieldType }) {
    switch (formFieldType) {
    // Validación de campos para formularios del usuario
      case FormFieldType.email:
        return FormValidators.validateEmail(email: value ?? '');
      case FormFieldType.password:
        return FormValidators.validatePassword(password: value ?? '');
      case FormFieldType.identity_card:
        return FormValidators.validateIdentityCard(identityCard: value ?? '');
      case FormFieldType.username:
        return FormValidators.validateUserName(name: value ?? '');

    // Validación de campos para formularios del objeto
      case FormFieldType.id:
        return FormValidators.validateId(id: value ?? '');
      case FormFieldType.quantity:
        return FormValidators.validateQuantity(quantity: value ?? '');
    // Validacion generica para el resto de campos
      default:
        return FormValidators.validateOtherField(value: value ?? '');
    }
  }

}