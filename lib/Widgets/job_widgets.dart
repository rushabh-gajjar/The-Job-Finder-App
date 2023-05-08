import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Jobs/job_details.dart';
import 'package:final_project/Services/global_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class JobWidgets extends StatefulWidget {
  final String jobTitle;
  final String jobDescription;
  final String jobId;
  final String uploadedBy;
  final String userImage;
  final String name;
  final bool recruitment;
  final String email;
  final String location;

  const JobWidgets({
    required this.jobTitle,
    required this.jobDescription,
    required this.jobId,
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location,
  });

  @override
  State<JobWidgets> createState() => _JobWidgetsState();
}

class _JobWidgetsState extends State<JobWidgets> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _deleteDialog() {
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () async {
                    try {
                      if (widget.uploadedBy == _uid) {
                        await FirebaseFirestore.instance
                            .collection("jobs")
                            .doc(widget.jobId)
                            .delete();
                        await Fluttertoast.showToast(
                            msg: "Job has been deleted",
                            toastLength: Toast.LENGTH_LONG,
                            backgroundColor: Colors.grey,
                            fontSize: 18.0);

                        Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : null;
                      } else {
                        GlobalMethod.showErrorDialog(
                            error: "You cannot perform this action", ctx: ctx);
                      }
                    } catch (error) {
                      GlobalMethod.showErrorDialog(
                          error: "This task cannot be deleted", ctx: ctx);
                    } finally {}
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      )
                    ],
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(
                uploadedBy: widget.uploadedBy,
                jobID: widget.jobId,
              ),
            ));
      },
      onLongPress: () {
        _deleteDialog();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(5, 5),
                  spreadRadius: 5,
                  blurRadius: 5)
            ],
            gradient: const LinearGradient(
                colors: [Colors.white, Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9]),
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assests/WhatsApp Image 2023-05-02 at 15.20.11.jpeg'),
            fit: BoxFit.cover)
          ),
          height: 150,
          margin: const EdgeInsets.only(left: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      widget.jobTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.indigo,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 5, top: 4),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Container(
                      height: 90,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(widget.userImage),
                              fit: BoxFit.cover),
                          border: Border.all(width: 3.0, color: Colors.white)),
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              widget.jobDescription,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
    // return Card(
    //   color: Colors.white24,
    //   elevation: 8,
    //   margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    //   child: ListTile(
    //     onTap: () {
    //       Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => JobDetailScreen(
    //         uploadedBy: widget.uploadedBy,
    //         jobID: widget.jobId ,
    //       ),));
    //     },
    //     onLongPress: () {
    //       _deleteDialog();
    //     },
    //     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //     leading: Container(
    //       padding: const EdgeInsets.only(right: 12),
    //       decoration: const BoxDecoration(
    //           border: Border(
    //         right: BorderSide(width: 1),
    //       )),
    //       child: Image.network(widget.userImage),
    //     ),
    //     title: Text(
    //       widget.jobTitle,
    //       maxLines: 2,
    //       overflow: TextOverflow.ellipsis,
    //       style: const TextStyle(
    //           color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
    //     ),
    //     subtitle: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       children: [
    //         Text(
    //           widget.name,
    //           maxLines: 2,
    //           overflow: TextOverflow.ellipsis,
    //           style: const TextStyle(
    //               color: Colors.black,
    //               fontSize: 13,
    //               fontWeight: FontWeight.bold),
    //         ),
    //         const SizedBox(
    //           height: 8,
    //         ),
    //         Text(
    //           widget.jobDescription,
    //           maxLines: 4,
    //           overflow: TextOverflow.ellipsis,
    //           style: const TextStyle(
    //             color: Colors.black,
    //             fontSize: 15,
    //           ),
    //         ),
    //       ],
    //     ),
    //     trailing: const Icon(
    //       Icons.keyboard_arrow_right,
    //       size: 30,
    //       color: Colors.black,
    //     ),
    //   ),
    // );
  }
}
