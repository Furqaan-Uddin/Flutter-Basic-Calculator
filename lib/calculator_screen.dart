import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class Calculator extends StatefulWidget{
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {

  String userinput = "";
  String result = "0";

  List<String> buttonList =[
    'AC','(',')','/',
    '7','8','9','*',
    '4','5','6','+',
    '1','2','3','-',
    'C','0','.','='
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF1d2630),
      body: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height/3,
          child: Column(mainAxisAlignment: MainAxisAlignment.end,
          children: [
          Container(padding: EdgeInsets.all(20),
          alignment: Alignment.centerRight,
            child: Text(
              userinput,
              style: TextStyle(
                fontSize: 32,
                color: Colors.white
            ),
            ),
          ),
            Container(padding: EdgeInsets.all(10),
              alignment: Alignment.centerRight,
              child: Text(
                result,
                style: TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
        ],),
        ),
        Divider(color: Colors.white,),
        Expanded(child: Container(
          padding: EdgeInsets.all(10),
          child: GridView.builder(
              itemCount: buttonList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (BuildContext context, int index){
                return CustomButton(buttonList[index]);
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget CustomButton(String text){
    return InkWell(
      splashColor: Color(0xFF1d2630),
      onTap: (){
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
              color: Colors.white.withOpacity(0.1),
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
  getColor(String text){
    if(text == "/" || text == "*" || text == "+" || text == "-" || text == "C" || text == "(" || text == ")"){
      return Colors.cyanAccent;
    }
    return Colors.white;
  }
  getBgColor(String text){
    if(text == "AC"){
      return Colors.cyanAccent;
    }
    if(text == "="){
      return Colors.tealAccent;
    }
    return Color(0xFF1d2630);
  }
  handleButtons(String text){
    if(text == "AC"){
      userinput = "";
      result = "0";
      return;
    }
    if(text == "C"){
      if(userinput.isNotEmpty){
        userinput = userinput.substring(0, userinput.length -1);
        return;
      }
      else{
        return null;
      }
    }

    if(text == "="){
      result = calculate();
      userinput = result;

      if(userinput.endsWith(".0")) {
        return userinput = userinput.replaceAll(".0", "");
      }

      if(result.endsWith(".0")){
        return result = result.replaceAll(".0", "");
        return;
      }
    }

    userinput = userinput + text;

  }

  String calculate(){
    try{
      var exp = Parser().parse(userinput);
      var evaluation = exp.evaluate(EvaluationType.REAL, ContextModel());
      return evaluation.toString();
    }catch(e){
      return "Error";
    }
  }
}