import 'package:example/pages/sandbox_example.dart';
import 'package:flutter/material.dart';

import 'draggable_node_example.dart';
import 'fixed_node_example.dart';
import 'floating_node_example.dart';

import 'package:url_launcher/url_launcher.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blueprint Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => goTo(context, const FixedNodeExample()),
              label: const Text("Fixed Node"),
              icon: const Icon(Icons.push_pin_rounded),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () => goTo(context, const DraggableNodeExample()),
              label: const Text("Draggable Node"),
              icon: const Icon(Icons.pinch_rounded),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () => goTo(context, const FloatingNodeExample()),
              label: const Text("Floating Node"),
              icon: const Icon(Icons.directions_boat_filled_rounded),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () => goTo(context, const SandboxExample()),
              label: const Text("Sandbox"),
              icon: const Icon(Icons.dashboard_customize_rounded),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(
                  "https://salah-rashad.github.io/blueprint_system_docs"),
              label: const Text("Explore Documentations"),
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ),
      ),
    );
  }

  void goTo(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}
