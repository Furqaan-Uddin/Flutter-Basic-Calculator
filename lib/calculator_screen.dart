import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(home: Calculator()));

class Calculator extends StatefulWidget {
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  List<String> history = [];
  String userinput = "";
  String result = "0";
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('calc_history', history);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('calc_history') ?? [];
    });
  }

  List<String> buttonList = [
    'AC', '(', ')', '/',
    '7', '8', '9', '*',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', 'C', '=',
  ];

  Future<void> _launchFudLink() async {
    final url = Uri.parse('https://www.linkedin.com/in/furqaan-uddin-4b61ab341');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1d2630) : Colors.white,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            color: isDarkMode ? Colors.white : Colors.black,
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          )
        ],
      ),
      backgroundColor: isDarkMode ? Color(0xFF1d2630) : Colors.grey[100],
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (history.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              userinput = history[index].split('=')[0].trim();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            child: Text(
                              history[index],
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[400] : Colors.black54,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      userinput,
                      style: TextStyle(fontSize: 32, color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.centerRight,
                  child: Text(
                    result,
                    style: TextStyle(
                      fontSize: 48,
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: isDarkMode ? Colors.white : Colors.black),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: buttonList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return CustomButton(buttonList[index]);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: GestureDetector(
          onTap: _launchFudLink,
          child: Text(
            'Made by F.U.D',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.cyanAccent : Colors.blueAccent,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  Widget CustomButton(String text) {
    return InkWell(
      splashColor: isDarkMode ? Color(0xFF1d2630) : Colors.white,
      onTap: () {
        setState(() {
          handleButtons(text);
        });
      },
      child: Ink(
        decoration: BoxDecoration(
          color: getBgColor(text),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 0.5,
              offset: Offset(-3, -3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: getColor(text),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color getColor(String text) {
    if (["/", "*", "+", "-", "C", "(", ")"].contains(text)) {
      return Colors.cyanAccent;
    }
    return isDarkMode ? Colors.white : Colors.black;
  }

  Color getBgColor(String text) {
    if (text == "AC") return Colors.cyanAccent;
    if (text == "=") return Colors.tealAccent;
    return isDarkMode ? Color(0xFF1d2630) : Colors.grey[300]!;
  }

  void handleButtons(String text) {
    if (text == "AC") {
      userinput = "";
      result = "0";
      return;
    }
    if (text == "C") {
      if (userinput.isNotEmpty) {
        userinput = userinput.substring(0, userinput.length - 1);
      }
      return;
    }
    if (text == "=") {
      result = calculate();
      if (result != "Error") {
        history.insert(0, "$userinput = $result");
        saveHistory();
        userinput = result;
      }
      return;
    }
    userinput += text;
  }

  String calculate() {
    try {
      if (userinput.trim().isEmpty) return "0";

      // Return input directly if it's a valid number
      if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(userinput.trim())) {
        return userinput;
      }

      String expression = userinput.replaceAll('x', '*');

      // ✅ Remove trailing invalid operators (like + - * / .)
      expression = expression.replaceAll(RegExp(r'[+\-*/.]+$'), '');

      // ✅ Fix repeated operators like ++, +-, etc.
      expression = expression.replaceAllMapped(
        RegExp(r'([+\-*/])([+\-*/])+'),
            (match) => match[2] == '-' ? '${match[1]}-' : match[1]!,
      );

      // ✅ Add multiplication between number and opening parenthesis: 2(3+1)
      expression = expression.replaceAllMapped(
        RegExp(r'(\d)(\()'),
            (match) => '${match[1]}*${match[2]}',
      );

      var exp = Parser().parse(expression);
      var evaluation = exp.evaluate(EvaluationType.REAL, ContextModel());

      return evaluation.toString().replaceAll('.0', '');
    } catch (e) {
      return "Error";
    }
  }

}
