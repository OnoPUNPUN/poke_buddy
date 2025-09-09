import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poke_buddy/models/pokemon.dart';
import 'package:poke_buddy/services/http_services.dart';

final pokemonDataProvider = FutureProvider.family<Pokemon?, String>((
  ref,
  url,
) async {
  HttpServices _httpService = GetIt.instance.get<HttpServices>();
  Response? response = await _httpService.get(url);

  if (response != null && response.data != null) {
    return Pokemon.fromJson(response.data);
  }

  return null;
});

final favoritePokemonProvider =
    StateNotifierProvider<FavoritePokemonProvider, List<String>>((ref) {
      return FavoritePokemonProvider([]);
    });

class FavoritePokemonProvider extends StateNotifier<List<String>> {
  FavoritePokemonProvider(super._state) {
    _setUp();
  }

  Future<void> _setUp() async {}

  void addFavPokemon(String url) {
    state = [...state, url];
  }

  void removeFavPokemon(String url) {
    state = state.where((e) => e != url).toList();
  }
}
