import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:x_home/login_page.dart';
import 'package:x_home/utils/card.dart';
import 'package:x_home/utils/dataprovider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  final StreamController<List<dynamic>> _controller =
      StreamController<List<dynamic>>();

  List<dynamic> _data = [];
  int _currentPage = 1;
  bool _isFetching = false;
  int _lim = 10;

  Stream<List<dynamic>> get dataStream => _controller.stream;
  late Stream<List<dynamic>> futureUsers;

  final TextEditingController _search = TextEditingController();

  Stream<List<dynamic>> fetchData(int page) async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id");
    while (true) {
      final response = await http.get(
        Uri.parse(
            'https://xhomebackend.onrender.com/api/v1/post/getPost/$id?limit=$_lim'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        yield data['data']['items'];
      } else {
        throw Exception('Failed to load data');
      }
    }
  }

  Future<List<dynamic>> fetchData2(int lim) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id");
    while (true) {
      final response = await http.get(
        Uri.parse(
            'https://xhomebackend.onrender.com/api/v1/post/getPost/$id?limit=$lim'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['data']['items'];
      } else {
        throw Exception('Failed to load data');
      }
    }
  }

  void _fetchData() {
    fetchData(_currentPage);
  }

  void fetchNextPage() async {
    print(_lim);
    _lim = _lim + 10;
    print(_lim);
  }

  Future<void> _postLike(String s) async {
    print("working");
    final Dio _dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id");
    try {
      final response = await _dio.post(
        'https://xhomebackend.onrender.com/api/v1/likes/like/$id/$s',
      );

      if (response.statusCode == 200) {
      } else {
        print('Login failed: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed:')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: something went wrong')),
      );
    } finally {
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  Future<void> _postComment(String s) async {
    final Dio _dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id");
    try {
      final response = await _dio.post(
        'https://xhomebackend.onrender.com/api/v1/comments/postComment/$s/$id',
        data: {
          'message': _textcontroller.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        print(response);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed:')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: something went wrong')),
      );
    } finally {
      // setState(() {
      //   _isLoading = false;
      // });
    }

    _textcontroller.text = "";
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    futureUsers = fetchData(_currentPage);
  }

  @override
  void dispose() {
    dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final TextEditingController _textcontroller = TextEditingController();
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchNextPage();
      print("working");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          centerTitle: true,
          title: InkWell(
            onTap: () {},
            child: const Text(
              "FlickX",
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            const Icon(
              Icons.settings,
              size: 23,
              color: Colors.black,
            ),
            SizedBox(
              width: 3.w,
            )
          ],
          leading: Builder(builder: (context) {
            return InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  child: Text(
                    "A",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8.h,
              ),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: InkWell(
                  onTap: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.remove("email");
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) {
                      return LoginPage();
                    }));
                  },
                  child: const CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 94, 171, 165),
                    child: Text(
                      "A",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                trailing: Icon(Icons.more_vert_rounded),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: const Text(
                  "username",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const Text(
                "@userid",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 89, 89, 89)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: const Text(
                  "0 following   0 followers",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Divider(
                height: 5.h,
              ),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(vertical: -1),
                contentPadding: EdgeInsets.all(0),
                horizontalTitleGap: 25,
                leading: Icon(
                  Icons.person,
                  size: 26,
                ),
                title: Text("Profile",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(vertical: -1),
                contentPadding: EdgeInsets.all(0),
                horizontalTitleGap: 25,
                leading: Icon(
                  Icons.payment,
                  size: 26,
                ),
                title: Text("Premium",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(vertical: -1),
                contentPadding: EdgeInsets.all(0),
                horizontalTitleGap: 25,
                leading: Icon(
                  Icons.people,
                  size: 26,
                ),
                title: Text("Communities",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(vertical: -1),
                contentPadding: EdgeInsets.all(0),
                horizontalTitleGap: 25,
                leading: Icon(
                  Icons.bookmark_outline,
                  size: 26,
                ),
                title: Text("Saved",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(vertical: -1),
                contentPadding: EdgeInsets.all(0),
                horizontalTitleGap: 25,
                leading: Icon(
                  Icons.list_alt,
                  size: 26,
                ),
                title: Text("List",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(vertical: -1),
                contentPadding: EdgeInsets.all(0),
                horizontalTitleGap: 25,
                leading: Icon(
                  Icons.mic_none,
                  size: 26,
                ),
                title: Text("Spaces",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(vertical: -1),
                contentPadding: EdgeInsets.all(0),
                horizontalTitleGap: 25,
                leading: Icon(
                  Icons.monetization_on_outlined,
                  size: 26,
                ),
                title: Text("Monetisation",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              Divider(
                height: 5.h,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Settings and Support",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 136, 136, 136)),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Icon(Icons.brightness_high)
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return ListView.builder(
            controller: _scrollController,
            itemCount: data.length,
            itemBuilder: (context, index) {
              if (index >= data.length) return CircularProgressIndicator();
              return TweetCard(
                  message: data[index]["message"],
                  img: data[index]["img"],
                  isLiked: data[index]["isliked"],
                  likes: data[index]["totalLikes"].toString(),
                  comments: data[index]["totalComments"].toString(),
                  onclick: () {
                    _postLike(data[index]["_id"]);
                  },
                  onclickcomment: () {
                    _postComment(data[index]["_id"]);
                  },
                  cnt: _textcontroller,
                  fullName: data[index]["Parentuser"][0]["fullName"],
                  likeslist: data[index]["likes"],
                  commentslist: data[index]["comments"],
                  time:
                      timeago.format(DateTime.parse(data[index]["createdAt"])),
                  username: data[index]["Parentuser"][0]["email"]);
            },
          );
        },
      ),
    );
  }
}
