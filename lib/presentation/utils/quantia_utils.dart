class QuantiaUtils {
  static bool isNumber(String value) {
    return value.isNotEmpty && value.length == 1 && value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
  }
  /// Función para verificar si una letra del abecedario
  static bool isLetter(String char) {
    final letterRegex = RegExp(r'^[a-zA-Z]$');
    return letterRegex.hasMatch(char);
  }
  //Extra la variable de un termino simple 2x. -2x
  static String? extractVariable(String input) {
    // Expresión regular para encontrar letras (a-z, A-Z)
    final regex = RegExp(r'[a-zA-Z]+');
    
    // Buscar la primera coincidencia en el string
    final match = regex.firstMatch(input);
    
    // Retornar la coincidencia si existe, de lo contrario retornar null
    return match?.group(0);
  }

  static bool containsVariable(String term) {
    // Expresión regular que busca letras (a-z, A-Z) en el término.
    final regex = RegExp(r'[a-zA-Z]');
    return regex.hasMatch(term);
  }
  /// Función para verificar si un token es un operador
  static bool isOperator(String token) {
    return ['+', '-', '*', '/'].contains(token);
  }

  /// Asignar precedencia a cada operador
  static int getPrecedence(String operator) {
    if (operator == '+' || operator == '-') return 1;
    if (operator == '*' || operator == '/') return 2;
    return 0;
  }
}