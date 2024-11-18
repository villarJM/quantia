import 'dart:collection';

import 'package:flutter/material.dart';

class Quantia {

  static bool isNumber(String value) {
    return value.isNotEmpty && value.length == 1 && value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
  }

  /// Función para verificar si una letra del abecedario
  static bool isLetter(String char) {
    final letterRegex = RegExp(r'^[a-zA-Z]$');
    return letterRegex.hasMatch(char);
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

  static Set<String> divideEquation(String equation) {
    final divide = equation.split("=");
    return {divide.first, divide.last};
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

  ///Algebra
  /*
    VARIABLE
    CONSTANTES
    EXPRESION ALG
    ECUACION
  
   */

  static String evaluateExp(String expression) {
    if (expression.isEmpty) return "0.0";
    // Paso 1: Dividir la ecuación en lado izquierdo y derecho
    final leftEquation = divideEquation(expression).first;
    final rightEquation = divideEquation(expression).last;
    // Paso 2: Convertir ambos lados en listas de términos
    List<String> leftTerms = getTerms(leftEquation);
    List<String> leftTermsCopy = List.from(leftTerms);
    List<String> rightTerms = getTerms(rightEquation);
    List<String> rightTermsCopy = List.from(rightTerms);
    // Paso 3: Mover todos los términos con 'x' al lado izquierdo
    for (var term in rightTermsCopy) {
      if (term.contains('x')) {
        leftTerms.add(invertSign(term));
        rightTerms.remove(term);
      } else {
        leftTerms.remove(term);
      }
    }
    // Paso 4: Mover todos los términos constantes al lado derecho
    for (var term in leftTermsCopy) {
      if (!term.contains('x')) {
        rightTerms.add(invertSign(term));
        leftTerms.remove(term);
      }
    }
    debugPrint("$leftTerms=$rightTerms");
    // Paso 5: Simplificar ambos lados
    final coefficientX = plusCoefficient(leftTerms, 'x');
    final constants = plusConstants(rightTerms);

    if (coefficientX != 0) {
      final x = constants / coefficientX;
      return "$x";
    } else {
      if (constants == 0) {
        throw Exception("Infinitas soluciones (Identidad, como 0 = 0");
      } else {
        throw Exception("Sin Soluciones");
      }
    }
  }

  static List<String> getTerms(String expression) {
    final tokens = expression.split("");
    List<String> terms = [];
    String currentTerm = "";

    for (var char in tokens) {
      if (isOperator(char)) {
        if (currentTerm.isNotEmpty) {
          terms.add(currentTerm);
        }
        currentTerm = char;
      } else {
        currentTerm += char;
      }
    }

    if (currentTerm.isNotEmpty) {
      terms.add(currentTerm);
    }
    return terms;
  }

  static String invertSign(String term) {
    String invert = "";
    if (term.startsWith("-")) {
      invert = term.substring(1, term.length);
    } else  {
      if (term.startsWith('+')) {
        invert = '-${term.substring(1, term.length)}';
      } else {
        invert = '-$term';
      }
    }
    return invert;
  }

  static int plusCoefficient(List<String> terms, String variable) {
    int result = 0;
    for (var term in terms) {
      if (term.contains(variable)) {
        final coefficient = extractCoefficient(term, variable);
        result += coefficient;
      }
    }
    return result;
  }

  static int plusConstants(List<String> terms) {
    int result = 0;
    for (var term in terms) {
      if (!isLetter(term)) {
        result += convertToNumber(term);
      }
    }
    return result;
  }
  // Esta función extrae el coeficiente de un término de la variable
  static int extractCoefficient(String term, String variable) {
    if (term.contains(variable)) {
      // Si la variable está al final del término (por ejemplo: 3x o -5x)
      if (term.startsWith(variable)) {
        return 1;
      } else {
        // Extraer el número antes de la variable
        final coefficient = extractNumberBeforeVariable(term, variable);
        return coefficient;
      }
    } else {
      return 0;
    }
  }
  // Esta función extrae el número que precede a la variable en el término
  static int extractNumberBeforeVariable(String term, String variable) {
    final indexVariable = term.indexOf(variable);
    final number = convertToNumber(term.substring(0,indexVariable));
    return number;
  }

  static int convertToNumber(String numberText) {
    int number = 0;
    bool isNagative = true;
    int index = 0;
    // Paso 1: Verificar si la cadena está vacía
    if (numberText.isEmpty) return 0;
    // Paso 2: Detectar signos positivos o negativos
    if (numberText == '+') return 1;
    if (numberText == '-') return -1;
    // Paso 3: Convertir la cadena a número

    // Si el primer carácter es un signo
    if (numberText[0] == '-') {
      isNagative = true;
      index = 1;
    } else if (numberText[0] == '+') {
      index = 1;
    } else {
      isNagative = false;
    }
    // Convertir los caracteres restantes a número
    for (int i = index; i < numberText.length; i++) {
      if (numberText[i].compareTo('0') >= 0 && numberText[i].compareTo('9') <= 0) {
        number = number * 10 + (numberText[i].codeUnitAt(0) - '0'.codeUnitAt(0));
      } else {
        break;
      }
    }
    // Aplicar el signo negativo si es necesario
    if (isNagative) {
      number = - number;
    }

    return number;
  }
  
}