import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './db/db.dart';
import 'package:go_router/go_router.dart';
import './file.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.init(); //DBHelperの初期化を待つ

  const scope = ProviderScope(child: Code()); //RiverpodのProviderScopeを作成
  runApp(scope);
}

// アプリのエントリーポイント file home

void gocode(BuildContext context, int id) {
  // ここでファイルを開く処理を実装
  // idを使ってDBからファイルの内容を取得し、表示するなどの処理を行う
  print('コードID: $id を開きます');
  context.push('/onecode?id=$id');
}

//  const Code({super.key,this.id});によってProviderScope(child: Code(id));ができるようになる
class Code extends StatelessWidget {
  final int? id; // idを受け取るためのコンストラクタ引数を追加
  const Code({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'code App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Codepage(id: id),
    );
  }
}

/*
ここまでのサマリ
runappの定義
gocode関数
MaterialAppの定義
*/

//以降からカスタム

final fileProvider = FutureProvider.family<List<Map<String, dynamic>?>, int>((
  ref,
  id,
) async {
  if (id == null) return [];
  return DBHelper.getCode(id);
});

class Codepage extends ConsumerWidget {
  final int? id; // idを受け取るためのコンストラクタ引数を追加
  const Codepage({super.key, this.id});

  @override //変数!でnullを許容しないことを示す
  Widget build(BuildContext context, WidgetRef ref) {
    final fileList = ref.watch(fileProvider(id!));

    // コントローラ

    final input2Controller = TextEditingController(); // 入力フィールドのコントローラーを作成
    final input2 = TextField(
      controller: input2Controller,
      decoration: InputDecoration(
        labelText: 'コードタイトルを入力',
        border: OutlineInputBorder(),
      ),
    );

    final inputController = TextEditingController();

    final input = SizedBox(
      height: 200,
      child: TextField(
        maxLines: null, // 複数行入力を可能にする
        expands: true, // 入力フィールドの高さを自動調整
        controller: inputController,
        decoration: InputDecoration(
          labelText: 'コードを入力',
          border: OutlineInputBorder(),
        ),
        scrollPhysics: BouncingScrollPhysics(),
      ),
    );

    final butoon = ElevatedButton(
      onPressed: () async {
        await DBHelper.insertCode(
          inputController.text,
          id!,
          input2Controller.text,
        );

        ref.refresh(fileProvider(id!));
      },
      child: Text('追加'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 83, 83, 83),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    final butoon1 = ElevatedButton(
      onPressed: () async {
        await DBHelper.deleteFile(id!); // idを使ってコードを削除
        // ref.refresh(fileProvider);
        ref.refresh(fileProvider(id!)); // データを更新するためにプロバイダーをリフレッシュ

        context.go('/'); // 前の画面に戻る
      },
      child: Text('フォルダを消去'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 83, 83, 83),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    final alll = Column(children: []);
    final row = Row(
      children: [
        ElevatedButton(
          onPressed: () {
            context.pop(); // ここでファイルを開く処理を実装
          },
          child: Text('戻る'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 83, 83, 83),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        butoon1,
      ],
    );

    final col = Column(
      children: [
        row,
        input2,
        input,
        butoon,
        fileList.when(
          data: (files) => files != null && files.isNotEmpty
              ? SizedBox(
                  height: 200, // 必要に応じて高さを調整
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
                          leading: Icon(
                            Icons.description,
                            color: Colors.deepPurple,
                          ),
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

/*
ここまでのサマリ
プロバイダ定義
Codepage　ウィジェット{
ボタン(コントローラ使用)
input(コントローラ使用)
fileListの取得(DB取得の表示)
}

*/

/*
memo
goルーターではmain.dartのrunAppだけを入れる。idを引数として
!はnullを許容しないことを示す。
?はnullを許容することを示す。

引数ありの場合this.idを追加
input+ボタンはコントローラでつなげるだけ
*/
