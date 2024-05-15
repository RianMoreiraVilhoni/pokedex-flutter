import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(PokemonApp());

class Pokemon {
  final String name;
  final String image;
  final String type;
  final List<String> abilities;

  Pokemon({required this.name, required this.image, required this.type, required this.abilities});
}

class PokemonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeSearch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  Pokemon _pokemon = Pokemon(name: '', image: '', type: '', abilities: []);

  Future<void> _searchPokemon() async {
    final String pokemonName = _searchController.text.toLowerCase().trim();
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String name = data['name'];
      String image = data['sprites']['front_default'];
      String type = data['types'][0]['type']['name'];
      List<String> abilities = [];

      for (var ability in data['abilities']) {
        abilities.add(ability['ability']['name']);
      }

      setState(() {
        _pokemon = Pokemon(name: name, image: image, type: type, abilities: abilities);
      });
    } else {
      setState(() {
        _pokemon = Pokemon(name: 'Pokémon não encontrado', image: '', type: '', abilities: []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PokeSearch'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Nome do Pokémon',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchPokemon,
              child: Text('Pesquisar'),
            ),
            SizedBox(height: 16.0),
            _pokemon.name.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _pokemon.name,
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 200, 
                    height: 200,
                    child: _pokemon.image.isNotEmpty
                      ? Image.network(
                          _pokemon.image,
                          fit: BoxFit.cover, 
                        )
                      : SizedBox(),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Tipo: ${_pokemon.type}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Habilidades:',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: _pokemon.abilities.map((ability) {
                      return Text(
                        ability,
                        style: TextStyle(fontSize: 16.0),
                      );
                    }).toList(),
                  ),
                ],
              )
            : SizedBox(),
          ],
        ),
      ),
    );
  }
}