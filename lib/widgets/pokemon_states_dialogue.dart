import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Providers/pokemon_data_providers.dart';

class PokemonStatesCard extends ConsumerWidget {
  final String pokemonUrl;

  const PokemonStatesCard({super.key, required this.pokemonUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonDataProvider(pokemonUrl));
    return AlertDialog(
      title: const Text("Pokémon Stats"),
      content: pokemon.when(
        data: (data) {
          final stats = data?.stats ?? [];
          return SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.7,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: stats.map((s) {
                  final name = (s.stat?.name ?? "").toUpperCase();
                  final value = s.baseStat ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (value / 200).clamp(0.0, 1.0),
                            minHeight: 10,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(value.toString()),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
        error: (error, stackTrace) => Text(error.toString()),
        loading: () {
          return const SizedBox(
            height: 64,
            width: 64,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
