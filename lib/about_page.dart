import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("About"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 40),

                // Game Logo
                Image.asset('assets/images/2048.png', height: 100),

                const SizedBox(height: 25),

                // Game Instructions
                SizedBox(
                  width: queryData.size.width * 0.95,
                  child: const Text(
                    'Swipe in any direction to slide all tiles on the grid.\n'
                    'Two tiles with the same number will combine.\n'
                    'Reach 2048 to win the game.\n Good luck!',
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Developer Credits
                SizedBox(
                  width: queryData.size.width * 0.95,
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Developed by Moiseychenko Nikita and Abishev Beibarys in the scope of the course “Crossplatform Development” at Astana IT University.\n'
                      'Mentor (Teacher): Assistant Professor Abzal Kyzyrkanov',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
