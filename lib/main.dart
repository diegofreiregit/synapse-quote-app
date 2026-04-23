import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/quote_list_view.dart';
import 'views/quote_form_view.dart';
import 'views/quote_settings_view.dart';

import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synapse Quote Creation', // nome do aplicativo
      debugShowCheckedModeBanner: false, // remove a faixa de debug
      theme: AppTheme.lightTheme, // tema do aplicativo
      initialRoute: '/',
      routes: {
        '/': (context) =>
            const QuoteListView(), // tela inicial com os documentos armazenados no banco de dados
        '/create': (context) =>
            const QuoteFormView(), // tela para criar um novo documento
        '/settings': (context) =>
            const QuoteSettingsView(), // tela de configurações
      },
    );
  }
}
