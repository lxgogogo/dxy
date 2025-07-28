import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';

import '../../../../model/course_model.dart';
import '../../../widget/common_html/common_html_widget.dart';
import 'course_knowledge_video_view.dart';
import 'course_progress_view.dart';

class CourseDetailKnowledgeItem extends StatelessWidget {
  final CourseModel item;
  final VoidCallback? onTap;
  final Function(int index)? onSelectItem;

  const CourseDetailKnowledgeItem({
    super.key,
    required this.item,
    this.onTap,
    this.onSelectItem,
  });

  @override
  Widget build(BuildContext context) {
    final knowledgeIndexDtoList = item.knowledgeIndexDtoList ?? [];
    final currentIndex = knowledgeIndexDtoList.indexWhere((element) => element.isSelected == true);
    final knowledgeIndexDto = currentIndex >= 0 ? knowledgeIndexDtoList[currentIndex] : null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: '#58A5FF'.hexColor.withOpacity(0.1),
              blurRadius: 8.63.r,
              offset: Offset(0, 4.32.w),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 8.w,
              children: [
                SvgPicture.asset(
                  Assets.svg.iconKnowledge,
                  width: 16.w,
                  height: 16.w,
                ),
                Text(
                  '知识',
                  style: TextStyle(
                    color: '#000000'.hexColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.w),
            Text(
              item.infoTitle ?? '',
              style: TextStyle(
                color: '#000000'.hexColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.w),
            if (knowledgeIndexDto?.contentArticle != null)
              ClipRect(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    HeightLimiter(
                      maxHeight: 166.w,
                      child: CommonHtmlWidget(
                        content: knowledgeIndexDto?.contentArticle?.content ?? '',
                      ),
                    ),
                    Positioned(
                      bottom: 12.w,
                      child: GestureDetector(
                        onTap: onTap,
                        child: Container(
                          height: 28.w,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: '#557BF6'.hexColor.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '查看全文',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (knowledgeIndexDto?.contentVideo != null)
              KnowledgeVideoView(
                contentVideo: knowledgeIndexDto?.contentVideo,
                onTapDetail: onTap,
              ),
            SizedBox(height: 12.w),
            CourseProgressView(
              item: item,
              onSelectItem: onSelectItem,
            ),
          ],
        ),
      ),
    );
  }
}
