import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get_storage/get_storage.dart';
import 'package:auto_size_text/auto_size_text.dart';

final random = Random();
final storage = GetStorage('cardsTab');
int deckTypeIndex = 0;
const deckTypes = ["52 cards", "32 cards", "Custom"];
const List<String> colors = ["♦", "♣", "♥", "♠"];
final List<bool> customDeck = (() {
  var customDeck = (storage.read('customDeck') ?? "").toString();

  if (customDeck.isEmpty) return List<bool>.filled(13 * 4, true);

  return customDeck.split('').map((e) => e == "1").toList();
})();

String getCardNUmber(int number) =>
    number < 11 ? number.toString() : ["♚", "♛", "♝"][13 - number];

String getCardColor(int colorIndex) => colors[colorIndex];

class CardsTab extends StatefulWidget {
  const CardsTab({Key? key}) : super(key: key);

  @override
  _CardsTabState createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  final ValueNotifier notifier = ValueNotifier(0);
  final List<PlayingCard> _deck = [];

  @override
  void initState() {
    this.generateDeck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Stack(children: _deck)),
              DeckTypeSelector(onChange: () => setState(this.generateDeck)),
              ElevatedButton(
                onPressed: () => setState(this.generateDeck),
                child: Icon(Icons.sync, color: Colors.white, size: 40),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(15),
                  primary: Colors.blue,
                  onPrimary: Colors.red,
                ),
              ),
            ]));
  }

  void generateDeck() {
    void addCard(int color, int number) {
      _deck.add(PlayingCard(
          key: GlobalKey(),
          cardNumber: number,
          cardColorIndex: color,
          onTap: (PlayingCard widget) {
            setState(() {
              _deck.remove(widget);
              _deck.add(widget);
            });
          }));
    }

    _deck.clear();
    if (deckTypeIndex != 2) {
      for (int color = 0; color < 4; color++)
        for (int number = 1; number <= 13; number++)
          if (!(deckTypeIndex == 1 && 2 <= number && number <= 6))
            addCard(color, number);
    } else
      for (int color = 0; color < 4; color++)
        for (int number = 0; number < 13; number++)
          if (customDeck[color * 13 + number]) addCard(color, number + 1);

    _deck.shuffle();
  }
}

class DeckTypeSelector extends StatefulWidget {
  final VoidCallback? onChange;
  const DeckTypeSelector({Key? key, @required this.onChange}) : super(key: key);

  @override
  _DeckTypeSelectorState createState() => _DeckTypeSelectorState();
}

class _DeckTypeSelectorState extends State<DeckTypeSelector> {
  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () => setState(() {
                    if (--deckTypeIndex < 0)
                      deckTypeIndex = deckTypes.length - 1;
                    this.widget.onChange!();
                  }),
              icon: Icon(Icons.arrow_left, size: 40)),
          Container(
            height: 40,
            width: 110,
            child: Align(
                alignment: Alignment.center,
                child: deckTypeIndex < 2
                    ? AutoSizeText(deckTypes[deckTypeIndex], minFontSize: 20)
                    : ElevatedButton.icon(
                        onPressed: () => _showCustomDeckPanel(context),
                        icon: Icon(Icons.format_list_bulleted),
                        label: AutoSizeText(deckTypes[deckTypeIndex],
                            minFontSize: 10),
                      )),
          ),
          IconButton(
              onPressed: () => setState(() {
                    if (++deckTypeIndex >= deckTypes.length) deckTypeIndex = 0;
                    this.widget.onChange!();
                  }),
              icon: Icon(Icons.arrow_right, size: 40))
        ]);
  }

  _showCustomDeckPanel(BuildContext context) {
    showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
        barrierColor: Colors.black.withOpacity(0.4),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (context, anim1, anim2, child) {
          Animation<Offset> _offsetAnimation = Tween<Offset>(
            begin: Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(anim1);

          return SlideTransition(
            position: _offsetAnimation,
            child: CustomDeckPanel(),
          );
        }).then((value) {
      storage.write(
          'customDeck', customDeck.map((e) => e ? "1" : "0").join(""));
      this.widget.onChange!();
    });
  }
}

class CustomDeckPanel extends StatefulWidget {
  const CustomDeckPanel({Key? key}) : super(key: key);
  @override
  _CustomDeckPanelState createState() => _CustomDeckPanelState();
}

class _CustomDeckPanelState extends State<CustomDeckPanel> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: Colors.black, width: 2)),
      contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          TextButton(
              child: Text("♦", style: TextStyle(fontSize: 30)),
              onPressed: () => setState(() {
                    for (int i = 0; i < 13; i++) customDeck[i] = !customDeck[i];
                  })),
          TextButton(
              child: Text("♣", style: TextStyle(fontSize: 30)),
              onPressed: () => setState(() {
                    for (int i = 0; i < 13; i++)
                      customDeck[13 + i] = !customDeck[13 + i];
                  })),
          TextButton(
              child: Text("♥", style: TextStyle(fontSize: 30)),
              onPressed: () => setState(() {
                    for (int i = 0; i < 13; i++)
                      customDeck[26 + i] = !customDeck[26 + i];
                  })),
          TextButton(
              child: Text("♠", style: TextStyle(fontSize: 30)),
              onPressed: () => setState(() {
                    for (int i = 0; i < 13; i++)
                      customDeck[39 + i] = !customDeck[39 + i];
                  }))
        ]),
        Align(
          alignment: Alignment.center,
          child: Container(
              width: 160,
              height: 10,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.black, width: 2)))),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          for (int color = 0; color < 4; color++)
            Column(
              children: [
                for (int numberIndex = 0; numberIndex < 13; numberIndex++)
                  ElevatedButton(
                    child: Text((numberIndex + 1).toString()),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: customDeck[color * 13 + numberIndex]
                            ? Colors.blue
                            : Colors.red),
                    onPressed: () => setState(() {
                      customDeck[color * 13 + numberIndex] =
                          !customDeck[color * 13 + numberIndex];
                    }),
                  )
              ],
            )
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () => null,
                onLongPress: () {
                  setState(() {
                    for (int color = 0; color < 4; color++) {
                      for (int numberIndex = 0;
                          numberIndex < 13;
                          numberIndex++) {
                        customDeck[color * 13 + numberIndex] = true;
                      }
                    }
                  });
                },
                child: null,
                style: ElevatedButton.styleFrom(primary: Colors.blue)),
            Container(
                width: 50,
                height: 50,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: IconButton(
                      padding: EdgeInsets.all(0.0),
                      onPressed: () => Navigator.of(context).pop(),
                      iconSize: 40.0,
                      icon: Icon(Icons.arrow_forward_ios)),
                )),
            ElevatedButton(
                onPressed: () => null,
                onLongPress: () => setState(() {
                      for (int color = 0; color < 4; color++) {
                        for (int numberIndex = 0;
                            numberIndex < 13;
                            numberIndex++) {
                          customDeck[color * 13 + numberIndex] = false;
                        }
                      }
                    }),
                child: null,
                style: ElevatedButton.styleFrom(primary: Colors.red)),
          ],
        )
      ],
    );
  }
}

class PlayingCard extends StatefulWidget {
  final int? cardNumber;
  final int? cardColorIndex;
  final void Function(PlayingCard)? onTap;
  const PlayingCard(
      {Key? key,
      @required this.cardNumber,
      @required this.cardColorIndex,
      this.onTap})
      : super(key: key);

  @override
  _PlayingCardState createState() => _PlayingCardState();
}

class _PlayingCardState extends State<PlayingCard> {
  bool _showFrontSide = false;
  bool _canTurn = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
        alignment:
            _showFrontSide ? Alignment.topCenter : Alignment.bottomCenter,
        duration: Duration(milliseconds: 600),
        child: GestureDetector(
          onTap: () => setState(() {
            if (_canTurn) {
              widget.onTap!(this.widget);
              _showFrontSide = !_showFrontSide;
              _canTurn = false;
            }
          }),
          child: AnimatedSwitcher(
            transitionBuilder: __transitionBuilder,
            layoutBuilder: (widget, list) =>
                Stack(children: [widget!, ...list]),
            duration: Duration(milliseconds: 600),
            child: _showFrontSide ? _buildFront() : _buildRear(),
          ),
        ));
  }

  Widget _buildFront() {
    var colorWdgt = Text(getCardColor(this.widget.cardColorIndex!),
        style: TextStyle(fontSize: 25));
    var numberWdgt = Text(getCardNUmber(this.widget.cardNumber!),
        style: TextStyle(
            fontSize: 25,
            color: this.widget.cardColorIndex! % 2 == 0
                ? Colors.red
                : Colors.black));

    return Container(
        width: 150,
        key: ValueKey(true),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white),
        child: AspectRatio(
            aspectRatio: 150 / 210,
            child: Stack(children: [
              Positioned(
                  left: 5,
                  top: 5,
                  child: Column(children: [colorWdgt, numberWdgt])),
              Positioned(
                  right: 5,
                  bottom: 5,
                  child: Column(children: [numberWdgt, colorWdgt])),
            ])));
  }

  Widget _buildRear() {
    return Container(
        width: 150,
        key: ValueKey(false),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.blue,
                Colors.red,
              ],
            ),
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: AspectRatio(aspectRatio: 150 / 210));
  }

  Widget __transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);

    animation.addListener(() {
      if (animation.status == AnimationStatus.completed) {
        _canTurn = true;
      }
    });

    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(_showFrontSide) != widget!.key);
        final value =
            isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;

        return Transform(
          transform: Matrix4.identity()..rotateY(value),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }
}
