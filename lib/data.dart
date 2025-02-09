// races.dart

class Race {
  final String name;
  final String imagePath;

  Race({
    required this.name,
    required this.imagePath,
  });
}

class Name {
  final String name;
  final String gender;
  final Race race;

  Name({
    required this.name,
    required this.gender,
    required this.race,
  });
}

// List of races with files
final List<Race> races = [
  // Race(name: 'Elf', imagePath: '🧝'),
  // Race(name: 'Dwarf', imagePath: '🧔'),
  Race(name: 'Human', imagePath: 'assets/images/human.png'),
  Race(name: 'Orc', imagePath: 'assets/images/orc.png'),
  Race(name: 'Goblin', imagePath: 'assets/images/goblin.png'),
  // Add more races as needed
];
