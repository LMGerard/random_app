import 'package:flutter/material.dart';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';

int? dzq;
const List<String> answers = [
  'It is Certain.',
  'It is decidedly so.',
  'Without a doubt.',
  'Yes definitely.',
  'You may rely on it.',
  'As I see it, yes.',
  'Most likely.',
  'Outlook good.',
  'Yes.',
  'Signs point to yes.',
  'Reply hazy, try again.',
  'Ask again later.',
  'Better not tell you now.',
  'Cannot predict now.',
  'Concentrate and ask again.',
  "Don't count on it.",
  'My reply is no.',
  'My sources say no.',
  'Outlook not so good.',
  'Very doubtful.'
];
final random = Random();

class EightBallTab extends StatefulWidget {
  const EightBallTab({Key? key}) : super(key: key);

  @override
  _EightBallTabState createState() => _EightBallTabState();
}

class _EightBallTabState extends State<EightBallTab> {
  String answer = "What do you want to know ?";
  final questionNotifier = ValueNotifier(0);
  final answerNotifier = ValueNotifier(0);
  final questionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
            valueListenable: questionNotifier,
            builder: (context, value, child) {
              if (questionController.text.isEmpty) return Container();

              String question = questionController.text;
              if (question[question.length - 1] != "?") question += " ?";

              return QuestionText(
                  question: question,
                  onShowed: () {
                    answer = answers[random.nextInt(answers.length)];
                    answerNotifier.value++;
                  });
            }),
        Expanded(
          flex: 6,
          child: Container(
              alignment: Alignment.center,
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.white,
                        Colors.black,
                        Colors.black,
                        Colors.black
                      ]),
                  shape: BoxShape.circle),
              child: Container(
                width: 200,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 5),
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.blue[400]!,
                          Colors.blue[800]!,
                          Colors.blue[400]!
                        ]),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: ValueListenableBuilder(
                    valueListenable: answerNotifier,
                    builder: (context, value, child) =>
                        AnswerText(answer: answer)),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              SizedBox(
                width: 25,
              ),
              Flexible(
                  child: TextField(
                      controller: questionController,
                      maxLength: 40,
                      decoration: InputDecoration(
                        hintText: "Type your question",
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2)),
                      ))),
              SizedBox(
                width: 5,
              ),
              ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    questionNotifier.value++;
                  },
                  child: Icon(Icons.add)),
              SizedBox(
                width: 20,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class AnswerText extends StatefulWidget {
  final String answer;
  const AnswerText({Key? key, this.answer = ""}) : super(key: key);

  @override
  State<AnswerText> createState() => _AnswerTextState();
}

class _AnswerTextState extends State<AnswerText> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = calculateTextWidth(this.widget.answer, 20, context);

    Animation<double> textAnim1 =
        Tween<double>(begin: -width, end: 200).animate(_controller
          ..reset()
          ..repeat());

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: textAnim1.value,
              child: Text(this.widget.answer,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  overflow: TextOverflow.clip,
                  maxLines: 1),
            )
          ],
        );
      },
    );
  }

  static double calculateTextWidth(
      String value, double fontSize, BuildContext context) {
    TextPainter painter = TextPainter(
        locale: Localizations.localeOf(context),
        maxLines: 1,
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: value,
            style: TextStyle(
              fontSize: fontSize,
            )));
    painter.layout(maxWidth: 300);

    return painter.width;
  }
}

class QuestionText extends StatefulWidget {
  final VoidCallback? onShowed;
  final String question;
  const QuestionText({Key? key, this.question = "", this.onShowed})
      : super(key: key);

  @override
  _QuestionTextState createState() => _QuestionTextState();
}

class _QuestionTextState extends State<QuestionText>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        this.widget.onShowed!();
      }
    });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Animation textAnim = StepTween(begin: 0, end: this.widget.question.length)
        .animate(_controller
          ..reset()
          ..forward());

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return AutoSizeText(this.widget.question.substring(0, textAnim.value),
            maxLines: 3,
            style: TextStyle(fontSize: 40),
            textAlign: TextAlign.center);
      },
    );
  }
}
