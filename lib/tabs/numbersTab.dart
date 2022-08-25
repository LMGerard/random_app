import 'package:flutter/material.dart';
import 'dart:math';

class NumbersTab extends StatefulWidget {
  NumbersTab({Key? key, this.title = ""}) : super(key: key);
  final String title;

  @override
  _NumbersTabState createState() => _NumbersTabState();
}

class _NumbersTabState extends State<NumbersTab> {
  static final List<String> _numbersHistory = [];
  bool _historicActivated = false;
  final _firstBornController = TextEditingController();
  final _secondBornController = TextEditingController();
  final _randomNumberNotifier = ValueNotifier(0);
  String _randomNumber = "0";

  void _generateNumber() {
    num? firstBorn = num.tryParse(_firstBornController.text);
    num? secondBorn = num.tryParse(_secondBornController.text);

    if (firstBorn != null && secondBorn != null) {
      num minBorn = min(firstBorn, secondBorn);
      num maxBorn = max(firstBorn, secondBorn);

      _numbersHistory.add("$minBorn|$maxBorn|$_randomNumber");
      if (_numbersHistory.length > 20) _numbersHistory.removeAt(0);

      var rng = new Random();
      _randomNumber = (rng.nextDouble() * (maxBorn - minBorn + 1) + minBorn)
          .floor()
          .toString();
      _randomNumberNotifier.value++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          width: 225,
          child: TextField(
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "From",
                labelStyle: TextStyle(fontSize: 20)),
            keyboardType: TextInputType.number,
            controller: _firstBornController,
            maxLength: 15,
          ),
        ),
        Container(
          width: 225,
          child: TextField(
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "to",
                labelStyle: TextStyle(fontSize: 20)),
            keyboardType: TextInputType.number,
            controller: _secondBornController,
            maxLength: 15,
          ),
        ),
        ElevatedButton(
            onPressed: _generateNumber,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 30,
            )),
        FittedBox(
          fit: BoxFit.contain,
          child: ValueListenableBuilder(
              valueListenable: _randomNumberNotifier,
              builder: (context, value, child) {
                return Text(
                  _randomNumber,
                  style: TextStyle(fontSize: 40),
                );
              }),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                  label: Text("History", style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    setState(() {
                      _historicActivated = !_historicActivated;
                    });
                  },
                  icon: _historicActivated
                      ? Icon(Icons.arrow_drop_down_outlined)
                      : Icon(Icons.arrow_drop_up_outlined)),
              SizedBox(height: 10),
              ValueListenableBuilder(
                  valueListenable: _randomNumberNotifier,
                  builder: (BuildContext context, __, Widget? widget) {
                    if (!_historicActivated) return Container();

                    if (_numbersHistory.isEmpty)
                      return Expanded(
                          child: Center(
                              child: Text(
                        "No history",
                        style: TextStyle(fontSize: 25, color: Colors.grey),
                      )));

                    return Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: _numbersHistory.length,
                        itemBuilder: (context, index) {
                          var nbrs = _numbersHistory[
                                  _numbersHistory.length - index - 1]
                              .split('|');
                          TextStyle txtSt = TextStyle(fontSize: 20);
                          return Card(
                              color: Colors.blue,
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Min", style: txtSt),
                                          Text("Max", style: txtSt),
                                          Text("Result", style: txtSt)
                                        ]),
                                    SizedBox(width: 10),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(":", style: txtSt),
                                          Text(":", style: txtSt),
                                          Text(":", style: txtSt)
                                        ]),
                                    SizedBox(width: 10),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(nbrs[0], style: txtSt),
                                          Text(nbrs[1], style: txtSt),
                                          Text(nbrs[2], style: txtSt)
                                        ])
                                  ])));
                        },
                      ),
                    );
                  })
            ],
          ),
        ),
      ],
    );
  }
}
