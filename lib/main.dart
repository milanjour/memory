import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'credits.dart';
import 'drawer.dart';
import 'drawer_state.dart';
import 'memory_game.dart';
import 'memory_game_state.dart';
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

  bool chooseGameDialogOn = false;

  _MyHomePageState();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DrawerModel>(
          create: (context) => DrawerModel(),
        ),
        ChangeNotifierProvider<MemoryGameState>(
          create: (context) => MemoryGameState(),
        ),
      ],
      child:
          Consumer<MemoryGameState>(builder: (context, memoryGameState, child) {
        return Consumer<DrawerModel>(builder: (context, drawerModel, child) {
          if (memoryGameState.questionSet.questions.isEmpty &&
              chooseGameDialogOn == false) {
            print("no questions");
            Future.delayed(const Duration(milliseconds: 300),
                () => chooseGameDialog(context, memoryGameState));
          }
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
                return memoryGameState.questionSet.questions.isNotEmpty
                    ? const MemoryGame()
                    : Container();
              })));
        });
      }),
    );
  }

  chooseGameDialog(
      BuildContext context, MemoryGameState memoryGameState) async {
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
          createChooseGameButton(
              'images/dado-5.png', "dice.json", memoryGameState),
          createChooseGameButton(
              'images/clock10_40.png', "clocks.json", memoryGameState),
        ],
      ),
    );
  }

  Widget createChooseGameButton(String iconFileName, String jsonFileName,
      MemoryGameState memoryGameState) {
    return IconButton(
      icon: Image.asset(iconFileName),
      iconSize: 200,
      onPressed: () {
        setState(() {
          // see https://www.oliverboorman.biz/projects/tools/clocks.php
          readJson(questionsFolder + jsonFileName, memoryGameState);
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

  Future<void> readJson(
      String jsonLocation, MemoryGameState memoryGameState) async {
    final String jsonString = await rootBundle.loadString(jsonLocation);
    setState(() {
      QuestionSet questionSet = questionSetFromJson(jsonString);
      memoryGameState.questionSet = questionSet;
    });
  }
}
