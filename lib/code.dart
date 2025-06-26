import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './db/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Flutterアプリで非同期処理（async/await）やプラットフォームチャネルを使う前に、Flutterエンジンとウィジェットバインディングを初期化するためのものです。
  await DBHelper.init(); //DBHelperの初期化を待つ

  const scope = ProviderScope(child: File()); //RiverpodのProviderScopeを作成
  runApp(scope);
}

// アプリのエントリーポイント file home

void gocode(int id) {
  // ここでファイルを開く処理を実装
  // idを使ってDBからファイルの内容を取得し、表示するなどの処理を行う
  print('ファイルID: $id を開きます');
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

//プロバイダー DB用のプロバイダーを定義します。 ref.refresh(fileProvider); // を使うことで、DBのデータを更新できます。
final fileProvider = FutureProvider<List<Map<String, dynamic>?>>((ref) async {
  // DBからファイルのリストを取得する
  return DBHelper.getFiles();
});

class Filepage extends ConsumerWidget {
  const Filepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ConsumerWidgetを使うことで、Riverpodのプロバイダーを利用できます。(WidgetRef ref)
    final fileList = ref.watch(fileProvider); // fileProviderを監視して、ファイルのリストを取得

    // コントローラ

    final inputController = TextEditingController(); // 入力フィールドのコントローラーを作成
    final input = TextField(
      controller: inputController, // コントローラーを設定
      decoration: InputDecoration(
        labelText: 'コードを入力',
        border: OutlineInputBorder(),
      ),
    );

    final butoon = ElevatedButton(
      onPressed: () async {
        await DBHelper.insertFile(
          inputController.text,
        ); //staticメソッドなのでDBHelper.で呼び出す.

        ref.refresh(fileProvider); // データを更新するためにプロバイダーをリフレッシュ
        // ここでDBからデータを取得して表示する処理を実行
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

    final col = Column(
      children: [
        input,
        butoon,
        fileList.when(
          data: (files) => files != null && files.isNotEmpty
              ? Column(
                  children: files
                      .where((file) => file != null)
                      .map(
                        (file) => ElevatedButton(
                          onPressed: () {
                            gocode(file!['id']); // ファイルを開く処理を呼び出す
                          },
                          child: Text('タイトル: ${file!['title']}'),
                        ),
                      )
                      .toList(),
                )
              : Text('データなし'),
          loading: () => CircularProgressIndicator(),
          error: (e, _) => Text('エラー: $e'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('code管理アプリ')),
      body: Center(child: col),
    );
  }
}
