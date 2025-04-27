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
  // 是否有观影权限
  RxBool haveWatchPower = true.obs;
  // 是否展示无权限弹窗
  bool haveWatchAlert = false;
  // 0-普通视频 1-精选视频
  int videoType = 0;
  bool isDisposed = false;

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
    isDisposed = true;
    /// 上传视频已播放时长
    _uploadVideoReport();
    _eventSubscription?.cancel();
    videoController?.removeListener(videoListener);
    videoController?.dispose();
    chewieController?.dispose();
    super.onClose();
  }

  void _uploadVideoReport() async {
    if (detailBean != null && videoController != null) {
      int videoType = detailBean?.featured ?? 0;
      final currentDuration = videoController?.value.position.inSeconds;
      if ((videoType == 1 && UserStore.of.isLogin) || videoType == 0) {
        if ((currentDuration ?? 0) > 1) {
          await CommonService.of.uploadBenefits({
            'type': videoType == 1 ? 'featured' : 'video',
            'value': currentDuration
          });
        }
      }
    }
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
        int featured = detailBean?.featured ?? 0;
        int videoWatch = detailBean?.userlevel?.videoWatch ?? 0;
        bool isLogin = UserStore.of.isLogin;
        if (isLogin) {
          safeUpdate();
          _watchVideo();
        } else {
          haveWatchPower.value = false;
          safeUpdate();
          if (featured == 0) {
            // 普通视频未登录可以观看
            if (videoWatch != 0) {
              _watchVideo();
            } else {
              haveWatchAlert = true;
              AppRoutesUtils.haveLogin(
                  title: '当前观看视频已达上限',
                  content: '您当前的身份为访客\n请注册或登录以提升观看权限');
            }
          } else {
            if (!haveWatchAlert) {
              haveWatchAlert = true;
              AppRoutesUtils.haveLogin(
                  title: '请登录后观看',
                  content: '您当前的身份为访客\n登录后即可观看精选视频');
            }
          }
        }
        EventBusUtil.of.fire(EventRefreshNum(
          detailBean!.id!,
          commentCount: detailBean?.commentCount,
          likeCount: detailBean?.likeCount,
          favoriteCount: detailBean?.favoriteCount,
          viewCount: detailBean?.viewCount,
        ));
      },
    );
  }

  void _watchVideo() {
    int featured = detailBean?.featured ?? 0;
    int videoWatch = detailBean?.userlevel?.videoWatch ?? 0;
    int featuredWatch = detailBean?.userlevel?.featured ?? 0;
    Log.d('featured: $featured;videoWatch:$videoWatch;featuredWatch:$featuredWatch');
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
        if (!haveWatchAlert) {
          haveWatchAlert = true;
          if (featured == 1) {
            if (featuredWatch != 0) {
              haveWatchPower.value = true;
              _startVideoPlayer(
                  detailBean!.videoList![playVideoIndex].sourceUrl ?? '');
            } else {
              haveWatchPower.value = false;
              AppRoutesUtils.haveVideoWatch();
            }
          } else {
            if (videoWatch != 0) {
              haveWatchPower.value = true;
              _startVideoPlayer(
                  detailBean!.videoList![playVideoIndex].sourceUrl ?? '');
            } else {
              haveWatchPower.value = false;
              AppRoutesUtils.haveVideoWatch();
            }
          }
        }
      } else {
        if (!haveWatchAlert) {
          haveWatchAlert = true;
          if (featured == 1) {
            if (featuredWatch != 0) {
              haveWatchPower.value = true;
              _startVideoPlayer(detailBean?.video?.sourceUrl ?? '');
            } else {
              haveWatchPower.value = false;
              AppRoutesUtils.haveVideoWatch();
            }
          } else {
            if (videoWatch != 0) {
              haveWatchPower.value = true;
              _startVideoPlayer(detailBean?.video?.sourceUrl ?? '');
            } else {
              haveWatchPower.value = false;
              AppRoutesUtils.haveVideoWatch();
            }
          }
        }
      }
    }
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
    Log.d('----currentDuration: $currentDuration');
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

  void onFocusGained() {
    playVideo();
  }

  void onFocusLost() {
    if (!isDisposed) {
      videoController?.pause();
    }
  }
}
