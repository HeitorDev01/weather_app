import 'package:flutter/material.dart'; // <--- ESTA LINHA É OBRIGATÓRIA
import 'package:intl/date_symbol_data_local.dart';
import 'package:weather_app/pages/home_page.dart';


void main() {
  // 1. Garante que os widgets do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa a localização para as datas funcionarem em PT-BR
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}