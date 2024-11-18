import 'dart:collection';

import 'package:calculator/presentation/utils/quantia_utils.dart';
import 'package:flutter/material.dart';

class Quantia {

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
      } else if (QuantiaUtils.isOperator(token)) {
        while (operators.isNotEmpty &&
            QuantiaUtils.getPrecedence(operators.last) >= QuantiaUtils.getPrecedence(token)) {
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
      } else if (QuantiaUtils.isOperator(token)) {
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

  static String processInput(String input) {
    // Paso 1: Detectar si la entrada es una ecuación
    if (input.contains('=')) { // Si hay un igual, es una ecuación
      return evaluateLinearEquations(input);
    } else {
      return evaluateExpression(input);
    }
  }

  static String evaluateLinearEquations(String expression) {
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
        return "$constants.0";
      } else {
        throw Exception("Sin Soluciones");
      }
    }
  }

  static String evaluateExpression(String expression) {
    // Paso 1: Separar la expresión en términos (dividir por '+' y '-')
    List<String> terms = splitTerms(expression);
    // Paso 2: Inicializar el coeficiente total de x y la constante total
    int coefTotalXVariable = 0;
    int constantTotal = 0;
    String result = "";
    String termTotal = "";
    String constTotal = "";
    List<String> termsWithVariable = [];
    List<String> termsWithConstant = [];
    List<String> uniqueVariableList = [];
    Set<String?> uniqueVariables = {};
    List<String> plusForTerms = [];

    //pila de posiciones de las variables
    String currentVar = "";

    // Paso 2.1: Separar terminos de las constantes
    termsWithVariable = terms.where( QuantiaUtils.containsVariable ).toList();
    termsWithConstant = terms.where( (term) => !QuantiaUtils.containsVariable(term) ).toList();
    uniqueVariables = terms
    .map(QuantiaUtils.extractVariable)
    .where((variable) => variable != null)
    .toSet();

    uniqueVariableList = List.from(uniqueVariables);
    // Sumar terminos
    for (var i = 0; i < uniqueVariableList.length; i++) {
      for (var j = 0; j < termsWithVariable.length; j++) {
        currentVar = QuantiaUtils.extractVariable(termsWithVariable[j])!;
        if (uniqueVariableList[i] == currentVar) {
          final coefficient = extractCoefficient(termsWithVariable[j], currentVar);
          coefTotalXVariable = coefTotalXVariable + coefficient;
        }
      }
      termTotal += "$coefTotalXVariable${uniqueVariableList[i]}";
      plusForTerms.add('$coefTotalXVariable${uniqueVariableList[i]}');
      coefTotalXVariable = 0;
    }
    // Sumar constantes
    for (var term in termsWithConstant) {
      final constant = convertToNumber(term); // Convertir el término a número
        constantTotal = constantTotal + constant; // Sumar a la constante total
        constTotal = '$constantTotal';
        if (constant > 0) {
          constTotal = '+$constTotal';
        } else if (constant == 0) {
          constTotal = "";
        }
    }
    result = '$termTotal$constTotal';
    // Paso 4: Devolver el resultado (coeficiente de x y constante total)
    return result;
  }

  static List<String> getTerms(String expression) {
    final tokens = expression.split("");
    List<String> terms = [];
    String currentTerm = "";

    for (var char in tokens) {
      if (QuantiaUtils.isOperator(char)) {
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
      if (!QuantiaUtils.isLetter(term)) {
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
      isNagative = false;
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
  
  static List<String> splitTerms(String expression) {
    // Dividir la expresión en términos, separando por '+' y '-'
    final terms = divideByOperators(expression, ['+', '-']);
    return terms;
  }
  
  static List<String> divideByOperators(String expression, List<String> operators) {
    // Paso 1: Inicializar una lista para los términos
    List<String> terms = [];
    // Paso 2: Iterar sobre la expresión y dividirla según los operadores
    int startTerm = 0;  // El inicio de un nuevo término
    for (var i = 0; i < expression.length - 1; i++) {
      if (operators.contains(expression[i])) {
        // Si encontramos un operador, guardar el término hasta esa posición
        if (expression.substring(startTerm, i).isNotEmpty) {
          terms.add(expression.substring(startTerm, i).trim()); // Se toma el término anterior sin espacios
          startTerm = i; // El siguiente término comienza después del operador
        }
        
      }
    }
    // Agregar el último término después del último operador
    terms.add(expression.substring(startTerm).trim());
    // Paso 3: Retornar la lista de términos
    return terms;
  }
  
}