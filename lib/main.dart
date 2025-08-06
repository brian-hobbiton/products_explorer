import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:products_explorer/pages/home_page.dart';
import 'package:products_explorer/providers/cart_provider.dart';
import 'package:products_explorer/theme/theme.dart';
import 'package:products_explorer/theme/util.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Use with Google Fonts package to use downloadable fonts
    TextTheme textTheme = createTextTheme(context, "Inter", "Inter");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'Product Explorer',
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
