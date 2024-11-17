import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({ super.key });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FocusNode _focusNode = FocusNode();

  final tokens = [
    ["C", "%", "+", "DEL"],
    ["7", "8", "9", "x"],
    ["4", "5", "6", "x"],
    ["1", "2", "3", "-"],
    ["7", "0", ".", "/"]
  ];

  bool isNumber(String value) {
    return value.isNotEmpty && value.length == 1 && value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
  }

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

  @override
  Widget build(BuildContext context){
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: size.width,
        height: size.height,
        margin: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0XffFFF3C7),
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tokens.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: item.map((token) {
                    return ButtonQuantia(
                      char: token,
                      isSymbol: isNumber(token),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
            const SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}

class ButtonQuantia extends StatelessWidget {
  final String char;
  final bool isSymbol;

  const ButtonQuantia({super.key, required this.char, required this.isSymbol});


  @override
  Widget build(BuildContext context){
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
        child: ElevatedButton(
          onPressed: () {
            
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            fixedSize: const Size.fromHeight(70),
            backgroundColor: isSymbol ? Colors.white : const Color(0XffFFF3C7)
          ),
          child: Text(char, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),)
        ),
      ),
    );
  }
}

  // final TextEditingController _controller = TextEditingController();
  // final FocusNode _focusNode = FocusNode();

  // bool isLoadFirst = false;
  // List<String> characters = [];
  // bool isEnd = false;
  // int index = 0;
  // int number1 = 0;
  // int number2 = 0;
  // int result = 0;
  // List<int> numbers = [];
  // List<String> operators = [];

  //  @override
  // void initState() {
  //   super.initState();
  //   // Para evitar que el teclado se abra
  //   _focusNode.addListener(() {
  //     if (_focusNode.hasFocus) {
  //       _focusNode.unfocus();
  //     }
  //   });
  // }

  // void evaluate(String expression) {

  //   if (!isLoadFirst) {
  //     characters = expression.split('');
  //     setState(() {
  //       isLoadFirst = true;
  //     });
  //   }

  //   if (isOperator(characters[index]) && index == 0) {
  //     index++;
  //     expression = expression.substring(index);
  //     characters = expression.split('');
  //     setState(() {});
  //   }

  //   if (isNumber(characters[index])) {
  //     number1 = getConsecutiveNumbers(expression);
  //     index = number1.toString().length;
  //     setState(() {});
  //   } else if (isOperator(characters[index]) && isNumber(characters[index + 1])) {
  //     operationAritmetic(characters[index], expression);
  //   }


    






  //   if (!isEnd) {
  //     evaluate(expression);
  //   }
    
  // }

  // operationAritmetic(String value, String expression) {
  //   switch (value) {
  //     case '+':
  //         index++;
  //         number2 = getConsecutiveNumbers(expression.substring((index)));
  //         result = number1 + number2;
  //         number1 = result;
  //         expression = expression.substring(index + number2.toString().length);
  //         print('Result: $result');
  //         if (expression.isEmpty) {
  //           isEnd = true;
  //         } else {
  //           evaluate(expression);
  //         }
  //         setState(() {});
  //       break;
  //     default:
  //   }
  // }

  // bool isNumber(String value) {
  //   return value.isNotEmpty && value.length == 1 && value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
  // }

  // bool isOperator(String value) {
  //   const operators = {'+', '-', '×', '÷', '%'};
  //   if (value.isEmpty) return false;
  //   return (operators.contains(value));
  // }

  // int getDigitNumberAllNumbers(String caracters) {
  //   // obtener el total de digitos en una cadena de caracteres
  //   return caracters.split('').where((c) => isNumber(c)).toList().length;
  // }

  // int getConsecutiveNumbers(String caracters) {
  //   String length = '';
  //   for (var char in caracters.split('')) {
  //     if (isNumber(char)) {
  //       length += char;
  //     } else {
  //       return int.parse(length);
  //     }
  //   }
  //   return int.parse(length);
  // }

  // int getConsecutiveNumberDigits(String caracters) {
  //   // obtener el total de degitos en una cadena, de izquierda a derecha hasta que no se un número, retorna ese tope.
  //   int length = 0;
  //   for (var char in caracters.split('')) {
  //     if (isNumber(char)) {
  //       length++;
  //     } else {
  //       return length;
  //     }
  //   }
  //   return length;
  // }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   _focusNode.dispose();
  //   super.dispose();
  // }

