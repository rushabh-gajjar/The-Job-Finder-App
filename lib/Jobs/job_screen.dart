import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Search/search_job.dart';
import 'package:final_project/Widgets/bottom_nav_bar.dart';
import 'package:final_project/Widgets/job_widgets.dart';
import 'package:final_project/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Persistent/persistent.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({Key? key}) : super(key: key);

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  //
  String? jobCategoryFilter;

  //
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  //
  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              "Job Category",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Persistent.jobCategoryList.length,
                itemBuilder: (ctx, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        jobCategoryFilter = Persistent.jobCategoryList[index];
                      });
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                      print(
                          "jobCategoryList[index],${Persistent.jobCategoryList[index]}");
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Persistent.jobCategoryList[index],
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      jobCategoryFilter = null;
                    });
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text(
                    "Cancel Filter",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Persistent persistenceObject = Persistent();
    persistenceObject.getMyData();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      // decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //         colors: [Colors.deepOrangeAccent.shade200, Colors.blueAccent],
      //         begin: Alignment.centerLeft,
      //         end: Alignment.centerRight,
      //         stops: const [0.2, 0.9])),
      child: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: BottomNavBarApp(
            indexNum: 0,
          ),
          appBar: AppBar(
            title: const Text(
              "Job Screen",
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              color: Colors.white,
              // decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //         colors: [
              //           Colors.deepOrangeAccent.shade200,
              //           Colors.blueAccent
              //         ],
              //         begin: Alignment.centerLeft,
              //         end: Alignment.centerRight,
              //         stops: const [0.2, 0.9])),
            ),
            automaticallyImplyLeading: false,
            leading: IconButton(
                onPressed: () {
                  _showTaskCategoriesDialog(size: size);
                },
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.black,
                )),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SearchJobScreen()));
                  },
                  icon: const Icon(
                    Icons.search_outlined,
                    color: Colors.black,
                  )),
            ],
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("jobs")
                .where("jobCategory", isEqualTo: jobCategoryFilter)
                .where("recruitment", isEqualTo: true)
                .orderBy("createdAt", descending: false)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.active) {
                //..........................................................//
                //..........................................................//
                //..........................................................//
                if (snapshot.data?.docs.isNotEmpty == true) {
                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return JobWidgets(
                        jobTitle: snapshot.data?.docs[index]["jobTitle"],
                        jobDescription: snapshot.data?.docs[index]
                            ["jobDescription"],
                        jobId: snapshot.data?.docs[index]["jobId"],
                        uploadedBy:
                            snapshot.data.docs[index]["uploadedBy"].toString(),
                        userImage: snapshot.data?.docs[index]["userImage"],
                        name: snapshot.data?.docs[index]["name"],
                        recruitment: snapshot.data?.docs[index]["recruitment"],
                        email: snapshot.data.docs[index]["email"].toString(),
                        location: snapshot.data?.docs[index]["location"],
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              );
            },
          )),
    );
    // return Container(
    //   decoration: BoxDecoration(
    //     gradient: LinearGradient(colors: [Colors.deepOrangeAccent.shade200,Colors.blueAccent],
    //     begin: Alignment.centerLeft,
    //     end: Alignment.centerRight,
    //     stops: [0.2,0.9])
    //   ),
    //   bod
    //   // child: Scaffold(
    //   //   bottomNavigationBar: BottomNavBarApp(indexNum:0 ),
    //   //   backgroundColor: Colors.transparent,
    //   //   appBar: AppBar(
    //       title: Text("Job Screen",
    //       ),
    //      centerTitle: true,
    //      flexibleSpace: Container(
    //        decoration: BoxDecoration(
    //            gradient: LinearGradient(colors: [Colors.deepOrangeAccent.shade200,Colors.blueAccent],
    //                begin: Alignment.centerLeft,
    //                end: Alignment.centerRight,
    //                stops: [0.2,0.9])
    //        ),
    //      ),
    //       automaticallyImplyLeading: false,
    //       leading: IconButton(onPressed:(){
    //         _showTaskCategoriesDialog(size: size);
    //       }, icon:Icon(Icons.filter_list_rounded,color: Colors.black,)),
    //       actions: [
    //         IconButton(onPressed: (){
    //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>SearchJobScreen()));
    //         }, icon: Icon(Icons.search_outlined,color: Colors.black,))
    //       ],
    // //     ),
    //     body: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
    //       stream: FirebaseFirestore.instance
    //           .collection("jobs")
    //           .where("jobCategory",isEqualTo: jobCategoryFilter)
    //           . where("recruitment",isEqualTo: true)
    //       .orderBy("createdAt",descending: false)
    //       .snapshots(),
    //       builder: (context,AsyncSnapshot snapshot){
    //         if(snapshot.connectionState == ConnectionState.waiting){
    //           return
    //               Center(
    //                 child: CircularProgressIndicator(),
    //               );
    //
    //         }else if(snapshot.connectionState == ConnectionState.active){
    //           //..........................................................//
    //           //..........................................................//
    //           //..........................................................//
    //           if(snapshot.data.docs.isNotEmpty == true){
    //             return ListView.builder(
    //               itemCount: snapshot.data.docs.length,
    //               itemBuilder: (BuildContext context, int index){
    //                 return JobWidgets(
    //                   jobTitle: snapshot.data.docs[index]["jobTitle"],
    //                   jobDescription: snapshot.data.docs[index]["jobDescription"],
    //                   jobId: snapshot.data.docs[index]["jobId"],
    //                   uploadedBy: snapshot.data.docs[index]["uploadedBy"].toString(),
    //                   userImage: snapshot.data.docs[index]["userImage"],
    //                   name: snapshot.data.docs[index]["name"],
    //                   recruitment: snapshot.data.docs[index]["recruitment"],
    //                   email: snapshot.data.docs[index]["email"].toString(),
    //                   location: snapshot.data.docs[index]["location"],
    //
    //
    //
    //
    //                 );
    //               },
    //             );
    //           }else{
    //             return Center(
    //               child: Text("There is no jobs"),
    //             );
    //           }
    //
    //         }
    //         return Center(
    //           child: Text(
    //             "Something went wrong",
    //             style: TextStyle(
    //               fontWeight: FontWeight.bold,
    //               fontSize: 30
    //             ),
    //           ),
    //         );
    //       },
    //     )
    //
    //   ),
    // );
  }
}
