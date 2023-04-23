import 'dart:async';
import 'package:provider/single_child_widget.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/models/database_helper.dart';
import 'package:pokedex/models/myPokemonCardUI.dart';
import 'package:pokedex/models/Pokemontypes.dart';



class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);
  

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late Future<List<Map<String, dynamic>>> _data;
  late Future<List<Map<String, dynamic>>> _types;
  late Future<List<Map<String, dynamic>>> _custom;
  late Future<List<Map<String, dynamic>>> name;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> typename=[];

  

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _data = DatabaseHelper.instance.customQuery('SELECT * FROM Pokemon');
    _types = DatabaseHelper.instance.customQuery('SELECT * FROM Types');

    List<Map<String, dynamic>> result = await DatabaseHelper.instance.customQuery('SELECT name FROM Types');
    for (Map<String, dynamic> row in result) {
        this.typename.add(row['name']);
  }

  }
  void settingModalBottomSheet(context,List<String> typename){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView.builder(
            itemCount: typename.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:getAvatarColor('${typename[index]}') ),
                  onPressed: () {

                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        '${typename[index]}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Pokèdex"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              _searchQuery = _searchController.text;
              setState(() {
                _fetchData();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
  padding: const EdgeInsets.all(8.0),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search Pokèmon by name',
        hintStyle: TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
              _fetchData();
            });
          },
          icon: Icon(Icons.clear),
          color: Colors.grey,
        ),
      ),
    ),
  ),
),
SizedBox(height: 10),
          Row(
            children: [
             ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.grey,
    shadowColor: Colors.black.withOpacity(0.1),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
  onPressed: () {
    settingModalBottomSheet(context,this.typename);
  },
    
  child: Text(
                'Sort by types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _data,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final data = snapshot.data!;
                  final filteredData = data
                      .where((pokemon) =>
                          pokemon['name']
                              .toString()
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();
                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (BuildContext context, int index) {
                      var type2 = filteredData[index]['type2'];
                      print(type2);
                      if (type2 == null) {
                        type2 = 0;
                      }
                      return MyPokemonCard(
                        name: filteredData[index]['name'].toString(),
                        id: filteredData[index]['id'].toString(),
                        imageUrl: filteredData[index]['image_url'].toString(),
                        type: filteredData[index]['type1'],
                        type2: type2,
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

