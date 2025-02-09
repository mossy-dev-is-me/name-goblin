// markov_name_generator.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart'; // For rootBundle
import 'data.dart'; // For Race and Name classes

class MarkovNameGenerator {
  final Map<String, Map<String, List<String>>> _markovChains = {};
  final Random _random = Random();
  final int _order; // Order of the Markov chain (e.g., 2 for second-order)

  MarkovNameGenerator({int order = 2}) : _order = order;

  Future<void> initialize() async {
    // Load Markov chains for all race/gender combinations
    for (final race in races) {
      for (final gender in ['Male', 'Female']) {
        final String key = '${race.name}|$gender';
        final String filePath =
            'assets/names/${race.name.toLowerCase()}_${gender.toLowerCase()}.txt';
        await _loadMarkovChain(key, filePath);
      }
    }
  }

  Future<void> _loadMarkovChain(String key, String filePath) async {
    try {
      final String data = await rootBundle.loadString(filePath);
      final List<String> names = LineSplitter.split(data).toList();

      _markovChains[key] = {};

      for (final name in names) {
        for (int i = 0; i < name.length - _order; i++) {
          final String prefix = name.substring(
              i, i + _order); // Current prefix (e.g., last 2 characters)
          final String nextChar = name[i + _order]; // Next character

          if (!_markovChains[key]!.containsKey(prefix)) {
            _markovChains[key]![prefix] = [];
          }
          _markovChains[key]![prefix]!.add(nextChar);
        }
      }
    } catch (e) {
      print('Failed to load Markov chain for $key: $e');
    }
  }

  String generateName(String race, String gender,
      {int minLength = 3, int maxLength = 15}) {
    final String key = '$race|$gender';
    final Map<String, List<String>>? markovChain = _markovChains[key];

    if (markovChain == null || markovChain.isEmpty) {
      throw Exception(
          "No Markov chain found for $race $gender. Ensure the data file exists.");
    }

    // Start with a random prefix
    String prefix =
        markovChain.keys.elementAt(_random.nextInt(markovChain.keys.length));
    String name = prefix;

    // Generate the rest of the name
    while (name.length < maxLength) {
      if (!markovChain.containsKey(prefix)) {
        break; // No more possible characters
      }

      final List<String> possibleNextChars = markovChain[prefix]!;
      final String nextChar =
          possibleNextChars[_random.nextInt(possibleNextChars.length)];
      name += nextChar;

      // Update the prefix to the last `_order` characters
      prefix = name.substring(name.length - _order);

      // Stop if the name reaches the minimum length and a natural stopping point
      if (name.length >= minLength && _random.nextDouble() < 0.2) {
        break;
      }
    }

    return name;
  }
}
