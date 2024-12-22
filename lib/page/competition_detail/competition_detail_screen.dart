import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/competition_bean.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/item_article.dart';
import 'package:holdem/widget/item_feed.dart';
import 'package:holdem/widget/item_video.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:video_player/video_player.dart';

part 'competition_detail_controller.dart';

class CompetitionDetailScreen extends StatefulWidget {
  final int? id;

  const CompetitionDetailScreen({super.key, required this.id});

  @override
  State<CompetitionDetailScreen> createState() => _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState extends State<CompetitionDetailScreen> {
  CompetitionBean? competitionBean;
  late VideoPlayerController _playController;
  late ChewieController _chewieController;

  bool _isPlaying = false;
  late String videoUrl;

  @override
  void initState() {
    super.initState();
    reqData();
  }

  @override
  void dispose() {
    super.dispose();
    _playController.dispose();
    _chewieController.dispose();
  }

  reqData() {
    NetRequest().contentShow({'id': widget.id}, (data) async {
      if (data == null) {
        ToastUtils.showToast('该帖子已删除');
        Get.back();
        return;
      }
      competitionBean = CompetitionBean.fromJson(data);
      setState(() {});
      if (competitionBean?.competition?.sourceUrl?.isNotEmpty == true) {
        _playController = VideoPlayerController.networkUrl(
          Uri.parse(competitionBean?.competition?.sourceUrl ?? ''),
        );
        await _playController.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _playController,
          autoPlay: false,
        );
        _isPlaying = true;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '赛事详情',
            style: TextStyle(
              color: const Color(0xff2c2c2c),
              fontSize: 16.px,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Image.asset(
              'assets/images/back.png',
              width: 22.px,
              height: 22.px,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            if (competitionBean != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.px, vertical: 12.px),
                  padding: EdgeInsets.symmetric(horizontal: 14.px, vertical: 12.px),
                  decoration: BoxDecoration(
                    color: const Color(0xfff4f9ff),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        competitionBean?.title ?? '',
                        style: const TextStyle(
                          color: Color(0xff2a2a2a),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10.px),
                      Row(
                        children: [
                          Container(
                            width: 5.px,
                            height: 14.px,
                            margin: EdgeInsets.only(right: 5.5.px),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: const Color(0xff249cfc),
                            ),
                          ),
                          const Text(
                            '赛事期间',
                            style: TextStyle(
                              color: Color(0xff2a2a2a),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.px),
                      Text(
                        '${competitionBean?.competition?.dayBegin != null ? DateFormat('yyyy-MM-dd-HH:mm').format(competitionBean!.competition!.dayBegin!) : ''}至${competitionBean?.competition?.dayEnd != null ? DateFormat('yyyy-MM-dd-HH:mm').format(competitionBean!.competition!.dayEnd!) : ''}',
                        style: const TextStyle(
                          color: Color(0xff2a2a2a),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 10.px),
                      Row(
                        children: [
                          Container(
                            width: 5.px,
                            height: 14.px,
                            margin: EdgeInsets.only(right: 5.5.px),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: const Color(0xff249cfc),
                            ),
                          ),
                          const Text(
                            '主赛事期间',
                            style: TextStyle(
                              color: Color(0xff2a2a2a),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.px),
                      Text(
                        '${competitionBean?.competition?.mainDayBegin != null ? DateFormat('yyyy-MM-dd-HH:mm').format(competitionBean!.competition!.mainDayBegin!) : ''}至${competitionBean?.competition?.mainDayEnd != null ? DateFormat('yyyy-MM-dd-HH:mm').format(competitionBean!.competition!.mainDayEnd!) : ''}',
                        style: const TextStyle(
                          color: Color(0xff2a2a2a),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 10.px),
                      Row(
                        children: [
                          Container(
                            width: 5.px,
                            height: 14.px,
                            margin: EdgeInsets.only(right: 5.5.px),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: const Color(0xff249cfc),
                            ),
                          ),
                          const Text(
                            '地点',
                            style: TextStyle(
                              color: Color(0xff2a2a2a),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.px),
                      Text(
                        competitionBean?.competition?.place ?? '',
                        style: const TextStyle(
                          color: Color(0xff2a2a2a),
                          fontSize: 12,
                        ),
                      ),
                      if (competitionBean?.competition?.sourceUrl?.isNotEmpty == true) _buildVideoView(),
                    ],
                  ),
                ),
              ),
            if (competitionBean?.refArticleList?.isNotEmpty == true) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.px, top: 12.px),
                  child: const Text(
                    '相关资讯',
                    style: TextStyle(
                      color: Color(0xff2c2c2c),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final item = competitionBean!.refArticleList![index];
                    return ArticleItem(article: item);
                  },
                  childCount: competitionBean!.refArticleList!.length,
                ),
              ),
            ],
            if (competitionBean?.refVideoList?.isNotEmpty == true) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.px, top: 12.px),
                  child: const Text(
                    '相关视频',
                    style: TextStyle(
                      color: Color(0xff2c2c2c),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 8.px,
                  mainAxisSpacing: 8.px,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final item = competitionBean!.refVideoList![index];
                    return VideoItem(article: item);
                  },
                  childCount: competitionBean!.refVideoList!.length,
                ),
              ),
            ],
            if (competitionBean?.refThreadList?.isNotEmpty == true) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.px, top: 12.px),
                  child: const Text(
                    '相关帖子',
                    style: TextStyle(
                      color: Color(0xff2c2c2c),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final item = competitionBean!.refThreadList![index];
                    return FeedItem(item);
                  },
                  childCount: competitionBean!.refArticleList!.length,
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: SizedBox(height: 32.px),
            ),
          ],
        ),
      ),
    );
  }

  _buildVideoView() {
    return Container(
      height: 180.px,
      margin: EdgeInsets.symmetric(vertical: 16.px),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffa2b9d0).withOpacity(0.64),
            offset: Offset(0, 1.px),
            blurRadius: 2.rpx,
            spreadRadius: -1.px,
          ),
          BoxShadow(
            color: const Color(0xffffffff),
            offset: Offset(0, -1.px),
            blurRadius: 2.rpx,
            spreadRadius: 0,
          ),
        ],
      ),
      child: _isPlaying
          ? Chewie(
              controller: _chewieController,
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: competitionBean?.competition?.thumbnail ?? '',
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Image.asset('assets/images/image_loading_def.png'),
                ),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
    );
  }
}
