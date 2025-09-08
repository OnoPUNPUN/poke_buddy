import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poke_buddy/models/page_data.dart';
import 'package:poke_buddy/models/pokemon.dart';
import 'package:poke_buddy/services/http_services.dart';

class HomePageController extends StateNotifier<HomePageData> {
  final GetIt _getIt = GetIt.instance;

  late HttpServices _httpServices;

  HomePageController(super.state) {
    _httpServices = _getIt.get<HttpServices>();
    _setUp();
  }

  Future<void> _setUp() async {
    loadData();
  }

  Future<void> loadData() async {
    if (state.data == null) {
      Response? response = await _httpServices.get(
        "https://pokeapi.co/api/v2/pokemon?limit=20&offset=0",
      );
      if (response != null && response.data != null) {
        PokemonListData data = PokemonListData.fromJson(response.data);
        state = state.copyWith(data: data);
      }
    } else {}
  }
}
