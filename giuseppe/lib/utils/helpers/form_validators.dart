class FormValidators {

  // *Validaciones para los formularios de Usuario
  static String? validateEmail({required String email}) {
    if (email.isEmpty) {
      return 'Se requiere un email.';
    }

    // Verificar texto antes y después de '@', un solo '@', un '.' seguido de más texto
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Se requiere un email válido.';
    }

    return email.length >= 7 ? null : 'El email debe contener al menos 6 caracteres.';
  }

  static String? validatePassword({required String password}) {
    if (password.isEmpty) {
      return 'Contraseña incorrecta.';
    }
    return password.length >= 6 ? null : 'Contraseña incorrecta.';
  }

  static String? validateIdentityCard({required String identityCard}) {
    if (identityCard.isEmpty) {
      return 'Usuario incorrecto.';
    }
    return identityCard.length >= 10 ? null : 'Usuario incorrecto.';
  }

  static String? validateUserName({required String name}) {
    String auxName = name.trim();
    if (auxName.isEmpty) {
      return 'Se requiere nombre.';
    } else if (auxName.length != name.length) {
      return 'El nombre no debe contener espacios.';
    }
    return name.length >= 2 ? null : 'El nombre debe contener al menos 2 caracteres.';
  }


  // *Validaciones para los formularios de Objeto
  static String? validateId({required String id}) {
    if (id.isEmpty) {
      return 'El campo no puede estar vacio.';
    }
    return null;
  }

  static String? validateQuantity({required String quantity}) {
    if (quantity.isEmpty) {
      return 'El campo no puede estar vacio.';
    }

    final intQuantity = int.tryParse(quantity);
    if (intQuantity == null || intQuantity < 1) {
      return 'Ingrese una cantidad válida.';
    }

    return null;
  }

  // *Validaciones genericas para otros campos
  static String? validateOtherField({required String value}) {
    return value.isNotEmpty ? null : 'Este campo no puede estar vacio.';
  }

}