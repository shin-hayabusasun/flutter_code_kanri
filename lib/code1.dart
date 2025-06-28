import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './db/db.dart';
import 'package:go_router/go_router.dart';

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
  context.go('/onecode?id=$id');
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

    final inputController = TextEditingController();
    final input = TextField(
      controller: inputController,
      decoration: InputDecoration(
        labelText: 'コードを入力',
        border: OutlineInputBorder(),
      ),
    );

    final butoon = ElevatedButton(
      onPressed: () async {
        await DBHelper.insertCode(inputController.text, id!);

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

    final alll = Column(children: []);

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
                            gocode(context, file!['id']); // ファイルを開く処理を呼び出す
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
