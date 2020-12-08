import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:safety_tracker_app/models/models.dart';
import 'package:safety_tracker_app/ui/views.dart';

class GroupMembers extends StatefulWidget {
  @override
  _GroupMembersState createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  final List<UserData> membersTest = <UserData>[
    new UserData(uid: "20", groupId: "2", displayName: "Test User", creationDate: DateTime.utc(2013, 7, 1), avatar: 'images/11.jpg'),
    new UserData(uid: "901", groupId: "1", displayName: "Second User", creationDate: DateTime.utc(2011, 9, 1), avatar: 'images/18.jpg'),
    new UserData(uid: "7819", groupId: "2", displayName: "Trial Test User", creationDate: DateTime.utc(2018, 11, 1), avatar: 'images/batsy.jpg'),
  ] ;


  @override
  Widget build(BuildContext context) {

    final List<Widget> memberSliders = membersTest.map((member) => Container(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                Image.asset(member.avatar, fit: BoxFit.cover, width: 1000.0),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Text(
                      '${member.displayName}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),
      ),
    )).toList();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0,0,10.0,0),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Members",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                FlatButton(
                  child: Text(
                    "View More",
                    style: TextStyle(
//                      fontSize: 22,
//                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context){
                          return GroupTrekHistory();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 10.0),

            //Slider Here

            CarouselSlider(
              options: CarouselOptions(
                  height: MediaQuery.of(context).size.height/2.4,
                autoPlay: true,
                viewportFraction: 1.0,
                //              enlargeCenterPage: true,
                //              aspectRatio: 2.0,
              ),
              items: memberSliders
            ),
            SizedBox(height: 20.0),

            // Text(
            //   "Food Categories",
            //   style: TextStyle(
            //     fontSize: 23,
            //     fontWeight: FontWeight.w800,
            //   ),
            // ),
            // SizedBox(height: 10.0),

            // Container(
            //   height: 65.0,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     shrinkWrap: true,
            //     itemCount: categories == null?0:categories.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       Map cat = categories[index];
            //       return HomeCategory(
            //         icon: cat['icon'],
            //         title: cat['name'],
            //         items: cat['items'].toString(),
            //         isHome: true,
            //       );
            //     },
            //   ),
            // ),

//             SizedBox(height: 20.0),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Text(
//                   "Popular Items",
//                   style: TextStyle(
//                     fontSize: 23,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//
//                 FlatButton(
//                   child: Text(
//                     "View More",
//                     style: TextStyle(
// //                      fontSize: 22,
// //                      fontWeight: FontWeight.w800,
//                       color: Theme.of(context).accentColor,
//                     ),
//                   ),
//                   onPressed: (){},
//                 ),
//               ],
//             ),
//             SizedBox(height: 10.0),
//
//             GridView.builder(
//               shrinkWrap: true,
//               primary: false,
//               physics: NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: MediaQuery.of(context).size.width /
//                     (MediaQuery.of(context).size.height / 1.25),
//               ),
//               itemCount: foods == null ? 0 :foods.length,
//               itemBuilder: (BuildContext context, int index) {
// //                Food food = Food.fromJson(foods[index]);
//                 Map food = foods[index];
// //                print(foods);
// //                print(foods.length);
//                 return GridProduct(
//                   img: food['img'],
//                   isFav: false,
//                   name: food['name'],
//                   rating: 5.0,
//                   raters: 23,
//                 );
//               },
//             ),
//
//             SizedBox(height: 30),
          ],
        ),
      ),


      // body: new Swiper(
      //   itemBuilder: (BuildContext context, int index){
      //     return new Card(
      //       color: Colors.white,
      //       elevation: 5.0,
      //       child: new Container(
      //         margin: EdgeInsets.all(15.0),
      //         child: new Text("${membersTest[index].displayName}"),
      //       ),
      //     );
      //     return new Image.asset(images[index], fit: BoxFit.scaleDown,);
      //   },
      //   itemCount: membersTest.length,
      //   pagination: new SwiperPagination(),
      //   control: new SwiperControl(),
      //   autoplay: true,
      // ),
    );
  }
}
