import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poke_buddy/models/pokemon.dart';
import 'package:poke_buddy/services/database_service.dart';
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
  final DatabaseService _databaseService = GetIt.instance
      .get<DatabaseService>();

  String FAVORITE_POKEMON_KEY = "favorite_pokemon";

  FavoritePokemonProvider(super._state) {
    _setUp();
  }

  Future<void> _setUp() async {
    List<String>? result = await _databaseService.getList(FAVORITE_POKEMON_KEY);
    state = result ?? [];
  }

  void addFavPokemon(String url) {
    state = [...state, url];
    _databaseService.saveList(FAVORITE_POKEMON_KEY, state);
  }

  void removeFavPokemon(String url) {
    state = state.where((e) => e != url).toList();
    _databaseService.saveList(FAVORITE_POKEMON_KEY, state);
  }
}
