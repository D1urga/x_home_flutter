import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:x_home/search_profile_page.dart';

class User {
  final String id;
  final String fullName;
  final String username;
  final String email;

  User(
      {required this.id,
      required this.fullName,
      required this.username,
      required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _search = TextEditingController();
  String filter = '';
  late Future<List<User>> futureUsers;
  Future<List<User>> fetchUsers() async {
    final response = await http.get(
        Uri.parse('https://xhomebackend.onrender.com/api/v1/user/getAllUser'));

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      List<dynamic> body1 = body["data"];
      return body1.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Container(
          height: 40,
          width: double.infinity,
          child: TextField(
            controller: _search,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(0),
                isDense: true,
                filled: true,
                hintStyle: TextStyle(fontSize: 15),
                prefixIcon: Icon(
                  Icons.search,
                  size: 23,
                ),
                hintText: "Search",
                fillColor: Color.fromARGB(255, 237, 240, 242),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    borderSide: BorderSide(color: Colors.transparent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    borderSide: BorderSide(color: Colors.transparent))),
            onChanged: (value) {
              setState(() {
                filter = value;
              });
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<User>>(
              future: futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data found'));
                } else {
                  List<User> users = snapshot.data!;
                  List<User> filteredUsers = users.where((user) {
                    return user.fullName
                            .toLowerCase()
                            .contains(filter.toLowerCase()) ||
                        user.email.toLowerCase().contains(filter.toLowerCase());
                  }).toList();
                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      User user = filteredUsers[index];
                      return ListTile(
                        trailing: const Icon(
                          Icons.more_vert_rounded,
                          size: 21,
                        ),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              const Color.fromARGB(255, 214, 229, 240),
                          child: Center(
                            child: Text(
                                user.fullName.toUpperCase().substring(0, 1)),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          user.email,
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => SearchProfilePage(
                                        fullName: user.fullName,
                                        id: user.id,
                                      )));
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
