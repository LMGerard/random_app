import 'package:flutter/material.dart';
import '../custom_icons/custom_icons.dart';
import 'dart:math';

const double iconSize = 80;
Map<int, Icon> dicesIcons = {
  1: Icon(
    CustomIcons.dice_one,
    size: iconSize,
    color: Colors.indigo[400],
  ),
  2: Icon(
    CustomIcons.dice_two,
    size: iconSize,
    color: Colors.red[300],
  ),
  3: Icon(CustomIcons.dice_three, size: iconSize, color: Colors.green[300]),
  4: Icon(
    CustomIcons.dice_four,
    size: iconSize,
    color: Colors.pink[200],
  ),
  5: Icon(
    CustomIcons.dice_five,
    size: iconSize,
    color: Colors.deepPurple[300],
  ),
  6: Icon(CustomIcons.dice_six, size: iconSize, color: Colors.blue[300])
};

final random = Random();
int randomNumber() {
  return random.nextInt(6) + 1;
}

final List<int> dices = [randomNumber(), randomNumber()];

class DicesTab extends StatefulWidget {
  const DicesTab({Key? key}) : super(key: key);

  @override
  DicesTabState createState() => DicesTabState();
}

class DicesTabState extends State<DicesTab> {
  int? _highlightedDices;

  void _rollDices() {
    setState(() {
      for (int i = 0; i < dices.length; i++) {
        dices[i] = randomNumber();
      }
    });
  }

  void _addDice() {
    if (dices.length >= 30) return;
    setState(() {
      dices.add(randomNumber());
    });
  }

  void _delDice() {
    if (dices.length == 1) return;
    setState(() {
      dices.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      for (int i in dices)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _highlightedDices =
                                  _highlightedDices == i ? null : i;
                            });
                          },
                          child: (() {
                            if (_highlightedDices == null ||
                                i == _highlightedDices)
                              return dicesIcons[i];
                            else
                              return ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      Color.fromARGB(50, 0, 0, 0),
                                      BlendMode.modulate),
                                  child: dicesIcons[i]);
                          })(),
                        )
                    ],
                  ))),
          Text(
            "Total : " + (() => dices.reduce((a, b) => a + b).toString())(),
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 15),
          Container(
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: _delDice,
                    child: Icon(
                      Icons.remove,
                      size: 30,
                    )),
                ElevatedButton(
                    onPressed: _addDice,
                    child: Icon(
                      Icons.add,
                      size: 30,
                    )),
              ],
            ),
          ),
          Container(
              width: 80,
              height: 60,
              child:
                  ElevatedButton(onPressed: _rollDices, child: Text("ROLL !"))),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}
