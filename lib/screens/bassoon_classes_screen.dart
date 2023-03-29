import 'package:bassoon_scheduler_app/models/bassoon_class.dart';
import 'package:bassoon_scheduler_app/screens/account_screen.dart';
import 'package:bassoon_scheduler_app/shared/nav_menu.dart';
import 'package:bassoon_scheduler_app/shared/translations.dart';
import 'package:bassoon_scheduler_app/shared/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bassoon_scheduler_app/data/shared_prefs.dart';

class BassoonClassesScreen extends StatefulWidget {
  const BassoonClassesScreen({Key? key}) : super(key: key);

  @override
  State<BassoonClassesScreen> createState() => _BassoonClassesScreenState();
}

class _BassoonClassesScreenState extends State<BassoonClassesScreen> {
  int settingColor = 0xff1976d2;
  double settingFontSize = 16;
  String settingLanguage = "PL";
  SPSettings settings = SPSettings();
  late Map<String, dynamic> translations;
  final formKey = GlobalKey<FormState>();

  final TextEditingController bassoonClassNameController =
      TextEditingController();

  @override
  void dispose() {
    bassoonClassNameController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    getSettingsAndTranslations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(translations["Somthingwong"]));
          } else if (snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(
                    backgroundColor: Color(settingColor),
                    title: Text(translations["Classes"])),
                drawer: const NavMenu(),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    showBassoonClassAddDialog(context);
                  },
                ),
                body: Container(
                  child: StreamBuilder<List<BassoonClass>>(
                      stream: readAllBassoonClasses(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text(translations["Somthingwong"]));
                        } else if (snapshot.hasData) {
                          final bassoonClasses = snapshot.data!;
                          return ListView(
                            padding: const EdgeInsets.all(8),
                            children:
                                bassoonClasses.map(buildBassoonClassesList).toList(),
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                ));
          } else {
            return AccountScreen();
          }
        });
  }

  Future<dynamic> showBassoonClassAddDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(translations["InsertClassName"]),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                          controller: bassoonClassNameController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              !RegExp(r"^[a-zA-Z0-9\sżźćńółęąśŻŹĆĄŚĘŁÓŃ]+$")
                                      .hasMatch(value!)
                                  ? translations["NoSpecialChars"]
                                  : null,
                          decoration: InputDecoration(hintText: translations["Name"])),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      bassoonClassNameController.text = '';
                    },
                    child: Text(translations["Cancel"])),
                ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        createNewBassoonClass();
                        Navigator.pop(context);
                        bassoonClassNameController.text = '';
                      }
                    },
                    child: Text(translations["Create"]))
              ]);
        });
  }

  Future createNewBassoonClass() async {
    final className = bassoonClassNameController.text.trim();
    final docBassoonClass =
        FirebaseFirestore.instance.collection("bassoon class").doc(className);
    BassoonClass bclass = BassoonClass(
      className,
      0,
      FirebaseAuth.instance.currentUser!.displayName,
      FirebaseAuth.instance.currentUser!.uid,
      <String>[]
    );
    docBassoonClass.set(bclass.toJson(true));
  }

  Stream<List<BassoonClass>> readAllBassoonClasses() =>
      FirebaseFirestore.instance.collection("bassoon class").snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => BassoonClass.fromJson(doc.data(), true))
              .toList());

  Widget buildBassoonClassesList(BassoonClass bClass) {
    bool isAssigned = false;
    for(int i=0;i<bClass.attendees!.length;i++){
      if(bClass.attendees![i]['uid'] == FirebaseAuth.instance.currentUser!.uid){
        isAssigned = true;
        break;
      }
    }
    Color joinClassIconColor;
    IconData joinClassIcon;
    if(isAssigned){
      joinClassIconColor = Colors.green;
      joinClassIcon = Icons.assignment_turned_in_rounded;
    }else{
      joinClassIconColor = Colors.blueGrey;
      joinClassIcon = Icons.assignment_return_rounded;
    }
    return ListTile(
        leading: CircleAvatar(
          child: Text(bClass.class_name.substring(0, 1).toUpperCase()),
        ),
        title: Text(bClass.class_name),
        subtitle: Text(
            "${translations["CreatedBy"]} ${bClass.created_by_name}, ${translations["Count"]} ${bClass.attendees_count}"),
        trailing: IconButton(
          icon: Icon(joinClassIcon),
          color: joinClassIconColor,
          onPressed: () {
            var myId = FirebaseAuth.instance.currentUser?.uid;
            var docRef = FirebaseFirestore.instance
                .collection('bassoon class')
                .doc(bClass.class_name);
            bool isAttending = false;
            late int deleteIndex;
            bClass.attendees?.asMap().forEach((index, element) {
              if (element['uid'] == myId) {
                deleteIndex = index;
                isAttending = true;
              }
            });

            if (isAttending) {
              bClass.attendees?.removeAt(deleteIndex);
              docRef.update({
                'attendees': bClass.attendees,
                'attendees count': FieldValue.increment(-1)
              });
            } else {
              docRef.update({
                'attendees': FieldValue.arrayUnion([
                  {
                    'name': FirebaseAuth.instance.currentUser?.displayName,
                    'uid': myId,
                  },
                ]),
                'attendees count': FieldValue.increment(1)
              });
            }
          },
        ),
        onTap: () {
          showBassoonClassInfoDialog(context, bClass.attendees);
        },
      onLongPress: (){
        if(bClass.created_by_id != FirebaseAuth.instance.currentUser!.uid)
        {
          return;
        }
        showDeleteBassoonClassDialog(context, bClass.class_name);
      },
      );
  }

  Future<dynamic> showBassoonClassInfoDialog(
      BuildContext context, List<dynamic>? attendees) async {
    String listOfAttendees = "";
    for(int i=0;i<attendees!.length;i++){
      listOfAttendees += attendees[i]['name'] + ", ";
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(translations["AttendeesList"]),
              content: Text(listOfAttendees),

              );
        });
  }

  Future<dynamic> showDeleteBassoonClassDialog(BuildContext context,
      String classNameToBeDeleted){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('${translations["Deleting"]} $classNameToBeDeleted'),
            content: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red ,
              ),
              onPressed: () async {
                bool confirmation = await confirmationDialog(context);
                if(confirmation) {
                  final docRef = FirebaseFirestore.instance.collection(
                      'bassoon class').doc(classNameToBeDeleted);
                  docRef.delete();
                }
                Navigator.pop(context);
              },
              child: Text(translations["DeletingThis"]),
            ),

          );
        });
  }

  Future<bool> confirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(translations["AreYouSure"]),
        actions: [
          TextButton(
              child: Text(translations["No"], style: const TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          TextButton(
              child: Text(translations["Yes"], style: const TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ],
      ),
    );
  }

  Future getSettingsAndTranslations() async {
    settings = SPSettings();
    settings.init().then((value) async {
      setState(() {
        settingColor = settings.getColor();
        settingFontSize = settings.getFontSize();
        settingLanguage = settings.getLanguage();
      });
      getTranslations();
    });
  }

  Future getTranslations() async{
    const String field = "classes";
    Translations translator = Translations(settingLanguage);
    translations = await translator.readTranslations(field);
  }
}
