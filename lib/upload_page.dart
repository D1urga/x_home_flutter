import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:x_home/search_profile_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool isuploading = false;
  File? _image;
  File? img1;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      setState(() {
        img1 = File(pickedFile!.path);
      });
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<File> compressImage(File file) async {
    img.Image image = img.decodeImage(file.readAsBytesSync())!;
    img.Image smallerImage = img.copyResize(image,
        width: 600); // Resize to width 600, keep aspect ratio
    List<int> compressedBytes = img.encodeJpg(smallerImage, quality: 40);
    final tempDir = await getTemporaryDirectory();
    final compressedFile = File('${tempDir.path}/compressed_image.jpg');
    await compressedFile.writeAsBytes(compressedBytes);
    return compressedFile;
  }

  final TextEditingController controller = TextEditingController();

  Future<void> _uploadImage() async {
    setState(() {
      isuploading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id");
    final String messageContent = controller.text.trim();
    File compressedImage = await compressImage(_image!);
    if (compressedImage == null) return;

    String fileName = compressedImage!.path.split('/').last;
    FormData formData = FormData.fromMap({
      "img": await MultipartFile.fromFile(compressedImage!.path,
          filename: fileName),
      "message": messageContent,
    });

    Dio dio = new Dio();
    try {
      Response response = await dio.post(
        "https://xhomebackend.onrender.com/api/v1/post/postPost/$id",
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
              content: Text(
                'Posted .. upload another one ?',
                style: TextStyle(
                    color: Color.fromARGB(255, 53, 209, 42),
                    fontWeight: FontWeight.w500),
              )),
        );
      }
    } catch (e) {}
    setState(() {
      _image = null;
      controller.text = "";
      isuploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            centerTitle: true,
            title: const Text(
              "share post",
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              InkWell(
                onTap: () {
                  isuploading ? () => {} : _uploadImage();
                },
                child: Container(
                  width: 25.w,
                  height: 30,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 0, 0, 0),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Center(
                    child: Text(
                      isuploading ? "Posting" : "Post",
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
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
          )),
      body: SingleChildScrollView(
        child: SizedBox(
          height: 84.h,
          child: Column(
            children: [
              SizedBox(
                height: 2.h,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: controller,
                  maxLength: 300,
                  // expands: true,
                  maxLines: null,
                  minLines: null,
                  cursorWidth: 2.5,
                  cursorRadius: const Radius.circular(10),
                  cursorColor: const Color.fromARGB(255, 61, 163, 247),
                  decoration: const InputDecoration(
                      focusColor: Colors.blue,
                      filled: true,
                      hintText: "What's happening ? write here ..",
                      fillColor: Color.fromARGB(255, 250, 250, 250),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              color: Colors.transparent, width: 0.5)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide:
                              BorderSide(color: Colors.transparent, width: 3))),
                ),
              ),
              isuploading
                  ? Column(
                      children: [
                        SizedBox(
                          height: 30.h,
                        ),
                        const Text(
                          "Uploading ...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(
                      height: 0,
                      width: 0,
                    ),
              Center(
                child: _image == null
                    ? Column(
                        children: [
                          SizedBox(
                            height: 30.h,
                          ),
                          const Text(
                            'No image selected.',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 210, 210, 210)),
                          ),
                        ],
                      )
                    : !isuploading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                  height: 250,
                                  width: 80.w,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(6)),
                                    border: Border.all(
                                        width: 0,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0)),
                                    image: DecorationImage(
                                        image: FileImage(_image!),
                                        fit: BoxFit.cover),
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                              // Image.file(
                              //   _image!,
                              //   height: 100,
                              //   width: 50.w,
                              //   fit: BoxFit.cover,
                              // ),
                            ],
                          )
                        : const SizedBox(
                            height: 0,
                            width: 0,
                          ),
              ),
              const Expanded(child: SizedBox()),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Everyone can reply",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        thickness: 1.5,
                        color: Color.fromARGB(255, 140, 140, 140),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _pickImage();
                      },
                      child: const Icon(
                        Icons.image_outlined,
                        size: 23,
                        color: Color.fromARGB(255, 47, 123, 186),
                      ),
                    ),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: Color.fromARGB(255, 165, 165, 165),
                    ),
                    const Icon(
                      Icons.bar_chart_outlined,
                      size: 20,
                      color: Color.fromARGB(255, 174, 174, 174),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
