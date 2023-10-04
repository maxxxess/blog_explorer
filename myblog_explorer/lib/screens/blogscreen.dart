import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:myblog_explorer/const/const.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:myblog_explorer/model/model.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  bool isFavorite = false;

  List<bool> isFavoriteList = List.generate(1000, (index) => false);
  bool isLoading = true;
  final String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
  final String adminSecret =
      '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';
  List<Blogs> allData = [];
  late Blogs blog;

  Future<void> cacheImages(List<Blogs> items) async {
    final fileCacheManager = DefaultCacheManager();
    for (final item in items) {
      await fileCacheManager.downloadFile(item.imageUrl);
    }
  }

  fetchData() async {
    try {
      var response = await http.get(Uri.parse(url), headers: {
        'x-hasura-admin-secret': adminSecret,
      });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        for (var i in data['blogs']) {
          blog =
              Blogs(id: i['id'], title: i['title'], imageUrl: i['image_url']);
          setState(() {
            allData.add(blog);
            isLoading = false;
          });
        }
      }
    } catch (e) {}
  }

  @override
  void initState() {
    fetchData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Blog Explorer',
            style: myStyle(Colors.white, 20, FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(
                child: SpinKitWave(
                  color: Colors.black,
                  size: 50.0,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.black87, Colors.white70],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: allData.length,
                  itemBuilder: (context, index) {
                    final blog = allData[index];

                    return InkWell(
                      onTap: () {
                        _customshowDialog(blog);
                        // Navigate to the blog detail page or perform any other action
                        // when a blog is tapped.
                      },
                      child: isLoading
                          ? Center(
                              child: SpinKitWave(
                                color: Colors.blue,
                                size: 10.0,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                      colors: [Colors.black87, Colors.white70],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter)),
                              margin: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(children: [
                                      Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: Image(
                                            image: CachedNetworkImageProvider(
                                                allData[index].imageUrl),
                                            fit: BoxFit.cover,
                                          )),
                                      Positioned(
                                          top: 5,
                                          right: 10,
                                          child: IconButton(
                                            icon: Icon(
                                              isFavoriteList[index]
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavoriteList[index]
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isFavoriteList[index] =
                                                    !isFavoriteList[index];
                                              });
                                            },
                                          ))
                                    ]),
                                    flex: 6,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: Text(
                                        '${blog.title}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    flex: 2,
                                  )
                                ],
                              ),
                            ),
                    );
                  },
                ),
              ));
  }

  void _customshowDialog(Blogs blog) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            Card(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.60,
                    width: double.infinity,
                    child: Image(
                      image: CachedNetworkImageProvider(blog.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: Text(
                      blog.title,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
