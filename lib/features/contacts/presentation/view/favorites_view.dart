import 'package:flutter/material.dart';
import '../widgets/contact_list_widget.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: const ContactListWidget(showFavoritesOnly: true),
    );
  }
}
