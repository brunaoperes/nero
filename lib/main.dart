import 'package:flutter/material.dart';
import 'screens/updates_screen.dart';
import 'services/app_update_service.dart';
import 'widgets/update_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Pessoal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gestor Pessoal'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final AppUpdateService _updateService = AppUpdateService();

  @override
  void initState() {
    super.initState();
    _checkForUpdatesOnStartup();
  }

  @override
  void dispose() {
    _updateService.dispose();
    super.dispose();
  }

  /// Verifica atualizações ao iniciar o app
  Future<void> _checkForUpdatesOnStartup() async {
    // Aguarda um pouco para não impactar a inicialização
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verifica se deve checar (respeita intervalo de 24h)
    if (await _updateService.shouldCheckForUpdates()) {
      final updateInfo = await _updateService.getAvailableUpdate();

      if (updateInfo != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: !updateInfo.mandatory,
          builder: (context) => UpdateDialog(
            updateInfo: updateInfo,
            updateService: _updateService,
            mandatory: updateInfo.mandatory,
          ),
        );
      }
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update),
            tooltip: 'Atualizações',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpdatesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '🎉 v1.0.15 - AUTO-ATUALIZAÇÃO FUNCIONANDO!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você pressionou o botão:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdatesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.system_update),
              label: const Text('Verificar Atualizações'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Incrementar',
        child: const Icon(Icons.add),
      ),
    );
  }
}
