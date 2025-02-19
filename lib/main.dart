import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  // Pet attributes
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 50; // New energy state variable

  // Controller for name input
  TextEditingController _nameController = TextEditingController();
  bool _isNameSet = false;

  // Timer for automatic hunger increase
  Timer? _hungerTimer;

  // Variables for game conditions
  String? _gameOverMessage;
  DateTime? _winStartTime;

  // Activity selection variables
  final List<String> _activities = ['Sleep', 'Exercise', 'Play', 'Eat'];
  String? _selectedActivity;

  @override
  void initState() {
    super.initState();
    // Start a timer that ticks every 5 seconds for hunger increase (for testing purposes)
    _hungerTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _updateHunger();
        _checkGameConditions();
      });
    });
    // Set default selected activity
    _selectedActivity = _activities.first;
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 70) {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 70) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  // Determine the text color based on happiness level
  MaterialColor _determineColor() {
    if (happinessLevel < 30) {
      return Colors.red;
    } else if (happinessLevel > 70) {
      return Colors.green;
    } else {
      return Colors.yellow;
    }
  }

  // Return an emoji representing pet mood
  String _petMood() {
    if (happinessLevel < 30) {
      return "😡";
    } else if (happinessLevel > 70) {
      return "🙂";
    } else {
      return "😐";
    } 
  }
  
  // Check win and loss conditions
  void _checkGameConditions() {
    // Loss Condition: Hunger reaches 100 and Happiness drops to 10.
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _gameOverMessage = "Game Over! Your pet is in distress.";
      _hungerTimer?.cancel();
    } else {
      _gameOverMessage = null;
    }

    // Win Condition: Happiness above 80 for 3 minutes.
    if (happinessLevel > 80) {
      if (_winStartTime == null) {
        _winStartTime = DateTime.now();
      } else {
        final duration = DateTime.now().difference(_winStartTime!);
        if (duration.inMinutes >= 3) {
          _gameOverMessage = "Congratulations! You win!";
          _hungerTimer?.cancel();
        }
      }
    } else {
      // Reset win timer if happiness drops below 80.
      _winStartTime = null;
    }
  }

  // Function to perform an activity and update energy level based on the selection
  void _performActivity() {
    setState(() {
      if (_selectedActivity == 'Sleep') {
        energyLevel = (energyLevel + 20).clamp(0, 100);
      } else if (_selectedActivity == 'Exercise') {
        energyLevel = (energyLevel - 20).clamp(0, 100);
      } else if (_selectedActivity == 'Play') {
        energyLevel = (energyLevel - 10).clamp(0, 100);
      } else if (_selectedActivity == 'Eat') {
        energyLevel = (energyLevel + 10).clamp(0, 100);
      }
    });
  }

  // UI for entering pet name
  Widget _buildNameInputUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Enter your pet\'s name'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  petName = _nameController.text.isEmpty ? 'Your Pet' : _nameController.text;
                  _isNameSet = true;
                });
              },
              child: Text('Confirm Name'),
            ),
          ],
        ),
      ),
    );
  }

  // Main game UI
  Widget _buildGameUI() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Name: $petName',
              style: TextStyle(fontSize: 20.0, color: _determineColor()),
            ),
            SizedBox(height: 16.0),
            Text(
              'Happiness Level: $happinessLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Mood: ${_petMood()}',
              style: TextStyle(fontSize: 30.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Hunger Level: $hungerLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            // Energy bar widget
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Energy Level: $energyLevel',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: energyLevel / 100,
                  minHeight: 10.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
            SizedBox(height: 32.0),
            // Activity Selection UI
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select Activity:',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(width: 16.0),
                DropdownButton<String>(
                  value: _selectedActivity,
                  items: _activities.map((activity) {
                    return DropdownMenuItem<String>(
                      value: activity,
                      child: Text(activity),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivity = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _performActivity,
              child: Text('Confirm Activity'),
            ),
            if (_gameOverMessage != null) ...[
              SizedBox(height: 32.0),
              Text(
                _gameOverMessage!,
                style: TextStyle(fontSize: 24.0, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Pet')),
      body: _isNameSet ? _buildGameUI() : _buildNameInputUI(),
    );
  }
}
