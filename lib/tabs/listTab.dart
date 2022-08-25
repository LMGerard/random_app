import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../custom_icons/custom_icons.dart';
import 'dart:math';
import 'package:get_storage/get_storage.dart';

final random = Random();
final storage = GetStorage('listTab');
final List<String> _list = (() {
  var choicesList = (storage.read('choicesList') ?? "").toString();

  return choicesList.isEmpty ? [].cast<String>() : choicesList.split('\n');
})();

class ListTab extends StatefulWidget {
  @override
  _ListTabState createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> with TickerProviderStateMixin {
  int currentTab = 0;
  late TabController _nestedTabController;
  @override
  void initState() {
    _nestedTabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TabBar(
          onTap: (tabIndex) {
            if (tabIndex == currentTab) return;
            FocusScope.of(context).requestFocus(new FocusNode());
            currentTab = tabIndex;
          },
          controller: _nestedTabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.black54,
          isScrollable: true,
          tabs: <Widget>[
            Tab(
              icon: Icon(CustomIcons.pen),
            ),
            Tab(
              icon: Icon(Icons.pie_chart),
            ),
          ],
        ),
        Container(
            child: Expanded(
          child: TabBarView(
              controller: _nestedTabController,
              children: [ListEditingTab(), WheelTab()]),
        ))
      ],
    );
  }
}

class ListEditingTab extends StatefulWidget {
  const ListEditingTab({Key? key}) : super(key: key);

  @override
  _ListEditingTabState createState() => _ListEditingTabState();
}

class _ListEditingTabState extends State<ListEditingTab> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final textInput = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildItem(
      BuildContext context, String value, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.blue, width: 1))),
          child: Row(
            children: [
              SizedBox(
                width: 5,
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.center,
                child: Text(value, style: TextStyle(fontSize: 20)),
              )),
              ElevatedButton(
                onPressed: () {
                  _removeChoice(_list.indexOf(value));
                  _saveList();
                },
                child: Icon(Icons.delete),
                style: ElevatedButton.styleFrom(primary: Colors.red),
              ),
              SizedBox(
                width: 5,
              ),
            ],
          )),
    );
  }

  void _addChoice(String choice) async {
    _listKey.currentState!
        .insertItem(_list.length, duration: const Duration(milliseconds: 250));
    _list.insert(_list.length, choice);
  }

  void _saveList() {
    storage.write('choicesList', _list.join('\n'));
  }

  void _removeChoice(int index) {
    if (index >= _list.length) return;
    String value = _list[index];
    _list.removeAt(index);
    _listKey.currentState!.removeItem(
        index, (_, animation) => _buildItem(context, value, animation),
        duration: const Duration(milliseconds: 250));
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
              child: AnimatedList(
                  key: _listKey,
                  initialItemCount: _list.length,
                  itemBuilder: (context, index, animation) {
                    return _buildItem(context, _list[index], animation);
                  })),
          Row(
            children: [
              SizedBox(
                width: 25,
              ),
              Flexible(
                  child: TextField(
                      controller: textInput,
                      decoration: InputDecoration(
                        hintText: "Type text",
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2)),
                      ))),
              SizedBox(
                width: 5,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (textInput.text == "" || _list.contains(textInput.text))
                      return;
                    _addChoice(textInput.text);
                    textInput.text = "";

                    _saveList();
                  },
                  child: Icon(Icons.add)),
              SizedBox(
                width: 20,
              )
            ],
          ),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}

class WheelTab extends StatefulWidget {
  const WheelTab({Key? key}) : super(key: key);

  @override
  _WheelTabState createState() => _WheelTabState();
}

class _WheelTabState extends State<WheelTab> with TickerProviderStateMixin {
  final ValueNotifier _resultNotifier = ValueNotifier(0);
  String _result = "";
  bool _wheelRolling = false;
  bool _wheelRoll = false;
  late double _rotationTurns;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _rotationTurns = 10 + random.nextDouble();

    AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _rotationTurns -= 10;
          var rotation = (0.25 + _rotationTurns) % 1;

          double k = 1 / _list.length;

          for (int i = 0; i < _list.length; i++) {
            if (1 - (i + 1) * k < rotation && rotation < 1 - i * k) {
              _result = _list[i];
              _resultNotifier.value++;

              break;
            }
          }
        }

        _wheelRolling = false;
      });

    if (_wheelRoll) {
      _controller.forward();
      _wheelRoll = false;
      _wheelRolling = true;
      _result = "??";
      _resultNotifier.value++;
    }
    return Container(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Icon(
            Icons.arrow_downward,
            size: 50,
          ),
          Container(
              width: 320,
              height: 320,
              child: RotationTransition(
                  turns: Tween(begin: 0.0, end: _rotationTurns)
                      .animate(_controller),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.yellow, shape: BoxShape.circle),
                    child: PieChart(PieChartData(
                        centerSpaceColor: Colors.yellow,
                        centerSpaceRadius: 10,
                        borderData: FlBorderData(show: false),
                        sections: _list.asMap().entries.map((e) {
                          Color color;
                          int k;
                          if (_list.length % 2 == 0)
                            k = 2;
                          else if (_list.length % 3 > 1)
                            k = 3;
                          else
                            k = 4;

                          color = [
                            Colors.red[500]!,
                            Colors.red[600]!,
                            Colors.red[700]!,
                            Colors.red[800]!
                          ][e.key % k];

                          return PieChartSectionData(
                              value: 1,
                              title: e.value,
                              color: color,
                              radius: 150);
                        }).toList())),
                  ))),
          ElevatedButton(
              onPressed: () {
                if (_wheelRolling || _list.isEmpty) return;
                setState(() {
                  _wheelRoll = true;
                });
              },
              child: Text("Roll !")),
          ValueListenableBuilder(
              valueListenable: _resultNotifier,
              builder: (context, _, widget) {
                return Text(
                  _result,
                  style: TextStyle(fontSize: 30),
                );
              })
        ],
      ),
    ));
  }
}
