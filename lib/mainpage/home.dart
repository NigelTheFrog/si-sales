import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String user_id = "", meme_id = "";

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  bool isLiked = false;
  String color = "0xffC0C0C0";

  Future<String> fetchData() async {
    final response = await http
        .get(Uri.https("ubaya.fun", "/flutter/160419017/memelist.php"));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Future<String> isLike() async {
    final response = await http
        .get(Uri.https("ubaya.fun", "/flutter/160419017/memelist.php"));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  // void _creatememe() {
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (context) => CreateMeme(userid: user_id)));
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loaddata();
  }

  void likeButton(String meme_id) async {
    
    if (isLiked == true) {
      final response = await http.post(
          Uri.parse("https://ubaya.fun/flutter/160419017/minuslikepost.php"),
          body: {'user_id': user_id, 'meme_id': meme_id});
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
      }
      setState(() {
        isLiked = false;
        color = "0xffC0C0C0";
      });
    } else if (isLiked == false) {
      final response = await http.post(
          Uri.parse("https://ubaya.fun/flutter/160419017/addlikepost.php"),
          body: {'user_id': user_id, 'meme_id': meme_id, });
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
      }
      setState(() {
        isLiked = true;
        color = "0xffff0000";
      });
    }
    ;
  }

  loaddata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = (prefs.getString('user_id') ?? '');
    });

    return user_id;
  }

  // Widget daftarmeme(data) {
  //   List<Meme> meme2 = [];
  //   Map json = jsonDecode(data);
  //   for (var mov in json['data']) {
  //     Meme meme = Meme.fromJson(mov);
  //     meme2.add(meme);
  //   }
  //   return ListView.builder(
  //       itemCount: meme2.length,
  //       itemBuilder: (BuildContext ctxt, int index) {
  //         return Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Card(
  //                 child: Container(
  //                     width: 300,
  //                     height: 250,
  //                     child: Column(children: [
  //                       Container(
  //                         width: 300,
  //                         height: 200,
  //                         alignment: Alignment.topCenter,
  //                         child: Stack(children: [
  //                           Align(
  //                               alignment: Alignment.center,
  //                               child: Container(
  //                                   decoration: BoxDecoration(
  //                                       image: DecorationImage(
  //                                 image: NetworkImage(meme2[index].picture),
  //                                 fit: BoxFit.fill,
  //                                 // alignment: Alignment.topCenter,
  //                               )))),
  //                           Align(
  //                             alignment: Alignment.topCenter,
  //                             child: Text(meme2[index].toptext,
  //                                 textAlign: TextAlign.center,
  //                                 style: TextStyle(
  //                                     color: Colors.white,
  //                                     fontSize: 20,
  //                                     fontWeight: FontWeight.bold)),
  //                           ),
  //                           Align(
  //                               alignment: Alignment.bottomCenter,
  //                               child: Text(meme2[index].bottomtext,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                       color: Colors.white,
  //                                       fontSize: 20,
  //                                       fontWeight: FontWeight.bold))),
  //                         ]),
  //                       ),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Row(
  //                             children: [
  //                               IconButton(
  //                                 icon: const Icon(Icons.favorite),
  //                                 color: Color(int.parse(color)),
  //                                 tooltip: 'Like',
  //                                 onPressed: () {
  //                                   setState(() {
  //                                     likeButton(meme2[index].id);
  //                                   });
  //                                 },
  //                               ),
  //                               TextButton(
  //                                   style: ElevatedButton.styleFrom(
  //                                     backgroundColor: Colors.white,
  //                                   ),
  //                                   onPressed: (() {}),
  //                                   child: Text(
  //                                     'Like ${meme2[index].likes.toString()}',
  //                                     style: TextStyle(
  //                                         color: Color(0xffC0C0C0),
  //                                         fontSize: 16),
  //                                   ))
  //                             ],
  //                           ),
  //                           IconButton(
  //                             icon: const Icon(Icons.chat),
  //                             color: Colors.blue,
  //                             tooltip: 'Comment',
  //                             onPressed: () {
  //                               setState(() {
  //                                 Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                     builder: (context) =>
  //                                         DetailMeme(meme_id: meme2[index].id),
  //                                   ),
  //                                 );
  //                               });
  //                             },
  //                           )
  //                         ],
  //                       )
  //                     ])))
  //           ],
  //         );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(children: <Widget>[
        // Container(
        //     height: MediaQuery.of(context).size.height,
        //     child: FutureBuilder(
        //         future: fetchData(),
        //         builder: (context, snapshot) {
        //           if (snapshot.hasData) {
        //             return daftarmeme(snapshot.data.toString());
        //           } else {
        //             return Center(child: CircularProgressIndicator());
        //           }
        //         }))
      ]),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _creatememe,
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
