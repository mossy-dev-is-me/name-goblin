import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'data.dart';
import 'name_generator.dart';

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
  List<Name> history = <Name>[];
  GlobalKey? historyListKey;
  int raceKey = 0;
  String gender = 'Male';
  Name current;

  MyAppState() : current = Name(name: '', gender: '', race: races[0]) {
    _initialize();
  }

  Future<void> _initialize() async {
    generateNewName(); // Generate the first name after initialization
  }

  void generateNewName() {
    current = generateRaceName(races[raceKey], gender);
    notifyListeners();
  }

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);

    generateNewName();
    notifyListeners();
  }

  var favorites = <Name>[];
  void toggleFavorite({Name? name}) {
    final Name target = name ?? current;
    if (favorites.contains(target)) {
      favorites.remove(target);
    } else {
      favorites.add(target);
    }
    notifyListeners();
  }

  void toggleGender(String gender) {
    this.gender = gender;
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show the main content once initialization is complete
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
            labelType: NavigationRailLabelType.all,
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
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: _getPage(selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return GeneratorPage();
      case 1:
        return FavoritePage();
      default:
        throw UnimplementedError('no widget for $index');
    }
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
              for (var name in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.toggleFavorite(name: name);
                    },
                  ),
                  title: Text(
                    name.name.toLowerCase(),
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
    var currentName = appState.current;

    IconData icon;
    if (appState.favorites.contains(currentName)) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.male,
                    color:
                        appState.gender == 'Male' ? Colors.blue : Colors.grey),
                onPressed: () {
                  appState.toggleGender('Male');
                },
              ),
              IconButton(
                icon: Icon(Icons.female,
                    color: appState.gender == 'Female'
                        ? Colors.pink
                        : Colors.grey),
                onPressed: () {
                  appState.toggleGender('Female');
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          BigCard(raceName: currentName),
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
                final raceName = appState.history[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          raceName.race.imagePath, // Path to the image
                          width: 24, // Set the width of the image
                          height: 24, // Set the height of the image
                        ),
                        SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            appState.toggleFavorite(name: raceName);
                          },
                          icon: appState.favorites.contains(raceName)
                              ? Icon(Icons.favorite, size: 12)
                              : SizedBox(),
                          label: Text(
                            raceName.name.toLowerCase(),
                          ),
                        ),
                      ],
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
      items: List.generate(races.length, (index) {
        return DropdownMenuItem<int>(
          value: index,
          child: Row(
            children: [
              Image.asset(
                races[index].imagePath, // Path to the image
                width: 24, // Set the width of the image
                height: 24, // Set the height of the image
              ),
              SizedBox(width: 8),
              Text(races[index].name),
            ],
          ),
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
    required this.raceName,
  });

  final Name raceName;

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
          raceName.name.toUpperCase(),
          style: style,
        ),
      ),
    );
  }
}
