import 'package:final_project/Search/profile_company.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AllWorkersWidget extends StatefulWidget {
  final String userID;
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String userImageUrl;

  const AllWorkersWidget(
      {required this.userID,
      required this.userName,
      required this.userEmail,
      required this.phoneNumber,
      required this.userImageUrl});

  @override
  State<AllWorkersWidget> createState() => _AllWorkersWidgetState();
}

class _AllWorkersWidgetState extends State<AllWorkersWidget> {
  // void _mailTo() async{
  //   var mailUrl = "mailto : ${widget.userEmail}";
  //   print("widget.userEmail ${widget.userEmail}");
  //
  //   if(await canLaunchUrlString(mailUrl)){
  //     await launchUrlString(mailUrl);
  //   }
  //   else{
  //     print("Error");
  //     throw "Error Occurred";
  //   }
  // }

  // void _mailTo() async {
  //   var mailUrl = "mailto: ${widget.userEmail}";
  //   print("widget.userEmail ${widget.userEmail}");
  //
  //   if (await canLaunchUrlString(mailUrl)) {
  //     await launchUrlString(mailUrl);
  //   } else {
  //     print("error");
  //     throw "error Occurred";
  //   }
  // }
  // void _mailTo() async{
  //   var mailUrl = "mailto: ${widget.userEmail}";
  //   print("widget.userEmail ${widget.userEmail}");
  //
  //   if(await canLaunchUrlString(mailUrl)){
  //     await launchUrlString(mailUrl);
  //
  //   }
  //   else{
  //     print("Error");
  //     throw "Error Occurred";
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white,
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userID: widget.userID),
              ));
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.only(right: 12),
          decoration:
              const BoxDecoration(border: Border(right: BorderSide(width: 1))),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Image.network(widget.userImageUrl == null
                ? "https://w7.pngwing.com/pngs/782/115/png-transparent-avatar-boy-man-avatar-vol-1-icon-thumbnail.png"
                : widget.userImageUrl),
          ),
        ),
        title: Text(
          widget.userName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              "Visit Profile",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        trailing: IconButton(
            onPressed: () {
              // _mailTo();
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.black,
            )),
      ),
    );
  }
}
