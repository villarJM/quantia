import 'dart:collection';

class Quantia {

  static bool isNumber(String value) {
    return value.isNotEmpty && value.length == 1 && value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
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

  /// Algoritmo Shunting Yard para convertir a notación postfija (RPN)
  static List<String> toPostfix(String expression) {

    expression.trim();

    List<String> output = [];
    Queue<String> operators = Queue();

    final regex = RegExp(r'(\d+(\.\d+)?|\+|\-|\*|\/|\(|\))');
    final tokens = regex.allMatches(expression).map((m) => m.group(0)!).toList();

    if (tokens.isEmpty) return ["0"];

    for (var token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token); // Números van al output
      } else if (isOperator(token)) {
        while (operators.isNotEmpty &&
            getPrecedence(operators.last) >= getPrecedence(token)) {
          output.add(operators.removeLast());
        }
        operators.addLast(token);
      } else if (token == '(') {
        operators.addLast(token);
      } else if (token == ')') {
        while (operators.isNotEmpty && operators.last != '(') {
          output.add(operators.removeLast());
        }
        if (operators.isNotEmpty) {
          operators.removeLast(); // Remover el '('
        }
        
      }
    }

    // Añadir operadores restantes al output
    while (operators.isNotEmpty) {
      output.add(operators.removeLast());
    }
    
    return output;
  }

  /// Evaluar expresión en notación postfija (RPN)
  static double evaluatePostfix(List<String> postfix) {

    if (postfix.isEmpty) return 0.0;
    
    Queue<double> stack = Queue();

    for (var token in postfix) {
      if (double.tryParse(token) != null) {
        stack.addLast(double.parse(token));
      } else if (isOperator(token)) {
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (token) {
          case '+':
            stack.addLast(a + b);
            break;
          case '-':
            stack.addLast(a - b);
            break;
          case '*':
            stack.addLast(a * b);
            break;
          case '/':
            if (b == 0) throw Exception('Error: División por cero');
            stack.addLast(a / b);
            break;
        }
      }
    }
    
    return stack.last;
  }

}