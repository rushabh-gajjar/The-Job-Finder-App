import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Widgets/all_companies_widget.dart';
import 'package:final_project/Widgets/bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllWorkersScreen extends StatefulWidget {
  const AllWorkersScreen({Key? key}) : super(key: key);

  @override
  State<AllWorkersScreen> createState() => _AllWorkersScreenState();
}

class _AllWorkersScreenState extends State<AllWorkersScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = "Search query";

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: "Search for companies...",
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
        bottomNavigationBar: BottomNavBarApp(indexNum: 1),
        backgroundColor: Colors.white,
        appBar: AppBar(
          flexibleSpace: Container(
            color: Colors.white,

            // decoration: BoxDecoration(
            //     gradient: LinearGradient(colors: [Colors.deepOrangeAccent.shade200,Colors.blueAccent],
            //         begin: Alignment.centerLeft,
            //         end: Alignment.centerRight,
            //         stops: const [0.2,0.9])
            // ),
          ),
          title: _buildSearchField(),
          actions: _buildActions(),
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("name", isGreaterThanOrEqualTo: searchQuery)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AllWorkersWidget(
                      userID: snapshot.data!.docs[index]["id"],
                      userName: snapshot.data!.docs[index]["name"],
                      userEmail: snapshot.data!.docs[index]["email"],
                      phoneNumber: snapshot.data!.docs[index]["phoneNumber"],
                      userImageUrl: snapshot.data!.docs[index]["userImage"],
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("There is no users"),
                );
              }
            }
            return const Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            );
          },
        ),
      ),
    );
  }
}
