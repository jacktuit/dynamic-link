import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';


import 'firebase_repo.dart';

class MyBooks extends StatefulWidget {
  const MyBooks({Key? key}) : super(key: key);

  @override
  State<MyBooks> createState() => _MyBooksState();

  static Future<String?> getDynamicUrl(String link) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    try {
      String? _linkMessage;

      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: "http://exampleoson.page.link",
        link: Uri.parse(link),
        androidParameters: AndroidParameters(
          packageName: 'com.example.example',

        ),


        iosParameters:
        // IosParameters(bundleId: 'com.xmed', appStoreId: '1580909766'),
        IOSParameters(bundleId: 'com.xmed', appStoreId: '1580909766',minimumVersion: "1"),
        // navigationInfoParameters:NavigationInfoParameters(forcedRedirectEnabled: true),

      );

      Uri url;

      ShortDynamicLink shortDynamicLink = await dynamicLinks.buildShortLink(parameters);
      // ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
      url = shortDynamicLink.shortUrl;

      _linkMessage = Uri.decodeFull(url.toString());
      print("_linkMessage");
      print(_linkMessage);

      return _linkMessage;
    } catch (e) {
      return null;
    }
  }


}

class _MyBooksState extends State<MyBooks> {

  @override
  Widget build(BuildContext context) {
    final moviesRef = FirebaseFirestore.instance
        .collection('bookId')
        .withConverter<Book>(
      fromFirestore: (snapshots, index) => Book.fromJson(snapshots.data()!),
      toFirestore: (movie, index) => movie.toJson(),
    );

    return Scaffold(

      body:


      StreamBuilder<QuerySnapshot<Book>>(
          stream: moviesRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Loading...');
            }
            if (snapshot.hasError) {
              return const Text('Something went wrong.');
            }
            final data = snapshot.requireData;
            return ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 12,
                  );
                },
                itemCount: data.size,
                itemBuilder: (BuildContext context, int index) {
                  return buildUIMovie(snapshot.data!.docs[index].data(),context);
                });
          }),
    );
  }

  @override
  Widget buildUIMovie(Book movie,BuildContext context) {
    return InkWell(
      onTap: (){
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewShow(name: movie.number.toString(), price: movie.price.toString(),)));
      },
      child: Container(
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            clipBehavior: Clip.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 12,
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      movie.name.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        MyBooks.getDynamicUrl("http://exampleoson.page.link"+"${movie.name.toString()}");
                      },

                      child: Text(
                        movie.number.toString(),
                        style: TextStyle(fontSize: 22, color: Colors.lightBlueAccent),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        buildDynamicLinks(movie.name.toString(), movie.number.toString(), movie.id.toString());
                      },
                      child: Text(
                        movie.id.toString(),
                        style: TextStyle(fontSize: 22, color: Colors.lightBlueAccent),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildDynamicLinks(String title,String image,String docId) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    String url = "http://exampleoson.page.link";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      link: Uri.parse('$url/$docId'),
      androidParameters: AndroidParameters(
        packageName: "com.example.example",
        minimumVersion: 0,
      ),
      // iosParameters: IosParameters(
      //   bundleId: "Bundle-ID",
      //   minimumVersion: '0',
      // ),
      socialMetaTagParameters: SocialMetaTagParameters(
          description: '',
          imageUrl:
          Uri.parse("$image"),
          title: title),
    );
    ShortDynamicLink shortDynamicLink = await dynamicLinks.buildShortLink(parameters);


    String? desc = shortDynamicLink.shortUrl.toString();
    print(desc);

    // await Share.share(desc, subject: title,);

  }
}
