import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_buddy/Providers/pokemon_data_providers.dart';
import 'package:poke_buddy/controllers/home_page_controller.dart';
import 'package:poke_buddy/models/page_data.dart';
import 'package:poke_buddy/widgets/pokemon_card.dart';
import 'package:poke_buddy/widgets/pokemon_list_tile.dart';
import 'package:poke_buddy/widgets/pokemon_grid_card.dart';

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

  String _searchQuery = "";
  bool _favoritesOnly = false;
  bool _useGrid = false;
  bool _showFavorites = true;

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
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.02,
                vertical: 6,
              ),
              child: const TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: "All"),
                  Tab(text: "Favorites"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_allTab(context), _favoritesTab(context)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _allTab(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_header(context), _allPokemon(context, _homePageData)],
        ),
      ),
    );
  }

  Widget _favoritesTab(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * 0.02,
        ),
        child: _favoritePokemon(context, fullSize: true),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
        TextField(
          decoration: InputDecoration(
            hintText: "Search Pokémon by name",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() => _searchQuery = "");
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onChanged: (value) =>
              setState(() => _searchQuery = value.trim().toLowerCase()),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.008),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text("Favorites only"),
              selected: _favoritesOnly,
              onSelected: (v) => setState(() => _favoritesOnly = v),
              avatar: const Icon(Icons.favorite, color: Colors.red, size: 18),
            ),
            FilterChip(
              label: Text(_useGrid ? "Grid" : "List"),
              selected: _useGrid,
              onSelected: (v) => setState(() => _useGrid = v),
              avatar: Icon(
                _useGrid ? Icons.grid_view : Icons.view_list,
                size: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _favoritePokemon(BuildContext context, {bool fullSize = false}) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Favorite Pokemons",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              IconButton(
                tooltip: _showFavorites ? "Hide favorites" : "Show favorites",
                onPressed: () =>
                    setState(() => _showFavorites = !_showFavorites),
                icon: Icon(
                  _showFavorites ? Icons.expand_less : Icons.expand_more,
                ),
              ),
            ],
          ),
          if (_showFavorites && _favoritePokemonList.isNotEmpty)
            SizedBox(
              height: fullSize ? MediaQuery.sizeOf(context).height * 0.50 : 220,
              width: MediaQuery.sizeOf(context).width,
              child: GridView.builder(
                scrollDirection: Axis.vertical,
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
          if (_showFavorites && _favoritePokemonList.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "No favorite Pokémon yet",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
            child: RefreshIndicator(
              onRefresh: () async {
                await _homePageController.refresh();
              },
              child: Builder(
                builder: (context) {
                  final all = homePageData.data?.results ?? [];
                  final filtered = all.where((r) {
                    final name = (r.name ?? "").toLowerCase();
                    final matchesQuery =
                        _searchQuery.isEmpty || name.contains(_searchQuery);
                    final matchesFav =
                        !_favoritesOnly ||
                        (_favoritePokemonList.contains(r.url));
                    return matchesQuery && matchesFav;
                  }).toList();

                  if (_useGrid) {
                    return GridView.builder(
                      controller: _allPokemonScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final pokemon = filtered[index];
                        return PokemonGridCard(pokemonURL: pokemon.url!);
                      },
                    );
                  }

                  return ListView.builder(
                    controller: _allPokemonScrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final pokemon = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Transform.scale(
                          scale: 1.02,
                          alignment: Alignment.centerLeft,
                          child: PokemonListTile(pokemonURL: pokemon.url!),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
