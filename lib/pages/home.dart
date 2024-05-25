import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override

  List<Service> services = [
    Service(title: 'Focus Mode', location: 'pages/timer_config.dart', appIcon: 'target.png'),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      appBar: AppBar(
        title: Text('Chronos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
            child: Card(
              child: ListTile(
                onTap: () {
                  Navigator.pushNamed(context, '/timer_config');
                },
                title: Text(services[index].title),
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/${services[index].appIcon}'),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}

class Service {

  String title; // title of the feature
  String location; // location of the page
  String appIcon; // icon corresponding to the feature

  Service({
    required this.title,
    required this.location,
    required this.appIcon
  });
}
