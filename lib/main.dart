import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

// 以下で定義されるクラスのインスタンスが不変であり、一度作成すると変更できないことを示すために使用されます。
// これは、アプリケーションの状態が誤って変更されないようにするのに役立ちます。
// BLoC 内のすべてのイベントの基本クラスとして使用される ColorEvent という抽象クラスを定義します。
@immutable
abstract class ColorEvent {}

// 3 つのクラス (InitialEvent、ColorToBlue、および ColorToRed) は、ColorEvent クラスを拡張する具象クラスです。
// これらは、状態変更をトリガーするために BLoC に送信できるさまざまなタイプのイベントを表します。
// InitialEvent クラスは、BLoC が最初に作成されたときに BLoC に送信される初期イベントを表します。
class InitialEvent extends ColorEvent {
  InitialEvent();
}

// ColorToBlue クラスと ColorToRed クラスは、アプリケーションの色の状態を変更するために BLoC に送信できるイベントを表します。
// これらには、色をそれぞれ青または赤に変更する必要があるという事実以外の追加情報は含まれません。
class ColorToBlue extends ColorEvent {
  ColorToBlue();
}

class ColorToRed extends ColorEvent {
  ColorToRed();
}

// ブロック内のすべての状態の基本クラスとして使用される ColorState という抽象クラスを定義します
@immutable
abstract class ColorState {}

// ColorInitial クラスは、ブロックの初期状態を表します。
// ブロックが作成されたばかりで、まだイベントを受け取っていないことを示すために使用されます。
class ColorInitial extends ColorState {}

// ColorUpdateState クラスは、アプリケーションの色が更新された状態を表します。
// 色の現在の状態を示す、initialState と呼ばれるブール値が含まれています。
class ColorUpdateState extends ColorState {
  bool? initialState;

  // オプションの initialState パラメーターを取る名前付きコンストラクターもあります。
  // このコンストラクターを使用すると、指定された initialState 値を持つ ColorUpdateState クラスの新しいインスタンスを作成できます。
  ColorUpdateState({
    this.initialState,
  });
}

// イベントを処理し、アプリケーションの状態を更新する Bloc クラスを定義します。
// ColorBloc クラスは、ColorEvent と ColorState という 2 つの型パラメータを取ります。
// これらは、それぞれ、ブロックに送信できるイベントとブロックによって発行できる状態を表します。
class ColorBloc extends Bloc<ColorEvent, ColorState> {
  bool initState = true;
  // ブロックの初期状態を ColorInitial() に
  ColorBloc() : super(ColorInitial()) { // 特定の初期状態を明示的に設定する必要がある場合にのみ使用
    on<ColorEvent>((event, emit) {
      //Implement an event handler
    });
    on<InitialEvent>((event, emit) {
      //  implement event handler
      emit(ColorUpdateState(initialState: initState));
    });

    // ColorToBlue イベントを受信すると、initialState フィールドが true に設定された ColorUpdateState 状態が発行
    on<ColorToBlue>((event, emit) {
      //implement event handler
      initState = true;
      emit(ColorUpdateState(initialState: initState));
    });

    // ColorToRed イベントが受信されると、initialState フィールドが false に設定された ColorUpdateState 状態が発行
    on<ColorToRed>((event, emit) {
      initState = false;
      emit(ColorUpdateState(initialState: initState));
    });
  }
}

// ウィジェット ツリーで ColorBloc を使用するには、BlocProvider ウィジェットでそれをラップする必要があります。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // MaterialApp ウィジェットを BlocProvider ウィジェットでラップ
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//Wrap with the BlocProvider widget
      home:
      BlocProvider(create: (_) => ColorBloc(), child: const ColorScreen()),
    );
  }
}

// BlocProvider は、bloc パッケージによって提供されるウィジェットです。
// これは、Bloc インスタンスをウィジェットのサブツリーに提供するために使用され、そのサブツリー内のすべてのウィジェットで使用できるようにします。
class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    context.read<ColorBloc>().add(InitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('colorz'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<ColorBloc, ColorState>(
            builder: (context, state) {
              if (state is ColorUpdateState ) {
                return Container(
                    width: 200,
                    height: 200,
                    color: state.initialState == true ? Colors.blue : Colors.red
                );
              }
              return Container(
                width: 200,
                height: 200,
                color: Colors.blue
              );
            },
          ),
          SizedBox(
            height: 20,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () =>
                    context.read<ColorBloc>().add(ColorToBlue()),
                child: Container(
                  width: 50,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Center(child: Text('blue')),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () =>
                    context.read<ColorBloc>().add(ColorToRed()),
                child: Container(
                  width: 50,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                  child: Center(child: Text('red')),
                ),
              ),
            ],
          ),

          // BlocConsumer ウィジェットには、ビルダー関数とリスナー関数という 2 つのビルダー関数があります。
          // ビルダー関数は初期 UI を構築しますが、リスナー関数は BLoC の状態に変化があるたびに UI を更新する役割を果たします。
          /*
          BlocConsumer<ColorBloc, ColorState>(listener: (context, state) {
            print(state);
          }, builder: (context, state) {
            if (state is ColorUpdateState) {
              return Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    color: state.initialState == true ? Colors.blue : Colors.red,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            context.read<ColorBloc>().add(ColorToBlue()),
                        child: Container(
                          width: 50,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Center(child: Text('blue')),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.read<ColorBloc>().add(ColorToRed()),
                        child: Container(
                          width: 50,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.red,
                          ),
                          child: Center(child: Text('red')),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Container();
            }
          }),
          */
        ],
      ),
    );
  }
}


/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
*/