import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Jobs/job_screen.dart';
import 'package:final_project/Widgets/job_widgets.dart';
import 'package:flutter/material.dart';

class SearchJobScreen extends StatefulWidget {
  const SearchJobScreen({Key? key}) : super(key: key);

  @override
  State<SearchJobScreen> createState() => _SearchJobScreenState();
}

class _SearchJobScreenState extends State<SearchJobScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = "Search query";

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: "Search for jobs...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black, fontSize: 16.0),
      ),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      IconButton(
        onPressed: () {
          _clearSearchQuery();
        },
        icon: const Icon(
          Icons.clear,
          color: Colors.black,
        ),
      )
    ];
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //     gradient: LinearGradient(colors: [Colors.deepOrangeAccent.shade200,Colors.blueAccent],
      //         begin: Alignment.centerLeft,
      //         end: Alignment.centerRight,
      //         stops: const [0.2,0.9])
      // ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          flexibleSpace: Container(
            color: Colors.white,
            // decoration: BoxDecoration(
            //     gradient: LinearGradient(colors: [Colors.deepOrangeAccent.shade200,Colors.blueAccent],
            //         begin: Alignment.centerLeft,
            //         end: Alignment.centerRight,
            //         stops: const [0.2,0.9])
            // ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobScreen(),
                  ));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          title: _buildSearchField(),
          actions: _buildActions(),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("jobs")
              .where("jobTitle", isGreaterThanOrEqualTo: searchQuery)
              .where("recruitment", isEqualTo: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data.docs.isNotEmpty == true) {
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return JobWidgets(
                      jobTitle: snapshot.data.docs[index]['jobTitle'],
                      jobDescription: snapshot.data.docs[index]
                          ["jobDescription"],
                      jobId: snapshot.data.docs[index]["jobId"],
                      uploadedBy:
                          snapshot.data.docs[index]["uploadedBy"].toString(),
                      userImage: snapshot.data.docs[index]["userImage"],
                      name: snapshot.data.docs[index]["name"],
                      recruitment: snapshot.data.docs[index]["recruitment"],
                      email: snapshot.data.docs[index]["email"].toString(),
                      location: snapshot.data.docs[index]["location"],
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("There is no jobs"),
                );
              }
            }
            return const Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}
