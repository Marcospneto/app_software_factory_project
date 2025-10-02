mixin ValidationsMixin {

  String? isNotEmpty(String? value, [String? message]) {
    if (value == null || value.isEmpty) {
      return message ?? 'Nome é obrigatório';
    }

    return null;
  }

  String? validEmail(String? value, [String? message]) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value!)) {
      return message ?? 'Por favor, insira um email válido';
    }

    return null;
  }

  String? validatePhoneNumber(String? phoneNumber) {
    // Remove caracteres não numéricos
    String cleanedNumber = phoneNumber!.replaceAll(RegExp(r'\D'), '');

    if (cleanedNumber.length < 11) {
      return "O número de telefone está incompleto.";
    }

    if (cleanedNumber.length > 11) {
      return "O número de telefone tem dígitos extras.";
    }

    if (!RegExp(r'^\d{11}$').hasMatch(cleanedNumber)) {
      return "O número de telefone contém caracteres inválidos.";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(value) ||
        !RegExp(r'[a-z]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value) ||
        !RegExp(r'[!@#/\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "A senha deve ter 8 caracteres, incluindo letras maiúsculas, minúsculas, números e caracter especial.";
    }
    return null;
  }


  String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (password == null || confirmPassword == null) {
      return "As senhas não podem ser vazias.";
    }

    if (password.trim() != confirmPassword.trim()) {
      return "As senhas não coincidem.";
    }

    return null;
  }

  String? combine(List<String? Function()> validators){
    for (final func in validators) {
      final validation = func();
      if (validation != null) return validation;
    }
  }

  String? validateCode(String? value) {
    if (value!.length < 6) {
      return "O código deve ter 6 digitos";
    }
  }

}
