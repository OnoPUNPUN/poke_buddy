import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_buddy/models/pokemon.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../Providers/pokemon_data_providers.dart';

class PokemonListTile extends ConsumerWidget {
  final String pokemonURL;

  const PokemonListTile({super.key, required this.pokemonURL});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonDataProvider(pokemonURL));

    return pokemon.when(
      data: (data) {
        return _tile(context, false, data);
      },
      error: (error, stackTrace) => Text(error.toString()),
      loading: () {
        return _tile(context, true, null);
      },
    );
  }

  Widget _tile(BuildContext context, bool isLoading, Pokemon? pokemon) {
    return Skeletonizer(
      enabled: isLoading,
      child: ListTile(
        leading: pokemon != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(pokemon.sprites!.frontDefault!),
              )
            : const CircleAvatar(),
        title: Text(pokemon != null ? pokemon.name!.toUpperCase() : "Loading"),
        subtitle: Text("Has ${pokemon?.moves?.length.toString() ?? 0} moves"),
        trailing: IconButton(onPressed: () {}, icon: Icon(Icons.favorite_border)),
      ),
    );
  }
}
