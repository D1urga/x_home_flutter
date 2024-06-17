import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:x_home/Not.dart';
import 'package:http/http.dart' as http;
import 'package:x_home/utils/card.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserNotifications extends StatefulWidget {
  const UserNotifications({super.key});

  @override
  State<UserNotifications> createState() => _UserNotificationsState();
}

class _UserNotificationsState extends State<UserNotifications> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    futureUsers = fetchData(1);
  }

  late Stream<List<dynamic>> futureUsers;
  int counts = -1;
  int round = 1;

  final TextEditingController _search = TextEditingController();

  Stream<List<dynamic>> fetchData(int page) async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id");
    while (true) {
      final response = await http.get(
        Uri.parse('https://xhomebackend.onrender.com/api/v1/notif/notif/$id'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["data"].length != counts && round == 2) {
          NotificationService().showNotification(
            0,
            'Someone mentioned you in comments ',
            'Check out your notifications',
          );
        }
        setState(
          () {
            counts = data["data"].length;
            round = 2;
          },
        );

        yield data['data'];
      } else {
        throw Exception('Failed to load data');
      }
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
          backgroundColor: Colors.white,
          title: InkWell(
            onTap: () {
              NotificationService().showNotification(
                0,
                'Test Title',
                'Test Body',
              );
            },
            child: const Text(
              'Notifications',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: fetchData(1),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              if (index >= data.length) return CircularProgressIndicator();
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 3.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '@${data[data.length - index - 1]["name"]} ',
                              style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 60, 132, 191)),
                            ),
                            const Text(
                              "Tagged you in comments",
                              style: TextStyle(
                                  fontSize: 15.5, fontWeight: FontWeight.w600),
                            ),
                            const Expanded(child: SizedBox()),
                            const Icon(
                              Icons.more_vert,
                              size: 20,
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5.w, top: 5),
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${data[data.length - index - 1]["message"]} ',
                              style: const TextStyle(
                                  fontSize: 15.5,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  height: 1.2),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5, top: 5),
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              timeago.format(DateTime.parse(
                                  data[data.length - index - 1]["createdAt"])),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const Divider(
                          color: const Color.fromARGB(255, 226, 226, 226),
                          height: 7,
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
