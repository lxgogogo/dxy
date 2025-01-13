import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/item_comment.dart';
import 'package:holdem/widget/linear_card.dart';

import '../gen/assets.gen.dart';
import '../model/board_list.dart';
import 'feed_more_action.dart';

class FeedItem extends StatelessWidget {
  final BoardBean item;
  final bool isMyPost;
  final VoidCallback? onShield;
  final VoidCallback? onShieldUser;
  final VoidCallback? onReport;

  const FeedItem(
    this.item, {
    super.key,
    this.isMyPost = false,
    this.onShield,
    this.onShieldUser,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              BorderAvatar(avatar: item.user?.avatar ?? ''),
              SizedBox(width: 8.w),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      item.user?.nickname ?? '',
                      style: TextStyle(
                        color: const Color(0xff2a2a2a),
                        fontSize: 12.sp,
                      ),
                    ),
                    if (item.sign?.isNotEmpty == true) tagWidget(item.sign!),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if ((onShield != null || onShieldUser !=null ) && !UserStore.of.isMe(item.user?.id))
                FeedMoreAction(
                  onShield: onShield,
                  onShieldUser: onShieldUser,
                  onReport: onReport,
                ),
            ],
          ),
          SizedBox(height: 8.w),
          Text(
            item.title ?? '',
            style: TextStyle(
              color: const Color(0xff2a2a2a),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.pureText?.isNotEmpty == true)
            Text(
              item.pureText ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xff666666),
              ),
              softWrap: true,
            ),
          if (item.files?.isNotEmpty == true)
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final itemWidth = (constraints.maxWidth - 12.w * 2) / 2.2;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(top: 8.w),
                  child: Row(
                    children: List.generate(
                      item.files?.length ?? 0,
                      (index) {
                        final fileItem = item.files![index];
                        return Container(
                          width: itemWidth,
                          margin: EdgeInsets.only(right: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: getFilesUrl(fileItem),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                  errorWidget: (context, url, error) =>
                                      Assets.images.imageLoadingDef.image(fit: BoxFit.fill),
                                ),
                                if (fileItem.type == 'video')
                                  Center(
                                    child: Assets.images.playBtn.image(
                                      width: 32.w,
                                      height: 32.w,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          SizedBox(height: 16.w),
          Row(
            children: [
              Expanded(
                child: CountLike(count: item.likeCount?.abbreviateNumber ?? '0'),
              ),
              Expanded(
                child: CountComment(count: item.commentCount?.abbreviateNumber ?? '0'),
              ),
              Expanded(
                child: CountFavorite(count: item.favoriteCount?.abbreviateNumber ?? '0'),
              ),
              Expanded(
                child: CountShare(count: item.shareCount?.abbreviateNumber ?? '0'),
              ),
            ],
          ),
        ],
      ),
    );
    return GestureDetector(
      onTap: () {
        if (item.relType != null && item.relType!.isNotEmpty) {
          if (item.relType == 'content') {
            Get.toNamed(Routes.articleDetail, arguments: item.id ?? 0);
          } else if (item.relType == 'comment') {}
        } else {
          Get.toNamed(Routes.feedDetail, arguments: item.id ?? 0);
        }
      },
      child: isMyPost
          ? Container(
              margin: EdgeInsets.fromLTRB(10.w, 12.w, 10.w, 0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: child,
            )
          : LinearCard(
              padding: EdgeInsets.only(bottom: 2.w),
              margin: EdgeInsets.only(top: 10.w, left: 16.w, right: 16.w),
              child: child,
            ),
    );
  }

  Widget tagWidget(List<String> sign) {
    var asset = 'assets/svg/post_office.svg';
    var text = '';
    if (sign.contains('office')) {
      asset = 'assets/svg/post_office.svg';
      text = '官方贴';
    } else if (sign.contains('boutique')) {
      asset = 'assets/svg/post_good.svg';
      text = '精品贴';
    } else if (sign.contains('newbie')) {
      asset = 'assets/svg/post_newer.svg';
      text = '新人贴';
    } else {
      return const SizedBox();
    }
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(asset),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(2.w, 1.w, 2.w, 2.5.w),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getFilesUrl(UploadFile uploadFile) {
    if (uploadFile.type == 'video') {
      return uploadFile.posterUrl!;
    }
    return uploadFile.url ?? '';
  }
}
