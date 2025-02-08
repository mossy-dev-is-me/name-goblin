import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'NAME GOBLIN',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String current = '';
  List<String> history = <String>[];
  GlobalKey? historyListKey;
  int raceKey = 0;
  List<({String name, String iconImage})> races = [
    (name: "Goblin", iconImage: "assets/goblin.png"),
    (name: "Orc", iconImage: "assets/orc.png"),
    (name: "Human", iconImage: "assets/human.png"),
  ];

  MyAppState() {
    generateNewName();
  }

  void generateNewName() {
    current = generateRaceName(races[raceKey].name);
    notifyListeners();
  }

  String generateRaceName(String race) {
    final random = Random();

    Map<String, List<String>> nameParts = {
      "Goblin": ["Giz", "Snag", "Blix", "Grub", "Zig"],
      "Orc": ["Gor", "Brak", "Thok", "Urg", "Krag"],
      "Human": ["John", "Arthur", "William", "Henry", "Robert"],
    };

    Map<String, List<String>> suffixes = {
      "Goblin": ["nob", "bix", "zag", "tix", "muk"],
      "Orc": ["mok", "thar", "gar", "gul", "drak"],
      "Human": ["son", "man", "ford", "ley", "ton"],
    };

    var firstPart =
        nameParts[race]?[random.nextInt(nameParts[race]!.length)] ?? "Nameless";
    var secondPart =
        suffixes[race]?[random.nextInt(suffixes[race]!.length)] ?? "One";

    return "$firstPart$secondPart";
  }

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);

    generateNewName();
    notifyListeners();
  }

  var favorites = <String>[];
  void toggleFavorite({String? pair}) {
    final String target = pair ?? current;
    if (favorites.contains(target)) {
      favorites.remove(target);
    } else {
      favorites.add(target);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        Expanded(
          // Make better use of wide windows with a grid.
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.toggleFavorite(pair: pair);
                    },
                  ),
                  title: Text(
                    pair.toLowerCase(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HistoryListView(),
          RaceSelector(),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Favorite'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Generate'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    // This gradient goes from fully transparent to fully opaque black...
    colors: [Colors.transparent, Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return Expanded(
      flex: 3,
      child: ShaderMask(
          shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: AnimatedList(
              key: _key,
              reverse: true,
              padding: EdgeInsets.only(top: 100),
              initialItemCount: appState.history.length,
              itemBuilder: (context, index, animation) {
                final pair = appState.history[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        appState.toggleFavorite(pair: pair);
                      },
                      icon: appState.favorites.contains(pair)
                          ? Icon(Icons.favorite, size: 12)
                          : SizedBox(),
                      label: Text(
                        pair.toLowerCase(),
                      ),
                    ),
                  ),
                );
              })),
    );
  }
}

class RaceSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    return DropdownButtonHideUnderline(
        child: DropdownButton<int>(
      value: appState.raceKey,
      items: List.generate(appState.races.length, (index) {
        return DropdownMenuItem<int>(
          value: index,
          child: Text(appState.races[index].name),
        );
      }),
      onChanged: (int? newIndex) {
        if (newIndex != null) {
          appState.raceKey = newIndex;
          appState.generateNewName();
        }
      },
    ));
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final String pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.toUpperCase(),
          style: style,
        ),
      ),
    );
  }
}
