import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uas_deva/app_color.dart';
import 'package:uas_deva/create_task_screen.dart';
import 'package:uas_deva/widget_background.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NounsApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColor().colorSecondary,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  final Firestore firestore = Firestore.instance;
  final AppColor appColor = AppColor();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;

    return Scaffold(
      key: scaffoldState,
      backgroundColor: appColor.colorPrimary,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            WidgetBackground(),
            _buildWidgetListTodo(widthScreen, heightScreen, context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTaskScreen(isEdit: false)));
          if (result != null && result) {
            scaffoldState.currentState.showSnackBar(SnackBar(
              content: Text('Purchaser has been created'),
            ));
            setState(() {});
          }
        },
        backgroundColor: appColor.colorTertiary,
      ),
    );
  }

  Container _buildWidgetListTodo(double widthScreen, double heightScreen, BuildContext context) {
    return Container(
      width: widthScreen,
      height: heightScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Text(
              'Noun Project',
              style: Theme
                  .of(context)
                  .textTheme
                  // ignore: deprecated_member_use
                  .title,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('tasks').orderBy('date').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data.documents[index];
                    Map<String, dynamic> task = document.data;
                    int totalHarga = task['jumlah'] * task['ongkos'];
                    String strDate = task['date'];
                    
                    final oCcy = new NumberFormat("#,##0.00", "en_US");
                    String formatted = oCcy.format(totalHarga);
                   
                    return Card(
                      child: ListTile(
                        title: Text(task['name'] + ' | ' + task['description'])  ,
                        subtitle: Text(
                            'Harga : Rp.' + formatted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: false,
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                color: appColor.colorSecondary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${int.parse(strDate.split(' ')[0])}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              strDate.split(' ')[1],
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (BuildContext context) {
                            return List<PopupMenuEntry<String>>()
                              ..add(PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ))..add(PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ));
                          },
                          onSelected: (String value) async {
                            if (value == 'edit') {
                              bool result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return CreateTaskScreen(
                                    isEdit: true,
                                    documentId: document.documentID,
                                    name: task['name'],
                                    description: task['description'],
                                    date: task['date'],
                                    jumlah : task["jumlah"],
                                    ongkos : task['ongkos']
                                  );
                                }),
                              );
                              if (result != null && result) {
                                scaffoldState.currentState.showSnackBar(SnackBar(
                                  content: Text('Purchaser has been updated'),
                                ));
                                setState(() {});
                              }
                            } else if (value == 'delete') {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Are You Sure'),
                                    content: Text('Do you want to delete ${task['name']}?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('No'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('Delete'),
                                        onPressed: () {
                                          document.reference.delete();
                                          Navigator.pop(context);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Icon(Icons.more_vert),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

