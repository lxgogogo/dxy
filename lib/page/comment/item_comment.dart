import 'package:flutter/material.dart';
import 'package:holdem/model/comment_list.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatefulWidget {
  CommentBean commentBean;
  CommentItem({super.key, required this.commentBean});

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
        SizedBox(
          width: 40.px,
          height: 40.px,
          child: ClipOval(
            child: Image.network(
              widget.commentBean.user!.avatar!,
              width: 40.px,
              height: 40.px,
              // fit: BoxFit.cover,
            ),
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
              widget.commentBean.user!.nickname!,
              style: TextStyle(color: Color(0xff3B5078), fontSize: 13.px),
            ),
            SizedBox(height: 3.px),
            Text(
              widget.commentBean.contentStr ?? '',
              style: TextStyle(
                  color: const Color(0xff333333), fontSize: 14.px, height: 1.5),
            ),
            SizedBox(
              height: 5.px,
            ),
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
                  widget.commentBean.createdAt!=null ? DateFormat('MM-dd hh:mm').format(widget.commentBean.createdAt!):'',
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
                  widget.commentBean.replyCount!.toString(),
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
                  widget.commentBean.likeCount!.toString(),
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
