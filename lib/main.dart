import 'package:flutter/material.dart';
import './db/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Flutterアプリで非同期処理（async/await）やプラットフォームチャネルを使う前に、Flutterエンジンとウィジェットバインディングを初期化するためのものです。
  await DBHelper.init(); //DBHelperの初期化を待つ
  runApp(const File());
}

// アプリのエントリーポイント file home
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
      onPressed: () async {
        await DBHelper.insertFile('新しいコードファイル'); //staticメソッドなのでDBHelper.で呼び出す.
        // データ追加後に画面を更新したい場合はStatefulWidgetにしてsetStateする必要あり
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
    // ここでDBからデータを取得して表示する処理を実行

    final col = Column(
      children: [
        butoon,
        FutureBuilder<Map<String, dynamic>?>(
          // 非同期処理の結果を待つ
          // DBからIDが1のファイルを取得する
          // ここでは例としてIDが1のファイルを取得していますが、実際には動的にIDを指定する必要があります。
          // 例えば、リストから選択したファイルのIDを使うなど
          future: DBHelper.getFileById(1),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('エラー: ${snapshot.error}');
            }
            final file = snapshot.data;
            if (file == null) {
              return Text('データがありません');
            }
            return Text('タイトル: ${file['title']}');
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('code管理アプリ')),
      body: Center(child: col),
    );
  }
}

// ここにDBからもらったやつを繰り返し入れるとそれを開くと名前表示にすると、実行したいコードはどこに入れるか、関数でflie１に飛ぶときのクエリみたいな処理はどうするか
