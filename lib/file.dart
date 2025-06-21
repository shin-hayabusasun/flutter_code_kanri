import 'package:flutter/material.dart';

void main() {
  runApp(const File());
}

class File extends StatelessWidget {
  const File({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'code App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Filepage(),
    );
  }
}

class Filepage extends StatelessWidget {
  const Filepage({super.key});

  @override
  Widget build(BuildContext context) {
    final butoon = ElevatedButton(
      onPressed: () {
        print('Button clicked!'); //飛ぶ
      },
      child: Text('追加'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 83, 83, 83),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    final alll = Column(children: []); //DBからもらったやつをどうやって入れよう

    final col = Column(children: [butoon, alll]);

    return Scaffold(
      appBar: AppBar(title: Text('code管理アプリ')),
      body: Center(child: col),
    );
  }
}

// ここにDBからもらったやつを繰り返し入れるとそれを開くと名前表示にすると、実行したいコードはどこに入れるか、関数でflie１に飛ぶときのクエリみたいな処理はどうするか
