import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'credits.dart';
import 'drawer.dart';
import 'drawer_state.dart';
import 'questions_set.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

const questionsFolder = "assets/questions/";

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: 'Memory - Trova le coppie',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;

  const MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer audioPlayerMusic = AudioPlayer();
  AudioPlayer audioPlayerSounds = AudioPlayer();

  QuestionSet? questionSet;

  List<int> selectedIndices = [];
  List<int> correctIndices = [];

  bool chooseGameDialogOn = false;

  _MyHomePageState();

  @override
  Widget build(BuildContext context) {
    if (questionSet == null && chooseGameDialogOn == false) {
      print("no questions");
      Future.delayed(
          const Duration(milliseconds: 300), () => chooseGameDialog(context));
    }
    return ChangeNotifierProvider(
        create: (context) => DrawerModel(),
        child: Consumer<DrawerModel>(builder: (context, drawerModel, child) {
          return Scaffold(
              appBar: AppBar(
                title: Text(widget.title!),
              ),
              drawer: buildDrawer(context),
              body: Center(
                    child: OrientationBuilder(builder: (context, orientation) {
                  if (drawerModel.getSelectedItem() == "credits") {
                    return const CreditsPage();
                  }
                  return questionSet != null
                      ? buildGameScaffold()
                      : Container();
                }
                )
          )
          );
              }));
  }

  Widget buildGameScaffold() {
    int cellCount = questionSet!.answers.length;
            return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return GridView.extent(
                    maxCrossAxisExtent: sqrt(
                        constraints.maxWidth * constraints.maxHeight /
                            cellCount),
                    padding: EdgeInsets.only(
                        bottom: constraints.maxHeight / 20),
                    children: List.generate(cellCount, (index) {
                      Answer? currentAnswer = questionSet!.answers.elementAt(
                          index);
                      return LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Padding(
                          padding: EdgeInsets.all(constraints.maxWidth / 10),
                          child: GestureDetector(
                            onTap: () => _select(index),
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(constraints.maxWidth / 10),
                              child: Stack(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    color: Colors.white,
                                    child: currentAnswer.type == "image"
                                        ? Image(
                                        image: AssetImage("images/" +
                                            currentAnswer.value.toString()))
                                        : AutoSizeText(
                                      currentAnswer.value.toString(),
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 100,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // Mark correct tiles
                                  if (correctIndices.contains(index))
                                    Container(
                                      alignment: Alignment.center,
                                      color: Colors.green.withOpacity(0.5),
                                    ),

                                  // Cover numbers which have not yet be found
                                  if (!correctIndices.contains(index) &&
                                      !selectedIndices.contains(index))
                                    Container(
                                      alignment: Alignment.center,
                                      color: Colors.grey,
                                      child: const AutoSizeText(
                                        '?',
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 100,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    }),
                  );
                })
    ;
                }

  chooseGameDialog(BuildContext context) async {
    print("chooseGameDialog");
    setState(() {
      chooseGameDialogOn = true;
    });
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Center(child: Text("Scegli il tipo di gioco")),
        titleTextStyle: const TextStyle(fontSize: 40),
        // content: Text("You stepped on a mine. Be careful next time."),
        actions: [
          createChooseGameButton('images/dado-5.png', "dice.json"),
          createChooseGameButton('images/clock10_40.png', "clocks.json"),
        ],
      ),
    );
  }

  Widget createChooseGameButton(String iconFileName, String jsonFileName) {
    return IconButton(
      icon: Image.asset(iconFileName),
      iconSize: 200,
      onPressed: () {
        setState(() {
          // see https://www.oliverboorman.biz/projects/tools/clocks.php
          readJson(questionsFolder + jsonFileName);
          chooseGameDialogOn = false;
          if (audioPlayerMusic.state != PlayerState.PLAYING) {
            audioPlayerMusic.resume();
          }
        });
        print("close");
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  initState() {
    super.initState();
    audioPlayerMusic
        .setUrl('assets/sounds/608624_bloodpixelhero_marvelous-gift.mp3');
    audioPlayerMusic.setReleaseMode(ReleaseMode.LOOP);
    audioPlayerMusic.setVolume(0.5);
  }

  playLocal(String localPath, double volume) async {
    int result =
        await audioPlayerSounds.play(localPath, isLocal: true, volume: volume);
  }

  Future<void> readJson(String jsonLocation) async {
    final String jsonString = await rootBundle.loadString(jsonLocation);
    setState(() {
      questionSet = questionSetFromJson(jsonString);

      _reset();
    });
  }

  void _checkFinishedGame() async {
    if (questionSet!.answers.length == correctIndices.length) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Center(child: Text("Hai vinto!")),
          titleTextStyle: const TextStyle(fontSize: 40),
          // content: Text("You stepped on a mine. Be careful next time."),
          actions: [
            MaterialButton(
              color: Colors.orangeAccent,
              onPressed: () {
                setState(() {
                  questionSet = null;
                });
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Cambia Gioco",
                style: TextStyle(fontSize: 25),
              ),
            ),
            MaterialButton(
              color: Colors.lightGreenAccent,
              onPressed: () {
                setState(() {
                  _reset();
                });
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Gioca di nuovo",
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      );
    }
  }

  bool _isRightMatch() {
    if (selectedIndices.length == 2) {
      bool isRightMatch = questionSet!.isRightMatch(selectedIndices);
      isRightMatch
          ? playLocal("assets/sounds/439211__javapimp__kara-ok.ogg", 1.0)
          : playLocal("assets/sounds/572936__bloodpixelhero__error.wav", 1.0);
      return isRightMatch;
    } else {
      return false;
    }
  }

  void _reset() {
    setState(() {
      questionSet!.shuffleAnswers();
      correctIndices.clear();
      selectedIndices.clear();
    });
  }

  void _select(int selected) {
    if (correctIndices.contains(selected) ||
        (selectedIndices.contains(selected)) && selectedIndices.length < 2) {
      return;
    }
    setState(() {
      if (selectedIndices.length >= 2) {
        selectedIndices.clear();
      }
      selectedIndices.add(selected);
      if (_isRightMatch()) {
        correctIndices.add(selectedIndices[0]);
        correctIndices.add(selectedIndices[1]);
      }
    });
    _checkFinishedGame();
  }
}
