import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../Providers/pokemon_data_providers.dart';
import '../models/pokemon.dart';
import 'pokemon_states_dialogue.dart';

class PokemonGridCard extends ConsumerWidget {
  final String pokemonURL;

  const PokemonGridCard({super.key, required this.pokemonURL});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonDataProvider(pokemonURL));
    final favProvider = ref.watch(favoritePokemonProvider.notifier);
    final favs = ref.watch(favoritePokemonProvider);

    return pokemon.when(
      data: (data) =>
          _card(context, data, favProvider, favs.contains(pokemonURL)),
      loading: () => _card(
        context,
        null,
        favProvider,
        favs.contains(pokemonURL),
        isLoading: true,
      ),
      error: (e, s) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(e.toString()),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    Pokemon? pokemon,
    FavoritePokemonProvider favProvider,
    bool isFav, {
    bool isLoading = false,
  }) {
    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: () {
          if (!isLoading) {
            showDialog(
              context: context,
              builder: (_) => PokemonStatesCard(pokemonUrl: pokemonURL),
            );
          }
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: pokemon != null
                        ? Hero(
                            tag: '${pokemon.id}_${pokemon.name}_grid',
                            child: Image.network(
                              pokemon.sprites!.frontDefault!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (pokemon?.name ?? '...').toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (isFav) {
                            favProvider.removeFavPokemon(pokemonURL);
                          } else {
                            favProvider.addFavPokemon(pokemonURL);
                          }
                        },
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        tooltip: isFav ? 'Unfavorite' : 'Favorite',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
