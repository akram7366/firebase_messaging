import 'package:flutter/material.dart';

import 'fun.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Messaging',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var list = <Item>[];
  String title = '', body = '';
  bool loading = false;

  @override
  void initState() {
    onMessageListen((item) {
      data(item: item).then((value) => setState(() => list = value));
    });
    data().then((value) => setState(() => list = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Messaging'),
      ),
      body: ListView(
        children: [
          TextFormField(
            onChanged: (value) => title = value,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10), label: Text('title')),
          ),
          TextFormField(
            onChanged: (value) => body = value,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10), label: Text('body')),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              if (loading) return;
              setState(() => loading = true);
              await sendNotification(title, body);
              setState(() => loading = false);
            },
            child: loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Text('send'),
          ),
          const Divider(),
          ...list.map((e) => ListTile(
            title: Text(e.title!),
            subtitle: Text(e.body!),
          )),
        ],
      ),
    );
  }
}
