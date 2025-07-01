import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './db/db.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Flutterアプリで非同期処理（async/await）やプラットフォームチャネルを使う前に、Flutterエンジンとウィジェットバインディングを初期化するためのものです。
  await DBHelper.init(); //DBHelperの初期化を待つ

  const scope = ProviderScope(child: File()); //RiverpodのProviderScopeを作成
  runApp(scope);
}

// アプリのエントリーポイント file home

void gocode(BuildContext context, int id) {
  // ここでファイルを開く処理を実装
  // idを使ってDBからファイルの内容を取得し、表示するなどの処理を行う
  print('ファイルID: $id を開きます');
  context.push('/code?id=$id'); // ここでファイルを開く処理を実装
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
      controller: inputController,
      decoration: InputDecoration(
        labelText: 'タイトルを入力',
        prefixIcon: Icon(Icons.edit, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.deepPurple.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
      style: TextStyle(fontSize: 18),
    );

    final butoon = SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await DBHelper.insertFile(inputController.text);
          ref.refresh(fileProvider);
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '追加',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          shadowColor: Colors.deepPurpleAccent,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );

    final alll = Column(children: []); //DBからもらったやつをどうやって入れよう

    final col = Column(
      children: [
        input,
        SizedBox(height: 16),
        butoon,
        SizedBox(height: 24),
        fileList.when(
          data: (files) => files != null && files.isNotEmpty
              ? SizedBox(
                  height: 400, // 必要に応じて高さを調整
                  child: ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      if (file == null) return SizedBox.shrink();
                      return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.folder, color: Colors.deepPurple),
                          title: Text(
                            'タイトル: ${file['title']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            gocode(context, file['id']);
                          },
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                        ),
                      );
                    },
                  ),
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
