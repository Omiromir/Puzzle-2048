import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'About'),
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
  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          bool isPortrait = orientation == Orientation.portrait;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: isPortrait ? 125 : 50),
                  Image.asset(
                    'assets/images/2048.png',
                    width: isPortrait
                        ? queryData.size.width * 0.6
                        : queryData.size.width * 0.3,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: queryData.size.width * 0.95,
                    child: const Text(
                      'Swipe in any direction to slide all tiles on the grid.\n'
                      'Two tiles with the same number will combine.\n'
                      'Reach 2048 to win the game.\n Good luck!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: isPortrait ? 50 : 20),
                  SizedBox(
                    width: queryData.size.width * 0.95,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Developed by Moiseychenko Nikita and Abishev Beibarys in the scope of the course “Crossplatform Development” at Astana IT University. '
                        'Mentor (Teacher): Assistant Professor Abzal Kyzyrkanov',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
