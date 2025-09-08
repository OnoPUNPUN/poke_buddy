import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_buddy/controllers/home_page_controller.dart';
import 'package:poke_buddy/models/page_data.dart';
import 'package:poke_buddy/models/pokemon.dart';
import 'package:poke_buddy/widgets/pokemon_list_tile.dart';

/*Providers from Riverpod*/
final homePageControllerProvider = StateNotifierProvider<HomePageController, HomePageData>((ref) {
  return HomePageController(HomePageData.initial());
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomePageController _homePageController;
  late HomePageData _homePageData;

  @override
  Widget build(BuildContext context) {

    _homePageController = ref.watch(homePageControllerProvider.notifier);
    _homePageData = ref.watch(homePageControllerProvider);

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
            children: [_allPokemon(context, _homePageData)],
          ),
        ),
      ),
    );
  }
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
            itemCount: homePageData.data?.results?.length ?? 0,
            itemBuilder: (context, index) {
              PokemonListResult pokemon =  homePageData.data!.results![index];
              return PokemonListTile(pokemonURL: pokemon.url!);
            },
          ),
        ),
      ],
    ),
  );
}
