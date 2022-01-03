import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'memory_game_state.dart';
import 'questions_set.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({Key? key}) : super(key: key);

  @override
  State<MemoryGame> createState() => _MyMemoryPageState();
}

class _MyMemoryPageState extends State<MemoryGame> {
  AudioPlayer audioPlayerMusic = AudioPlayer();
  AudioPlayer audioPlayerSounds = AudioPlayer();

  bool chooseGameDialogOn = false;

  _MyMemoryPageState();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Consumer<MemoryGameState>(builder: (context, memoryGameState, child) {
        int cellCount = memoryGameState.questionSet.answers.length;
        return GridView.extent(
          maxCrossAxisExtent:
              sqrt(constraints.maxWidth * constraints.maxHeight / cellCount),
          padding: EdgeInsets.only(bottom: constraints.maxHeight / 20),
          children: List.generate(cellCount, (index) {
            Answer? currentAnswer = memoryGameState.questionSet.answers.elementAt(index);
            return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return Padding(
                padding: EdgeInsets.all(constraints.maxWidth / 10),
                child: GestureDetector(
                  onTap: () => _tapTile(index, memoryGameState),
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
                        if (memoryGameState.correctIndices.contains(index))
                          Container(
                            alignment: Alignment.center,
                            color: Colors.green.withOpacity(0.5),
                          ),

                        // Cover numbers which have not yet be found
                        if (!memoryGameState.correctIndices.contains(index) &&
                            !memoryGameState.selectedIndices.contains(index))
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
      });
    });
  }

  _tapTile(int index, MemoryGameState memoryGameState){
    memoryGameState.select(index);
    if(memoryGameState.isGameFinished()){
      _showEndGameDialog(memoryGameState);
    }
  }


  playLocal(String localPath, double volume) async {
    int result =
        await audioPlayerSounds.play(localPath, isLocal: true, volume: volume);
  }

  void _showEndGameDialog(MemoryGameState memoryGameState) async {
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
                  memoryGameState.reset(false);
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
                  memoryGameState.reset(true);
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
