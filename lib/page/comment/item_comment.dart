import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';

class CommentItem extends StatefulWidget {
  const CommentItem({super.key});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.network(
            'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
            width: 40.px,
            height: 40.px,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          width: 10.px,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '用户昵称',
              style: TextStyle(color: Color(0xff3B5078), fontSize: 13.px),
            ),
            SizedBox(height: 3.px),
            Text(
              '阿丽塔概念设计图曝光 女主身体内部如同艺术品',
              style: TextStyle(
                  color: const Color(0xff333333), fontSize: 14.px, height: 1.5),
            ),
            SizedBox(height: 5.px,),
            Container(
                padding: EdgeInsets.only(left: 9.px),
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            width: 3.px,
                            color: Colors.black.withOpacity(0.05)))),
                child: Container(
                  padding: EdgeInsets.all(10.px),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.all(Radius.circular(10.px))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('用户1：说的好',
                          style: TextStyle(
                              color: Color(0xff666666),
                              fontSize: 14.px,
                              height: 2.0)),
                      Text('用户2：说的好回复评论说的好回复评论说的好回复评论',
                          style: TextStyle(
                              color: Color(0xff666666),
                              fontSize: 14.px,
                              height: 2.0))
                    ],
                  ),
                )),
            // Row(children: [
            //   Container(
            //     width: 3.px,
            //     color: Colors.black.withOpacity(0.05),
            //   ),
            //   Expanded(child: Container(
            //     child: Column(children: [
            //       Text('用户1：说的好'),
            //       Text('用户2：说的好回复评论说的好回复评论说的好回复评论')
            //     ],),
            //   ))
            //   ,
            // ],),
            SizedBox(
              height: 10.px,
            ),
            Row(
              children: [
                Text(
                  '2-24 12:22',
                  style: TextStyle(color: Color(0xff999999), fontSize: 14.px),
                ),
                const Spacer(),
                Image.asset(
                  'assets/images/reply.png',
                  width: 20.px,
                  height: 20.px,
                ),
                SizedBox(
                  width: 5.px,
                ),
                Text(
                  '1300',
                  style: TextStyle(
                    color: const Color(0xff999999),
                    fontSize: 14.px,
                  ),
                ),
                SizedBox(
                  width: 30.px,
                ),
                Image.asset(
                  'assets/images/praise.png',
                  width: 18.px,
                  height: 18.px,
                ),
                SizedBox(
                  width: 5.px,
                ),
                Text(
                  '16',
                  style: TextStyle(
                    color: const Color(0xff999999),
                    fontSize: 14.px,
                  ),
                )
              ],
            ),
            Container(
              height: 1.px,
              margin: EdgeInsets.symmetric(vertical: 20.px),
              color: Colors.black.withOpacity(0.1),
            )
          ],
        ))
      ],
    );
  }
}
