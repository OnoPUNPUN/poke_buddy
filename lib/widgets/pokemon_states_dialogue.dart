import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Providers/pokemon_data_providers.dart';

class PokemonStatesCard extends ConsumerWidget {
  final String pokemonUrl;

  const PokemonStatesCard({super.key, required this.pokemonUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonDataProvider(pokemonUrl));
    return AlertDialog(
      title: Text("Pokemon States"),
      content: pokemon.when(
        data: (data) {
          return Column(
            mainAxisSize: MainAxisSize.min,

            children:
                (data?.stats
                    ?.map(
                      (s) =>
                          Text("${s.stat?.name?.toUpperCase()}: ${s.baseStat}"),
                    )
                    .toList() ??
                []),
          );
        },
        error: (error, stackTrace) => Text(error.toString()),
        loading: () {
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
