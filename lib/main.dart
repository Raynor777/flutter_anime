import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const FlappyAnimeApp());
}

class FlappyAnimeApp extends StatelessWidget {
  const FlappyAnimeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Anime',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FlappyGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FlappyGame extends StatefulWidget {
  const FlappyGame({Key? key}) : super(key: key);

  @override
  State<FlappyGame> createState() => _FlappyGameState();
}

class _FlappyGameState extends State<FlappyGame> {
  // 游戏参数
  static const double gravity = 2.5;
  static const double jump = -30;
  static const double characterWidth = 60;
  static const double characterHeight = 60;
  static const double pipeWidth = 60;
  static const double gap = 180;
  static const double pipeSpeed = 4;

  // 网络图片
  final String characterUrl = 'https://img1.imgtp.com/2023/07/21/8QwQw6Qe.png'; // 二次元人物
  final String pipeUrl = 'https://img.icons8.com/color/96/000000/pipe.png'; // 障碍物

  double characterY = 0;
  double velocity = 0;
  bool isGameStarted = false;
  bool isGameOver = false;
  int score = 0;

  // 障碍物
  List<Pipe> pipes = [];
  Random random = Random();
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void startGame() {
    isGameStarted = true;
    isGameOver = false;
    score = 0;
    characterY = MediaQuery.of(context).size.height / 2 - characterHeight;
    velocity = 0;
    pipes = [
      Pipe(
        x: MediaQuery.of(context).size.width + 100,
        gapY: randomGapY(),
      ),
    ];
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateGame();
    });
  }

  void resetGame() {
    isGameStarted = false;
    isGameOver = false;
    score = 0;
    characterY = MediaQuery.of(context).size.height / 2 - characterHeight;
    velocity = 0;
    pipes = [
      Pipe(
        x: MediaQuery.of(context).size.width + 100,
        gapY: randomGapY(),
      ),
    ];
    setState(() {});
  }

  double randomGapY() {
    double screenHeight = MediaQuery.of(context).size.height;
    return random.nextDouble() * (screenHeight - gap - 100) + 50;
  }

  void updateGame() {
    setState(() {
      // 角色下落
      velocity += gravity;
      characterY += velocity;

      // 障碍物移动
      for (var pipe in pipes) {
        pipe.x -= pipeSpeed;
      }

      // 新障碍物
      if (pipes.isNotEmpty && pipes.last.x < MediaQuery.of(context).size.width - 200) {
        pipes.add(Pipe(
          x: MediaQuery.of(context).size.width + 100,
          gapY: randomGapY(),
        ));
      }

      // 移除越界障碍物
      if (pipes.isNotEmpty && pipes.first.x < -pipeWidth) {
        pipes.removeAt(0);
        score++;
      }

      // 碰撞检测
      for (var pipe in pipes) {
        if (pipe.x < 100 + characterWidth && pipe.x + pipeWidth > 100) {
          // 上管
          if (characterY < pipe.gapY || characterY + characterHeight > pipe.gapY + gap) {
            gameOver();
            return;
          }
        }
      }

      // 地面/天花板
      if (characterY < 0 || characterY + characterHeight > MediaQuery.of(context).size.height) {
        gameOver();
        return;
      }
    });
  }

  void jumpAction() {
    if (!isGameStarted) {
      startGame();
    }
    if (!isGameOver) {
      setState(() {
        velocity = jump;
      });
    }
  }

  void gameOver() {
    isGameOver = true;
    isGameStarted = false;
    gameTimer?.cancel();
    setState(() {});
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: jumpAction,
      child: Scaffold(
        backgroundColor: Colors.lightBlue[100],
        body: Stack(
          children: [
            // 障碍物
            ...pipes.map((pipe) {
              return Stack(
                children: [
                  // 上管
                  Positioned(
                    left: pipe.x,
                    top: 0,
                    child: Image.network(
                      pipeUrl,
                      width: pipeWidth,
                      height: pipe.gapY,
                      fit: BoxFit.fill,
                    ),
                  ),
                  // 下管
                  Positioned(
                    left: pipe.x,
                    top: pipe.gapY + gap,
                    child: Image.network(
                      pipeUrl,
                      width: pipeWidth,
                      height: screenHeight - pipe.gapY - gap,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              );
            }).toList(),
            // 角色
            Positioned(
              left: 100,
              top: characterY,
              child: Image.network(
                characterUrl,
                width: characterWidth,
                height: characterHeight,
                fit: BoxFit.cover,
              ),
            ),
            // 分数
            Positioned(
              top: 60,
              left: screenWidth / 2 - 40,
              child: Text(
                '分数: $score',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  shadows: [Shadow(blurRadius: 4, color: Colors.white, offset: Offset(2, 2))],
                ),
              ),
            ),
            // 开始/结束提示
            if (!isGameStarted && !isGameOver)
              Center(
                child: Text(
                  '点击屏幕开始',
                  style: TextStyle(fontSize: 32, color: Colors.black.withOpacity(0.7)),
                ),
              ),
            if (isGameOver)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '游戏结束',
                      style: TextStyle(fontSize: 40, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '分数: $score',
                      style: const TextStyle(fontSize: 28, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: resetGame,
                      child: const Text('重新开始'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Pipe {
  double x;
  double gapY;
  Pipe({required this.x, required this.gapY});
} 