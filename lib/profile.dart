import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

Map<String, dynamic> list = {};
bool isloading = false;
bool isuploading = false;

class _UserProfileState extends State<UserProfile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData(1);
  }

  Future<void> fetchData(int page) async {
    setState(() {
      isloading = true;
    });
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var id1 = prefs1.getString("id");
    final response = await http.get(
      Uri.parse(
          'https://xhomebackend.onrender.com/api/v1/user/userprofile/$id1'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        list = data["data"][0];
      });
    } else {
      throw Exception('Failed to load data');
    }
    setState(() {
      isloading = false;
    });
  }

  Future<void> _refresh() async {
    await fetchData(1);
  }

  Future<void> _delete(String id2) async {
    // setState(() {
    //   isuploading = true;
    // });
    print(id2);
    final Dio _dio = Dio();
    try {
      final response = await _dio.delete(
        'https://xhomebackend.onrender.com/api/v1/post/delete/$id2',
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
              content: Text(
                'Deleted',
                style: TextStyle(
                    color: Color.fromARGB(255, 228, 73, 62),
                    fontWeight: FontWeight.w500),
              )),
        );
      } else {
        print('followed failed: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('followed failed:')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: something went wrong')),
      );
    } finally {}
    print("worked");
    // setState(() {
    //   isuploading = false;
    // });
  }

  // Future<void> _unfollow() async {
  //   setState(() {
  //     isuploading = true;
  //   });
  //   print("working");
  //   final Dio _dio = Dio();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var id = prefs.getString("id");
  //   try {
  //     final response = await _dio.post(
  //       'https://xhomebackend.onrender.com/api/v1/follow/unfollow/${widget.id}/$id',
  //     );

  //     if (response.statusCode == 200) {
  //       print("njjasjasdkasbfasbfasbfasfaksfsa");
  //     } else {
  //       print('followed failed: ${response.statusCode}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('followed failed:')),
  //       );
  //     }
  //   } catch (e) {
  //     print(e);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Error: something went wrong')),
  //     );
  //   } finally {}
  //   print("worked");
  //   setState(() {
  //     isuploading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            isloading ? "" : list["fullName"],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Center(
                child: FaIcon(
              FontAwesomeIcons.arrowLeft,
              size: 20,
            )),
          ),
          actions: [
            const FaIcon(
              FontAwesomeIcons.bars,
              size: 16,
              color: Colors.black,
            ),
            SizedBox(
              width: 4.w,
            )
          ],
        ),
      ),
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              backgroundColor: Color.fromARGB(255, 169, 207, 238),
              color: Color.fromARGB(255, 0, 0, 0),
              displacement: 30,
              edgeOffset: 0,
              child: Padding(
                padding: EdgeInsets.only(left: 2.w, right: 2.w),
                child: Column(
                  children: [
                    ListTile(
                      horizontalTitleGap: 10,
                      contentPadding: const EdgeInsets.all(0),
                      leading: const CircleAvatar(
                        radius: 27,
                        backgroundColor: Color.fromARGB(255, 203, 221, 233),
                        child: Center(
                          child: Text(
                            "A",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      title: Text(
                        list["fullName"],
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            height: 0,
                            fontSize: 16.5),
                      ),
                      subtitle: Text(
                        '@${list["email"]}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            height: 0,
                            color: Color.fromARGB(255, 118, 118, 118)),
                      ),
                      trailing: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: Container(
                            height: 35,
                            width: 31.w,
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 219, 237, 252),
                                // border: Border.all(color: Colors.black, width: 0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            child: Center(
                              child: !isuploading
                                  ? const Text(
                                      "Edit Profile",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(255, 0, 0, 0)),
                                    )
                                  : const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      )),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 2.w,
                        ),
                        Container(
                            width: 75.w,
                            alignment: Alignment.topLeft,
                            child: const Text(
                              "Update your bio data here .. ex .. Software Engineer",
                              style: TextStyle(
                                  // fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.2),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 2.w,
                        ),
                        const Icon(Icons.location_on,
                            size: 15,
                            color: Color.fromARGB(255, 116, 116, 116)),
                        const SizedBox(
                          width: 2,
                        ),
                        const Text(
                          "India",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 116, 116, 116)),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        const Icon(Icons.calendar_month_rounded,
                            size: 15,
                            color: Color.fromARGB(255, 116, 116, 116)),
                        const SizedBox(
                          width: 2,
                        ),
                        const Text(
                          "Joined may 2021",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 116, 116, 116)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Expanded(child: SizedBox()),
                        SizedBox(
                          width: 3.w,
                        ),
                        Text(
                          list["totalPost"].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        const Text(
                          " Posts",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color.fromARGB(255, 127, 127, 127)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          list["totalFollowers"].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        const Text(
                          " Followers",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color.fromARGB(255, 127, 127, 127)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          list["totalFollowing"].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        const Text(
                          " Following",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color.fromARGB(255, 127, 127, 127)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // const Row(
                    //   children: [
                    //     Text(
                    //       "Followed by many of your contacts",
                    //       style: TextStyle(color: Color.fromARGB(255, 109, 109, 109)),
                    //     )
                    //   ],
                    // ),
                    // const SizedBox(
                    //   height: 15,
                    // ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Posts",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15.5),
                        ),
                        Text(
                          "Highlights",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15.5),
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    list["totalPost"] == 0
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                "No post available",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 69, 69, 69)),
                              ),
                            ),
                          )
                        : Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 1.5,
                                mainAxisSpacing: 1.5,
                              ),
                              itemCount: list["totalPost"],
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            list["allPost"][index]["img"],
                                          ),
                                          fit: BoxFit.cover)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                              backgroundColor: Colors.white,
                                              constraints: const BoxConstraints(
                                                  maxHeight: 200,
                                                  minHeight: 100,
                                                  minWidth: double.infinity,
                                                  maxWidth: double.infinity),
                                              context: context,
                                              builder: (context) => Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 12,
                                                                bottom: 8),
                                                        child: Container(
                                                          height: 4,
                                                          width: 13.w,
                                                          decoration: const BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      52,
                                                                      52,
                                                                      52),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10))),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          _delete(list[
                                                                      "allPost"]
                                                                  [
                                                                  index]["_id"])
                                                              .then((value) =>
                                                                  fetchData(1));
                                                        },
                                                        leading: const Icon(
                                                          Icons.delete_rounded,
                                                          color: Color.fromARGB(
                                                              255, 179, 51, 42),
                                                        ),
                                                        title: const Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    179,
                                                                    51,
                                                                    42),
                                                          ),
                                                        ),
                                                      ),
                                                      const ListTile(
                                                        leading: Icon(
                                                          Icons
                                                              .timelapse_outlined,
                                                        ),
                                                        title: Text(
                                                          "Archieve",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      const ListTile(
                                                        leading: Icon(
                                                          Icons.comment,
                                                        ),
                                                        title: Text(
                                                          "Turn off commenting",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ));
                                        },
                                        child: const Icon(
                                          Icons.more_vert_rounded,
                                          size: 22,
                                          color: Color.fromARGB(
                                              200, 255, 255, 255),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
