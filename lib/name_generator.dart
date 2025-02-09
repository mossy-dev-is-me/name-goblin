// name_generator.dart
import 'data.dart'; // For Race and Name classes
import 'markov_name_generator.dart'; // For MarkovNameGenerator

final MarkovNameGenerator _markovNameGenerator = MarkovNameGenerator();

Future<void> initializeNameGenerator() async {
  await _markovNameGenerator.initialize();
}

Name generateRaceName(Race race, String gender) {
  final String name = _markovNameGenerator.generateName(race.name, gender);
  return Name(name: name, gender: gender, race: race);
}
