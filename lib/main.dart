// Github Access Token: "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";



import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// Model Class
class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;
  // const constructor
  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
  });

  // copy method
  Film copyWith({required bool isFavorite}) => Film(
    id: id,
    title: title,
    description: description,
    isFavorite: isFavorite,
  );

  // override operator equality for equatable
  @override
  bool operator ==(covariant Film other) => id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll([id, isFavorite]);

  @override
  String toString() => '';
}

const allFilms = [
  Film(
    id: '1',
    title: 'The Shawshank Redemption',
    description: 'Description for the shawshank redemption',
    isFavorite: false,
  ),
  Film(
    id: '2',
    title: 'The Godfather',
    description: 'Description for the Godfather',
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'The Godfather: part II',
    description: 'Description for the Godfather: part II',
    isFavorite: false,
  ),
  Film(
    id: '4',
    title: 'The Dark Knight',
    description: 'Description for the Dark Knight',
    isFavorite: false,
  ),
];



class FilmNotifier extends StateNotifier<List<Film>>{
  FilmNotifier() : super(allFilms);

  void update(Film film, bool isFavorite){
    state = state.map((thisFilm) => thisFilm.id == film.id
    ? thisFilm.copyWith(isFavorite: isFavorite)
        : thisFilm
    ).toList();
  }
}
// enum for dropdown state
enum FavoriteStatus {
  all,
  favorite,
  notFavorite,
}

// status provider
final filmStatusProvider = StateProvider<FavoriteStatus>((ref) => FavoriteStatus.all);

// all status provider
final allFilmsProvider = StateNotifierProvider<FilmNotifier, List<Film>>((ref) => FilmNotifier());

// Favorite provider
final favoriteFilmsProvider = Provider<Iterable<Film>>((ref) {
      final allFilmsPro = ref.watch(allFilmsProvider);
     return allFilmsPro.where((film) => film.isFavorite);
});

// None Favorite provider
final noneFavoriteFilmsProvider = Provider<Iterable<Film>>((ref) =>
    ref.watch(allFilmsProvider).where((film) => !film.isFavorite),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        children: [
         const FilterWidget(),
        Consumer(
    builder: (BuildContext context, WidgetRef ref, Widget? child) {
      final filter = ref.watch(filmStatusProvider);
      switch(filter){
        case FavoriteStatus.all:
          return FilmList(provider: allFilmsProvider,);
        case FavoriteStatus.favorite:
          return FilmList(provider: favoriteFilmsProvider,);
        case FavoriteStatus.notFavorite:
          return FilmList(provider: noneFavoriteFilmsProvider);

      }
    },
    ),
        ],
      ),
    );
  }
}

// Films Widget
class FilmList extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const FilmList({super.key, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
        child: ListView.builder(
          itemCount: films.length,
            itemBuilder: (context, index){
              final film = films.elementAt(index);
              final favoriteIcon = film.isFavorite
              ? const Icon(Icons.favorite)
                  : const Icon(Icons.favorite_border);

              return ListTile(
                title: Text(film.title),
                subtitle: Text(film.description),
                trailing: IconButton(
                  icon: favoriteIcon,
                  onPressed: (){
                    final isFavorite = !film.isFavorite;
                    ref.read(allFilmsProvider.notifier).update(film, isFavorite);
                  },
                ),
              );
            }
        ));
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child){
        return DropdownButton(
          value: ref.watch(filmStatusProvider),
            items: FavoriteStatus.values.map((fss) =>
            DropdownMenuItem(
              value: fss,
              child: Text(fss.toString().split('.').last),
            ),
            ).toList(),
            onChanged: (dynamic fs){
            // final fooo = ref.read(filmStatusProvider.notifier);
            ref.read(filmStatusProvider.notifier).state = fs!;
            },
        );
      }
    );
  }
}
