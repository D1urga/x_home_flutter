// import 'dart:math' as math;

// import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
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

class TweetCard extends StatefulWidget {
  final String message;
  final String img;
  bool isLiked;
  String likes;
  final String comments;
  final Function onclick;
  final Function onclickcomment;
  final String fullName;

  final List likeslist;
  final List commentslist;
  TextEditingController cnt;
  final String username;

  final String time;
  TweetCard(
      {super.key,
      required this.message,
      required this.img,
      required this.isLiked,
      required this.likes,
      required this.comments,
      required this.onclick,
      required this.onclickcomment,
      required this.cnt,
      required this.time,
      required this.fullName,
      required this.likeslist,
      required this.commentslist,
      required this.username});

  @override
  State<TweetCard> createState() => _TweetCardState();
}

class _TweetCardState extends State<TweetCard> {
  String filter = '';
  String taggedName = "";
  bool isTagged = false;
  bool _isLoading = false;
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

  Future<void> _tagg() async {
    final Dio _dio = Dio();
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var id1 = prefs1.getString("id");
    try {
      final response = await _dio.post(
        'https://xhomebackend.onrender.com/api/v1/notif/notif/$id1',
        data: {'username': taggedName, 'message': widget.cnt.text},
      );
      if (response.statusCode == 200) {
        print("worked");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed:')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: something went wrong')),
      );
    } finally {}
  }

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 10),
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            border: Border(
                bottom: BorderSide(
                    color: Color.fromARGB(255, 203, 203, 203), width: 0.3)),
            borderRadius: BorderRadius.all(Radius.circular(0))),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.all(0),
                  minVerticalPadding: 0,
                  leading: const CircleAvatar(
                    radius: 21,
                    backgroundColor: Color.fromARGB(255, 188, 208, 227),
                    child: Text("A"),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fullName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 0),
                      ),
                      Text(
                        '@${widget.username}',
                        style: const TextStyle(
                            fontSize: 13.5,
                            color: Color.fromARGB(255, 82, 82, 82),
                            fontWeight: FontWeight.w400,
                            height: 0),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.time,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "mathura",
                        style: TextStyle(
                            fontSize: 13.5,
                            color: Color.fromARGB(255, 62, 62, 62),
                            fontWeight: FontWeight.w400,
                            height: 0),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 6, top: 10, right: 2, bottom: 10),
                  child: Text(
                    widget.message,
                    style: const TextStyle(fontSize: 15.5),
                  ),
                ),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 230, 244, 255),
                      image: DecorationImage(
                          image: NetworkImage(widget.img),
                          filterQuality: FilterQuality.medium,
                          fit: BoxFit.cover),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 5.w,
                    ),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            elevation: 0,
                            backgroundColor: Colors.white,
                            constraints: const BoxConstraints(
                                maxHeight: 700,
                                minHeight: 300,
                                minWidth: double.infinity,
                                maxWidth: double.infinity),
                            context: context,
                            builder:
                                (BuildContext context) => StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                      return Column(
                                        children: [
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12, bottom: 8),
                                                child: Container(
                                                  height: 4,
                                                  width: 13.w,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color.fromARGB(
                                                              255, 52, 52, 52),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                ),
                                              ),
                                              const Text(
                                                "Comments",
                                                style: TextStyle(
                                                    fontSize: 16.7,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const Divider(
                                                height: 20,
                                                color: Color.fromARGB(
                                                    255, 217, 217, 217),
                                              )
                                            ],
                                          ),
                                          Expanded(
                                            child:
                                                !filter.contains(" ") &&
                                                        filter.length > 0 &&
                                                        filter.substring(
                                                                0, 1) ==
                                                            "@"
                                                    ? FutureBuilder<List<User>>(
                                                        future: futureUsers,
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Center(
                                                                child:
                                                                    CircularProgressIndicator());
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return Center(
                                                                child: Text(
                                                                    'Error: ${snapshot.error}'));
                                                          } else if (!snapshot
                                                                  .hasData ||
                                                              snapshot.data!
                                                                  .isEmpty) {
                                                            return const Center(
                                                                child: Text(
                                                                    'No data found'));
                                                          } else {
                                                            List<User> users =
                                                                snapshot.data!;
                                                            List<User>
                                                                filteredUsers =
                                                                users.where(
                                                                    (user) {
                                                              return user
                                                                  .username
                                                                  .toLowerCase()
                                                                  .contains(filter
                                                                      .substring(
                                                                          1)
                                                                      .toLowerCase());
                                                            }).toList();
                                                            return ListView
                                                                .builder(
                                                              itemCount:
                                                                  filteredUsers
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                User user =
                                                                    filteredUsers[
                                                                        index];
                                                                return Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      top: 4,
                                                                      bottom: 4,
                                                                      left: 15,
                                                                      right:
                                                                          10),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                        () {
                                                                          widget
                                                                              .cnt
                                                                              .text = '@${user.username}';
                                                                          taggedName =
                                                                              user.username;
                                                                          filter =
                                                                              '';
                                                                          isTagged =
                                                                              true;
                                                                        },
                                                                      );
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        CircleAvatar(
                                                                          radius:
                                                                              13,
                                                                          backgroundColor: const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              214,
                                                                              229,
                                                                              240),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(user.fullName.toUpperCase().substring(0, 1)),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              user.fullName,
                                                                              style: const TextStyle(fontWeight: FontWeight.w500, height: 1.3),
                                                                            ),
                                                                            Text(
                                                                              user.username,
                                                                              style: TextStyle(fontWeight: FontWeight.w400, height: 1.3),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          }
                                                        },
                                                      )
                                                    : ListView(
                                                        children: [
                                                          for (int i = 0;
                                                              i <
                                                                  widget
                                                                      .commentslist
                                                                      .length;
                                                              i++)
                                                            Column(
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 3.w,
                                                                      right:
                                                                          3.w,
                                                                      top: 1.h),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      CircleAvatar(
                                                                        radius:
                                                                            12,
                                                                        backgroundColor: const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            150,
                                                                            168,
                                                                            189),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            widget.commentslist[i]["userDetails"][0]["fullName"].toString().toUpperCase().substring(0,
                                                                                1),
                                                                            style: const TextStyle(
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        widget.commentslist[i]["userDetails"][0]
                                                                            [
                                                                            "fullName"],
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 14),
                                                                      ),
                                                                      const Expanded(
                                                                          child:
                                                                              SizedBox()),
                                                                      const Icon(
                                                                        Icons
                                                                            .favorite_outline_rounded,
                                                                        size:
                                                                            15,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: 11
                                                                            .w,
                                                                        right:
                                                                            3.w,
                                                                        bottom: 1
                                                                            .h),
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child: Text(
                                                                          widget.commentslist[i]
                                                                              [
                                                                              "message"]),
                                                                    )),
                                                              ],
                                                            )
                                                        ],
                                                      ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 7,
                                                  right: 7,
                                                  top: 5,
                                                  bottom: 8),
                                              child: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    filter = value;
                                                  });
                                                },
                                                controller: widget.cnt,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    filled: true,
                                                    hintStyle: const TextStyle(
                                                        fontSize: 14),
                                                    prefixIcon: const Icon(
                                                      Icons
                                                          .emoji_emotions_outlined,
                                                      size: 27,
                                                    ),
                                                    suffixIcon: InkWell(
                                                      onTap: () {
                                                        isTagged
                                                            ? _tagg()
                                                            : () {};
                                                        widget.onclickcomment();
                                                        setState(
                                                          () {
                                                            isTagged = false;
                                                          },
                                                        );
                                                      },
                                                      child: const Icon(
                                                        Icons.send_rounded,
                                                        size: 27,
                                                      ),
                                                    ),
                                                    hintText:
                                                        "Add a comment ..",
                                                    fillColor:
                                                        const Color.fromARGB(
                                                            255, 226, 232, 236),
                                                    focusedBorder: const OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    60)),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .transparent)),
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(60)),
                                                            borderSide: BorderSide(color: Colors.transparent))),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    }));
                      },
                      child: const Icon(
                        Icons.list_alt_rounded,
                        size: 20,
                      ),
                    ),
                    Text(
                      widget.comments,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(
                      Icons.repeat,
                      size: 20,
                    ),
                    const Text(
                      " 43",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const Expanded(child: SizedBox()),
                    widget.isLiked
                        ? InkWell(
                            onTap: () {
                              // setState(() {
                              //   widget.isLiked = !widget.isLiked;
                              //   widget.likes =
                              //       (int.parse(widget.likes) - 1).toString();
                              // });
                              widget.onclick();
                            },
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.pink,
                              size: 20,
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              // setState(() {
                              //   widget.isLiked = !widget.isLiked;
                              //   widget.likes =
                              //       (int.parse(widget.likes) + 1).toString();
                              // });
                              widget.onclick();
                            },
                            child: const Icon(
                              Icons.favorite_outline,
                              size: 20,
                            ),
                          ),
                    Text(
                      widget.likes,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(
                      Icons.bar_chart_rounded,
                      size: 20,
                    ),
                    const Text(
                      " 4753",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(
                      Icons.bookmark_outline,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5.w,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
