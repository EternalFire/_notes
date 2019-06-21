import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main()=>runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final wordPair = new WordPair.random();
    return new MaterialApp(
      title: 'Title 666',
      // home: new Scaffold(
      //   appBar: new AppBar(
      //     title: new Text('AppBar Title'),
      //     actions: <Widget>[
      //       new IconButton(icon: new Icon(Icons.list), onPressed: (){}),
      //     ],
      //   ),
      //   body: new Center(
      //     // child: new Text('Center Text')
      //     // child: new Text(wordPair.asPascalCase),
      //     child: new RandomWord(),
      //   ),
      // ),
      home:  new RandomWord(),
      theme: new ThemeData(
        primaryColor: Colors.deepOrange,
      )
    );
  }
}

class RandomWord extends StatefulWidget {
  @override
  _RandomWordState createState() => _RandomWordState();
}

class _RandomWordState extends State<RandomWord>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final _suggestions = <WordPair>[];
  final _saved = new Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  int _suggestionsMaxLength = 41;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final wordPair = new WordPair.random();
    // return Container(
    //   // child: new Text(wordPair.asPascalCase)
    //   child: _buildSuggestions()
    // );

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Random Word AppBar Title'),
          actions: <Widget>[
            new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved),
          ],
        ),
        body: new Center(
          child: _buildSuggestions(),
        ),
    );
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
      itemCount: _suggestionsMaxLength,
      padding: const EdgeInsets.all(16.0),
      // 对于每个建议的单词对都会调用一次itemBuilder，然后将单词对添加到ListTile行中
      // 在偶数行，该函数会为单词对添加一个ListTile row.
      // 在奇数行，该函数会添加一个分割线widget，来分隔相邻的词对。
      // 注意，在小屏幕上，分割线看起来可能比较吃力。
      itemBuilder: (context, i) {
        // 语法 "i ~/ 2" 表示i除以2，但返回值是整形（向下取整），比如i为：1, 2, 3, 4, 5
        // 时，结果为0, 1, 1, 2, 2， 这可以计算出ListView中减去分隔线后的实际单词对数量
        final index = i ~/ 2;
        print("item  $i  $index ");

        if (i >= _suggestionsMaxLength - 1) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.0),
            child: Text("没有更多了", style: TextStyle(color: Colors.grey),)
          );
        }

        // 在每一列之前，添加一个1像素高的分隔线widget
        if (i.isOdd) return new Divider();

        // 如果是建议列表中最后一个单词对
        if (index >= _suggestions.length) {
          // ...接着再生成10个单词对，然后添加到建议列表
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index], index);
      }
    );
  }

  Widget _buildRow(WordPair pair, index) {
    final alreadySaved = _saved.contains(pair);
    return new ListTile(
      title: new Text(
        "$index. ${pair.asPascalCase}",
        style: _biggerFont,
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  void _pushSaved(){
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          final tiles = _saved.map((pair) {
            return new ListTile(
              title: new Text(
                pair.asCamelCase,
                style: _biggerFont
              )
            );
          });

          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles
          ).toList();

          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Saved'),
            ),
            body: new ListView(
              children: divided,
            ),
          );
        },
      ),
    );
  }

}