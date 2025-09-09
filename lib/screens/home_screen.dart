import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_buddy/Providers/pokemon_data_providers.dart';
import 'package:poke_buddy/controllers/home_page_controller.dart';
import 'package:poke_buddy/models/page_data.dart';
import 'package:poke_buddy/models/pokemon.dart';
import 'package:poke_buddy/widgets/pokemon_card.dart';
import 'package:poke_buddy/widgets/pokemon_list_tile.dart';

/*Providers from Riverpod*/
final homePageControllerProvider =
    StateNotifierProvider<HomePageController, HomePageData>((ref) {
      return HomePageController(HomePageData.initial());
    });

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _allPokemonScrollController = ScrollController();
  late HomePageController _homePageController;
  late HomePageData _homePageData;

  late List<String> _favoritePokemonList;

  @override
  void initState() {
    super.initState();
    _allPokemonScrollController.addListener(_scrolListener);
  }

  @override
  void dispose() {
    super.dispose();
    _allPokemonScrollController.removeListener(_scrolListener);
    _allPokemonScrollController.dispose();
  }

  void _scrolListener() {
    if (_allPokemonScrollController.offset >=
            _allPokemonScrollController.position.maxScrollExtent * 1 &&
        !_allPokemonScrollController.position.outOfRange) {
      _homePageController.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    _homePageController = ref.watch(homePageControllerProvider.notifier);
    _homePageData = ref.watch(homePageControllerProvider);
    _favoritePokemonList = ref.watch(favoritePokemonProvider);

    return Scaffold(body: _buildUI(context));
  }

  Widget _buildUI(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _favoritePokemon(context),
              _allPokemon(context, _homePageData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _favoritePokemon(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Favorite Pokemons", style: TextStyle(fontSize: 25)),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.50,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_favoritePokemonList.isNotEmpty)
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.48,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: _favoritePokemonList.length,
                      itemBuilder: (context, index) {
                        String pokemon = _favoritePokemonList[index];
                        return PokemonCard(pokemonUrl: pokemon);
                      },
                    ),
                  ),
                if (_favoritePokemonList.isEmpty)
                  const Text("No Favorite Pokemon"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _allPokemon(BuildContext context, HomePageData homePageData) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("All Pokemons", style: TextStyle(fontSize: 25)),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.60,
            child: ListView.builder(
              controller: _allPokemonScrollController,
              itemCount: homePageData.data?.results?.length ?? 0,
              itemBuilder: (context, index) {
                PokemonListResult pokemon = homePageData.data!.results![index];
                return PokemonListTile(pokemonURL: pokemon.url!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
