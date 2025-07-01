import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './db/db.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.init(); //DBHelperの初期化を待つ
  const id = 1; // ここでIDを指定するか、引数として受け取るように変更できます
  const scope = ProviderScope(
    child: OneCode(id: id),
  ); //RiverpodのProviderScopeを作成
  runApp(scope);
}

// アプリのエントリーポイント file home

void gocode(BuildContext context, int id) {
  // ここでファイルを開く処理を実装
  // idを使ってDBからファイルの内容を取得し、表示するなどの処理を行う
  print('ファイルID: $id を開きます');
}

//  const Code({super.key,this.id});によってProviderScope(child: Code(id));ができるようになる
class OneCode extends StatelessWidget {
  final int? id; // idを受け取るためのコンストラクタ引数を追加
  const OneCode({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'code App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: OneCodepage(id: id),
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

final fileProvider = FutureProvider.family<Map<String, dynamic>?, int>((
  ref,
  id,
) async {
  if (id == null) return null;
  return DBHelper.getOneCode(id);
});

class OneCodepage extends ConsumerWidget {
  final int? id; // idを受け取るためのコンストラクタ引数を追加
  const OneCodepage({super.key, this.id});

  @override //変数!でnullを許容しないことを示す
  Widget build(BuildContext context, WidgetRef ref) {
    final fileList = ref.watch(fileProvider(id!));

    final butoon = ElevatedButton(
      onPressed: () async {},
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
        await DBHelper.deleteCode(id!); // idを使ってコードを削除
        ref.refresh(fileProvider(id!)); // データを更新するためにプロバイダーをリフレッシュ
        context.go('/'); // 前の画面に戻る
      },
      child: Text('消去'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 83, 83, 83),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    final butoon2 = ElevatedButton(
      onPressed: () {
        context.pop(); // ここでファイルを開く処理を実装
      },
      child: Text('戻る'),
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
        Row(children: [butoon2, butoon1]),
        fileList.when(
          data: (data) {
            if (data == null) {
              return Text('データがありません');
            }
            return Column(
              children: [
                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: data['desprite'] ?? ''),
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('コードをコピーしました')));
                  },
                  icon: Icon(
                    Icons.copy,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  tooltip: 'コピー',
                ),
                Text('タイトル: ${data['title']}, コード: ${data['desprite']}'),
              ],
            );
          },
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => Text('エラー: $error'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('code管理アプリ')),
      body: Center(child: col),
    );
  }
}
