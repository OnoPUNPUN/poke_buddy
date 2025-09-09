import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_buddy/models/pokemon.dart';
import 'package:poke_buddy/widgets/pokemon_states_dialogue.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../Providers/pokemon_data_providers.dart';

class PokemonListTile extends ConsumerWidget {
  final String pokemonURL;

  PokemonListTile({super.key, required this.pokemonURL});

  late FavoritePokemonProvider _favoritePokemonProvider;
  late List<String> _favoritePokemonList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonDataProvider(pokemonURL));
    _favoritePokemonProvider = ref.watch(favoritePokemonProvider.notifier);
    _favoritePokemonList = ref.watch(favoritePokemonProvider);

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
      child: GestureDetector(
        onTap: () {
          if (!isLoading) {
            showDialog(
              context: context,
              builder: (_) {
                return PokemonStatesCard(pokemonUrl: pokemonURL);
              },
            );
          }
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            leading: pokemon != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(
                      pokemon.sprites!.frontDefault!,
                    ),
                  )
                : const CircleAvatar(),
            title: Text(
              pokemon != null ? pokemon.name!.toUpperCase() : "Loading",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Has ${pokemon?.moves?.length.toString() ?? 0} moves",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                if (_favoritePokemonList.contains(pokemonURL)) {
                  _favoritePokemonProvider.removeFavPokemon(pokemonURL);
                } else {
                  _favoritePokemonProvider.addFavPokemon(pokemonURL);
                }
              },
              icon: Icon(
                _favoritePokemonList.contains(pokemonURL)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
