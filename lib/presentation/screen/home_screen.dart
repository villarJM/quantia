import 'package:flutter/material.dart';

Map<int, List<String>> symbol = {
  1 : ['C', 'DEL', '%', '÷' ],
  2 : ['7', '8', '9', '×' ],
  3 : ['4', '5', '6', '-' ],
  4 : ['1', '2', '3', '+' ],
  5 : ['0', '.', '=' ],
};

class HomeScreen extends StatefulWidget {
const HomeScreen({ super.key });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool isLoadFirst = false;
  List<String> characters = [];
  bool isEnd = false;
  int index = 0;
  int number1 = 0;
  int number2 = 0;
  int result = 0;
  List<int> numbers = [];
  List<String> operators = [];

   @override
  void initState() {
    super.initState();
    // Para evitar que el teclado se abra
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
    });
  }

  void evaluate(String expression) {

    if (!isLoadFirst) {
      characters = expression.split('');
      setState(() {
        isLoadFirst = true;
      });
    }

    if (isOperator(characters[index]) && index == 0) {
      index++;
      expression = expression.substring(index);
      characters = expression.split('');
      setState(() {});
    }

    if (isNumber(characters[index])) {
      number1 = getConsecutiveNumbers(expression);
      index = number1.toString().length;
      setState(() {});
    } else if (isOperator(characters[index]) && isNumber(characters[index + 1])) {
      operationAritmetic(characters[index], expression);
    }


    






    if (!isEnd) {
      evaluate(expression);
    }
    
  }

  operationAritmetic(String value, String expression) {
    switch (value) {
      case '+':
          index++;
          number2 = getConsecutiveNumbers(expression.substring((index)));
          result = number1 + number2;
          number1 = result;
          expression = expression.substring(index + number2.toString().length);
          print('Result: $result');
          if (expression.isEmpty) {
            isEnd = true;
          } else {
            evaluate(expression);
          }
          setState(() {});
        break;
      default:
    }
  }

  bool isNumber(String value) {
    return value.isNotEmpty && value.length == 1 && value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
  }

  bool isOperator(String value) {
    const operators = {'+', '-', '×', '÷', '%'};
    if (value.isEmpty) return false;
    return (operators.contains(value));
  }

  int getDigitNumberAllNumbers(String caracters) {
    // obtener el total de digitos en una cadena de caracteres
    return caracters.split('').where((c) => isNumber(c)).toList().length;
  }

  int getConsecutiveNumbers(String caracters) {
    String length = '';
    for (var char in caracters.split('')) {
      if (isNumber(char)) {
        length += char;
      } else {
        return int.parse(length);
      }
    }
    return int.parse(length);
  }

  int getConsecutiveNumberDigits(String caracters) {
    // obtener el total de degitos en una cadena, de izquierda a derecha hasta que no se un número, retorna ese tope.
    int length = 0;
    for (var char in caracters.split('')) {
      if (isNumber(char)) {
        length++;
      } else {
        return length;
      }
    }
    return length;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: true,
              maxLines: 2,
              style: TextStyle(fontSize: 100),
              decoration: const InputDecoration(
                
              ),
            ),
            const Spacer(),
            Column(
              children: symbol.entries.map((entry) => Row(
                children: entry.value.map((value) => CustomButton(
                  code: value,
                  isNumber: isNumber(value),
                  width: 70,
                  onChanged: (value) {
                    
                    if (isNumber(value) || isOperator(value)) {
                      _controller.text += value;
                    }
                    if (value.contains('DEL')) {
                      _controller.text.isNotEmpty 
                      ? _controller.text = _controller.text.substring(0, _controller.text.length - 1) 
                      : null;
                    }
                    if (value.contains('C')) {
                      _controller.text = '';
                    }
                    if (value.contains('=')) {
                      evaluate('+1200+200+200');
                    }
                  },
                ),).toList(),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatefulWidget {
  final String code;
  final bool? isNumber;
  final bool? isOperator;
  final double? width;
  final void Function(String)? onChanged;
  const CustomButton({
    super.key, 
    required this.code,
    this.isNumber,
    this.isOperator,
    this.width,
    this.onChanged
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {

  void onTap(String value) {
    widget.onChanged!(value);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () { onTap(widget.code); },
      child: Container(
        height: 70,
        width: widget.width,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10
          ),
          color: Colors.grey.shade300,
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              spreadRadius: 1,
              color: Colors.grey.shade500,
              offset: const Offset(4, 4),
            ),
            const BoxShadow(
              blurRadius: 15,
              spreadRadius: 1,
              color: Colors.white,
              offset: Offset(-4, -4),
            )
          ]
        ),
        child: Center(child: Text(widget.code, textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
      ),
    );
  }
}