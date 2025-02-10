// name_generator.dart
import 'dart:math';

import 'data.dart'; // For Race and Name classes

Name generateRaceName(Race race, String gender) {
  var name = 'sam';
  switch (race.name) {
    case 'Orc':
      name = generateOrcName(gender);
    case 'Goblin':
      name = 'Blok';
    case 'Human':
      name = generateHumanName(gender);
    default:
      throw Exception('Unknown race ${race.name}');
  }
  return Name(name: name, gender: gender, race: race);
}

String generateHumanName(String gender) {
  List<String> prefixes;
  List<String> suffixes;
  List<String> vowels;
  List<String> consonants;
  if (gender == 'Male') {
    prefixes = [
      "Al",
      "Ba",
      "Ced",
      "Da",
      "Eld",
      "Fen",
      "Gar",
      "Hal",
      "Iv",
      "Jor",
      "Kaed",
      "Luth",
      "Mael",
      "Nor",
      "Oth",
      "Per",
      "Quen",
      "Rod",
      "Sar",
      "Tib",
      "Ul",
      "Vey",
      "Wulf",
      "Xan",
      "Yor",
      "Zep"
    ];

    suffixes = [
      "ric",
      "lor",
      "rin",
      "var",
      "ion",
      "ren",
      "drin",
      "mar",
      "ric",
      "tis",
      "en",
      "ric",
      "eth",
      "ar",
      "or",
      "is",
      "an"
    ];
    vowels = ["a", "e", "i", "o", "u", "y"];
    consonants = [
      "b",
      "c",
      "d",
      "f",
      "g",
      "h",
      "j",
      "k",
      "l",
      "m",
      "n",
      "p",
      "q",
      "r",
      "s",
      "t",
      "v",
      "w",
      "x",
      "z"
    ];
  } else if (gender == 'Female') {
    prefixes = [
      "El",
      "Ser",
      "Mel",
      "Ly",
      "Rhi",
      "Va",
      "Ae",
      "Ny",
      "Is",
      "Cal",
      "Sy",
      "Mir"
    ];

    suffixes = [
      "wen",
      "wyn",
      "anna",
      "ia",
      "elle",
      "ora",
      "ine",
      "is",
      "andre",
      "thia"
    ];

    vowels = ["a", "e", "i", "o", "u", "y"];

    consonants = ["l", "r", "n", "s", "v", "m", "w", "z", "x", "t", "d"];
  } else {
    throw Exception('Gender: $gender is neither Male nor Female.');
  }
  return combinePhonetics(prefixes, suffixes, vowels, consonants);
}

String generateOrcName(String gender) {
  List<String> orcPrefixes;
  List<String> orcSuffixes;
  List<String> orcVowels;
  List<String> orcConsonants;

  if (gender == 'Male') {
    orcPrefixes = [
      "Gro",
      "Dur",
      "Thr",
      "Bol",
      "Az",
      "Goth",
      "Ug",
      "Sna",
      "Shag",
      "Lur",
      "Gor",
      "Nar",
      "Mor",
      "Vor",
      "Zog",
      "Throk",
      "Ur",
      "Kru",
      "Drog",
      "Skar"
    ];

    orcSuffixes = [
      "mash",
      "tan",
      "gg",
      "g",
      "og",
      "mog",
      "lúk",
      "ga",
      "rat",
      "tz",
      "bag",
      "zug",
      "kai",
      "ash",
      "ar",
      "kk",
      "gan",
      "ash",
      "g",
      "n"
    ];

    orcVowels = ["a", "o", "u", "i"];
    orcConsonants = [
      "g",
      "r",
      "m",
      "d",
      "t",
      "h",
      "b",
      "l",
      "z",
      "k",
      "s",
      "n",
      "v"
    ];
  } else if (gender == 'Female') {
    orcPrefixes = [
      "Ghor",
      "Urz",
      "Shag",
      "Mor",
      "Vraz",
      "Drak",
      "Zhur",
      "Brak",
      "Nag",
      "Throk",
      "Maz",
      "Rash",
      "Grush",
      "Vorg",
      "Krag",
      "Lurz",
      "Zog",
      "Tor",
      "Bruz",
      "Gul"
    ];

    orcSuffixes = ["za", "ula", "ra", "zha", "ka", "ga", "na", "gha", "sha"];

    orcVowels = ["a", "o", "u"];

    orcConsonants = ["g", "r", "z", "k", "d", "m", "sh", "th", "v", "b"];
  } else {
    throw Exception('Gender: $gender is neither Male nor Female.');
  }
  return combinePhonetics(orcPrefixes, orcSuffixes, orcVowels, orcConsonants);
}

String combinePhonetics(List<String> prefixes, List<String> suffixes,
    List<String>? vowels, List<String>? consonants) {
  final Random random = Random();
  String prefix = '';
  String suffix = '';
  if (random.nextDouble() < 0.5 || vowels == null || consonants == null) {
    prefix = prefixes[random.nextInt(prefixes.length)];
  } else {
    prefix = consonants[random.nextInt(consonants.length)] +
        vowels[random.nextInt(vowels.length)] +
        consonants[random.nextInt(consonants.length)];
  }
  if (random.nextDouble() < 0.5 || vowels == null || consonants == null) {
    suffix = suffixes[random.nextInt(suffixes.length)];
  } else {
    suffix = consonants[random.nextInt(consonants.length)] +
        vowels[random.nextInt(vowels.length)] +
        consonants[random.nextInt(consonants.length)];
  }
  return prefix + suffix;
}
