part of 'video_detail_screen.dart';

class VideoDetailController extends GetxController {
  int? id;
  int? childId;

  ArticleDetailBean? detailBean;
  VideoPlayerController? videoController;
  ChewieController? chewieController;

  List<CommentBean>? comments;
  bool isInitialize = false;

  StreamSubscription? _eventSubscription;

  final autoScrollController = AutoScrollController(
    axis: Axis.horizontal,
    suggestedRowHeight: 148.w,
  );

  String get shareLink {
    String shareUrlSuffix = '';
    if (detailBean?.type == 'videoList' && (detailBean?.videoList?.isNotEmpty ?? false)) {
      shareUrlSuffix = '?id=${detailBean?.videoList?[playVideoIndex].id}';
    }
    return 'details/${detailBean?.type}-$id$shareUrlSuffix';
  }

  bool noNetwork = false;

  final VideoNotifier videoNotifier = VideoNotifier();

  final RefreshController refreshController = RefreshController();
  int pageNum = 1;
  int pageSize = 10;
  bool noMore = false;

  @override
  void onInit() {
    id = Get.arguments['id'] as int?;
    childId = Get.arguments['childId'] as int?;
    super.onInit();
    _eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      requestData(showLoading: false);
    });
    dataInit();
  }

  Future<void> dataInit() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      safeUpdate();
      return;
    }
    requestData(showLoading: false);
  }

  Future<void> refreshData() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      ToastUtils.showToast('请检查网络');
      return;
    }
    requestData();
  }

  @override
  void onClose() {
    _eventSubscription?.cancel();
    videoController?.removeListener(videoListener);
    videoController?.dispose();
    chewieController?.dispose();
    /// 上传视频已播放时长

    super.onClose();
  }

  void requestData({bool showLoading = true}) {
    if (showLoading) {
      EasyLoading.show(status: 'loading...');
    }
    Future.wait([
      requestDetail(),
      loadComments(),
    ]).whenComplete(() {
      if (showLoading) {
        EasyLoading.dismiss();
      }
    });
  }

  Future<void> requestDetail() async {
    await NetRequest().contentShow(
      {'id': id},
      showLoading: false,
      (data) async {
        if (data == null) {
          ToastUtils.showToast('该视频已删除');
          Get.back();
          return;
        }
        detailBean = ArticleDetailBean.fromJson(data);

        safeUpdate();
        if (videoController == null) {
          if (detailBean?.videoList?.isNotEmpty == true) {
            if (childId != null) {
              final index = detailBean!.videoList!.indexWhere((e) => e.id == childId);
              if (index != -1) {
                playVideoIndex = index;
                autoScrollController.scrollToIndex(
                  playVideoIndex,
                  duration: const Duration(microseconds: 1),
                  preferPosition: AutoScrollPosition.end,
                );
              }
            }
            _startVideoPlayer(detailBean!.videoList![playVideoIndex].sourceUrl ?? '');
          } else {
            _startVideoPlayer(detailBean?.video?.sourceUrl ?? '');
          }
        }
        EventBusUtil.of.fire(EventRefreshNum(
          detailBean!.id!,
          commentCount: detailBean?.commentCount,
          likeCount: detailBean?.likeCount,
          favoriteCount: detailBean?.favoriteCount,
        ));
      },
    );
  }

  void _initController(String link) {
    isInitialize = false;
    safeUpdate();
    videoController = VideoPlayerController.networkUrl(Uri.parse(link))
      ..addListener(videoListener)
      ..initialize().then((_) {
        videoNotifier.initChewieController(videoController!);
        isInitialize = true;
        safeUpdate();
      });
  }

  void videoListener() {
    if (detailBean?.videoList?.isNotEmpty != true) return;
    if (videoController == null) return;
    final currentDuration = videoController!.value.position.inSeconds;
    final totalDuration = videoController!.value.duration.inSeconds;
    // if (currentDuration >= freeTotalDuration) {
    //   /// 权限不足 弹窗
    //   return;
    // }
    if (currentDuration > 0 && currentDuration >= totalDuration) {
      if (playVideoIndex == detailBean!.videoList!.length - 1) {
        playVideoIndex = 0;
      } else {
        playVideoIndex += 1;
      }
      autoScrollController.scrollToIndex(
        playVideoIndex,
        duration: const Duration(microseconds: 1),
        preferPosition: AutoScrollPosition.end,
      );
      safeUpdate();
      _startVideoPlayer(detailBean!.videoList![playVideoIndex].sourceUrl ?? '');
    }
  }

  Future<void> _startVideoPlayer(String link) async {
    if (videoController == null) {
      _initController(link);
    } else {
      final oldController = videoController;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        oldController?.removeListener(videoListener);
        await oldController?.dispose();
        _initController(link);
      });
      videoController?.removeListener(videoListener);
      videoController = null;
      safeUpdate();
    }
  }

  void playVideo() {
    if (isInitialize) {
      if (videoController?.value.isPlaying == true) {
        videoController?.pause();
      } else {
        videoController?.play();
      }
    }
  }

  int playVideoIndex = 0;

  void onPageChanged(int value) {
    playVideoIndex = value;
    safeUpdate();
  }

  Future<void> selectVide(int index) async {
    if (playVideoIndex == index) return;
    autoScrollController.scrollToIndex(
      index,
      duration: const Duration(microseconds: 1),
      preferPosition: AutoScrollPosition.end,
    );
    playVideoIndex = index;
    safeUpdate();
    _startVideoPlayer(detailBean!.videoList![index].sourceUrl ?? '');
  }

  void onRefresh() async {
    pageNum = 1;
    loadComments();
  }

  void onLoading() async {
    if (noMore) {
      refreshController.loadNoData();
      return;
    }
    pageNum++;
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      int recordsSize = 0;
      await NetRequest().commentList(
        {
          'pageNum': pageNum,
          'pageSize': pageSize,
          'filters': {
            'relType': 'content',
            'relId': id,
          },
        },
        showLoading: false,
        (data) {
          final dataList = List<CommentBean>.from(
            data['list'].map((comment) => CommentBean.fromJson(comment)),
          );
          recordsSize = dataList.length;
          if (pageNum == 1) {
            comments = dataList;
          }
          comments?.addAll(dataList);
          safeUpdate();
        },
      );
      if (pageNum == 1) {
        refreshController.refreshCompleted();
        if (recordsSize < pageSize) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.resetNoData();
        }
      } else {
        if (recordsSize < pageSize) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.loadComplete();
        }
      }
    } catch (e) {
      refreshController.loadFailed();
    } finally {
      safeUpdate();
    }
  }
}
