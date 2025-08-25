part of 'video_detail_screen.dart';

class VideoDetailController extends GetxController {
  static VideoDetailController get of => Get.find<VideoDetailController>();

  int? id;
  int? childId;
  Duration? duration;

  bool noNetwork = false;

  final ScrollController scrollController = ScrollController();

  StreamSubscription? _eventSubscription;

  ArticleDetailBean? detailBean;
  int playVideoIndex = 0;

  bool _isVideoInitialized = false;
  final VideoNotifier videoNotifier = VideoNotifier();
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  bool hasUploadEvent = false;
  bool isPlayComplete = false;
  Timer? recommendTimer;
  RxBool recommendTimerCancelled = false.obs; // 添加取消标志
  RxList<RecommendVideoModel> recommendedVideos = <RecommendVideoModel>[].obs;

  List<CommentBean>? comments;
  final RefreshController refreshController = RefreshController();
  int _pageNum = 1;
  int pageSize = 10;
  bool noMore = false;

  String get shareLink {
    String shareUrlSuffix = '';
    if (detailBean?.type == 'videoList' && (detailBean?.videoList?.isNotEmpty ?? false)) {
      shareUrlSuffix = '?id=${detailBean?.videoList?[playVideoIndex].id}';
    }
    return 'details/${detailBean?.type}-$id$shareUrlSuffix';
  }

  // 是否有观影权限
  RxBool haveWatchPower = true.obs;

  // 是否展示无权限弹窗
  bool haveWatchAlert = false;

  // 0-普通视频 1-精选视频
  bool isDisposed = false;
  bool isFullScreen = false;
  bool fullScreenOnTap = false;

  @override
  void onInit() {
    id = Get.arguments['id'] as int?;
    childId = Get.arguments['childId'] as int?;
    duration = Get.arguments['duration'] as Duration?;
    super.onInit();
    _eventSubscription = EventBusUtil.of.on<EventRefreshComments>().listen((event) {
      detailBean?.commentCount = (detailBean?.commentCount ?? 0) + 1;
      onRefresh();
    });
    loadData();
  }

  @override
  void onClose() {
    isDisposed = true;

    cancelRecommendTimer();

    /// 上传视频已播放时长
    _uploadVideoReport();
    _eventSubscription?.cancel();
    videoController?.removeListener(videoListener);
    videoController?.dispose();
    chewieController?.dispose();
    super.onClose();
  }

  Future<void> loadData({bool isRefresh = false}) async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      if (isRefresh) {
        DialogUtil.showToast('请检查网络');
      } else {
        safeUpdate();
      }
      return;
    }
    requestData(showLoading: isRefresh);
  }

  void requestData({bool showLoading = true}) {
    if (showLoading) {
      DialogUtil.showLoading();
    }
    Future.wait([
      requestDetail(),
      _loadComments(),
    ]).whenComplete(() {
      if (showLoading) {
        DialogUtil.dismiss();
      }
    });
  }

  void _uploadVideoReport() async {
    if (detailBean != null && videoController != null) {
      int videoType = detailBean?.featured ?? 0;
      final currentDuration = videoController?.value.position.inSeconds;
      if ((videoType == 1 && UserStore.of.isLogin) || videoType == 0) {
        if ((currentDuration ?? 0) > 1) {
          await CommonService.of
              .uploadBenefits({'type': videoType == 1 ? 'featured' : 'video', 'value': currentDuration});
        }
      }
    }
  }

  Future<void> requestDetail() async {
    await NetRequest().contentShow(
      {'id': id},
      showLoading: false,
      (data) async {
        if (data == null) {
          DialogUtil.showToast('该视频已删除');
          Get.back();
          return;
        }
        detailBean = ArticleDetailBean.fromJson(data);
        await loadRecommendedVideos();
        if (UserStore.of.isLogin) {
          safeUpdate();
          _watchVideo();
        } else {
          haveWatchPower.value = false;
          safeUpdate();
          if ((detailBean?.userlevel?.videoWatch ?? 0) > 0) {
            _watchVideo();
          } else {
            haveWatchAlert = true;
            AppRoutesUtils.haveLogin(
              title: '当前观看视频已达上限',
              content: '您当前的身份为访客，请登录/注册后观看',
            );
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
    if (detailBean?.videoList?.isNotEmpty == true) {
      if (childId != null) {
        final index = detailBean!.videoList!.indexWhere((e) => e.id == childId);
        if (index != -1) {
          playVideoIndex = index;
        }
      }
      if (!haveWatchAlert) {
        haveWatchAlert = true;
        if (featured == 1) {
          if (featuredWatch != 0) {
            haveWatchPower.value = true;
            _startVideoPlayer(detailBean!.videoList![playVideoIndex].sourceUrl ?? '');
          } else {
            haveWatchPower.value = false;
            AppRoutesUtils.haveVideoWatch(featured: featured);
          }
        } else {
          if (videoWatch != 0) {
            haveWatchPower.value = true;
            _startVideoPlayer(detailBean!.videoList![playVideoIndex].sourceUrl ?? '');
          } else {
            haveWatchPower.value = false;
            AppRoutesUtils.haveVideoWatch(featured: featured);
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
            AppRoutesUtils.haveVideoWatch(featured: featured);
          }
        } else {
          if (videoWatch != 0) {
            haveWatchPower.value = true;
            _startVideoPlayer(detailBean?.video?.sourceUrl ?? '');
          } else {
            haveWatchPower.value = false;
            AppRoutesUtils.haveVideoWatch(featured: featured);
          }
        }
      }
    }
  }

  void _initController(String link) {
    _isVideoInitialized = false;
    isPlayComplete = false;
    safeUpdate();
    videoController = VideoPlayerController.networkUrl(Uri.parse(link))
      ..addListener(videoListener)
      ..initialize().then((_) async {
        videoNotifier.initChewieController(videoController!, (value) {
          isFullScreen = value;
          fullScreenOnTap = true;
        });
        _isVideoInitialized = true;
        safeUpdate();
        if (duration != null) {
          await videoNotifier.chewieController?.seekTo(duration!);
          duration = null;
        }
        if (!hasUploadEvent) {
          hasUploadEvent = true;
          TrackUtils.trackEvent(userLogType: '103011', params: id);
        }
      });
  }

  void videoListener() {
    if (videoController == null) return;
    final currentDuration = videoController!.value.position.inSeconds;
    if (currentDuration > 0) {
      final totalDuration = videoController!.value.duration.inSeconds;
      if ((currentDuration + 1) >= totalDuration) {
        if (detailBean?.videoList?.isNotEmpty == true) {
          if (playVideoIndex == detailBean!.videoList!.length - 1) {
            if (!isPlayComplete) {
              recommendTimerCancelled.value = false;
              recommendTimer = Timer(const Duration(seconds: 5), () {
                if (!recommendTimerCancelled.value && recommendedVideos.isNotEmpty) {
                  onPlayNewVideo(recommendedVideos.first);
                }
              });
              isPlayComplete = true;
              safeUpdate();
            }
            return;
            // playVideoIndex = 0;
          } else {
            playVideoIndex += 1;
          }
          safeUpdate();
          _startVideoPlayer(detailBean!.videoList![playVideoIndex].sourceUrl ?? '');
        } else {
          if (!isPlayComplete) {
            recommendTimerCancelled.value = false;
            recommendTimer = Timer(const Duration(seconds: 5), () {
              if (!recommendTimerCancelled.value && recommendedVideos.isNotEmpty) {
                onPlayNewVideo(recommendedVideos.first);
              }
            });
            isPlayComplete = true;
            safeUpdate();
          }
        }
      }
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

  Future<void> playVideo() async {
    if (_isVideoInitialized) {
      if (videoController?.value.isPlaying == true) {
        await videoController?.pause();
      } else {
        await videoController?.play();
      }
    }
  }

  Future<void> onReplay() async {
    recommendTimer?.cancel();
    recommendTimer = null;
    await videoController?.seekTo(Duration.zero);
    await videoController?.play();
    isPlayComplete = false;
    safeUpdate();
  }

  void cancelRecommendTimer() {
    recommendTimerCancelled.value = true;
    recommendTimer?.cancel();
  }

  Future<void> onPlayNewVideo(RecommendVideoModel model) async {
    recommendTimer?.cancel();
    recommendTimer = null;
    isPlayComplete = false;
    safeUpdate();

    id = model.id;
    playVideoIndex = 0;
    hasUploadEvent = false;
    recommendedVideos.clear();
    comments = null;
    _pageNum = 1;
    noMore = false;

    haveWatchPower.value = true;
    haveWatchAlert = false;
    isDisposed = false;
    isFullScreen = false;
    fullScreenOnTap = false;

    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      DialogUtil.showToast('请检查网络');
      return;
    }
    requestData(showLoading: true);
  }

  Future<void> selectVide(int index) async {
    if (playVideoIndex == index) return;
    playVideoIndex = index;
    safeUpdate();
    final videoUrl = detailBean?.videoList?[playVideoIndex].sourceUrl;
    await _startVideoPlayer(videoUrl ?? '');
  }

  Future<void> loadRecommendedVideos() async {
    int? queryId = id;
    if (detailBean?.videoList?.isNotEmpty == true) {
      queryId = detailBean!.videoList!.last.id;
    }
    final res = await VideoService.of.recommendedVideos(id: queryId);
    if (res.isSuccess) {
      final listRes = res.data as List;
      final records = listRes.map((e) => RecommendVideoModel.fromJson(e)).toList();
      if (records.isNotEmpty) {
        recommendedVideos.assignAll(records);
        safeUpdate();
      }
    }
  }

  void onFocusGained() {
    if (!fullScreenOnTap) {
      if (_isVideoInitialized) {
        if (videoController?.value.isPlaying == false) {
          // videoController?.play();
        }
      }
    } else {
      fullScreenOnTap = false;
    }
  }

  void onFocusLost() {
    if (!fullScreenOnTap) {
      if (!isDisposed && videoController?.value.isPlaying == true) {
        videoController?.pause();
      }
    } else {
      fullScreenOnTap = false;
    }
  }

  void followOnTap() {
    safeUpdate();
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    final success = await _likeToggle.call();
    return success ? !isLiked : isLiked;
  }

  Future<bool> _likeToggle() async {
    if (detailBean == null) {
      return false;
    }
    final data = await NetRequest().newContentLike({
      'relType': NetRequest.COMMENT_TYPE_CONTENT,
      'relId': detailBean!.id,
      'state': detailBean!.liked ?? false ? false : true,
    });
    if (data is int) {
      if (detailBean!.liked != true) {
        DialogUtil.showToast('点赞成功');
        TrackUtils.trackEvent(userLogType: '103003', params: detailBean!.id);
      } else {
        DialogUtil.showToast('取消点赞成功');
      }
      if (detailBean!.liked == true) {
        detailBean!.liked = false;
        detailBean!.likeCount = (detailBean!.likeCount ?? 0) - 1;
      } else {
        detailBean!.liked = true;
        detailBean!.likeCount = (detailBean!.likeCount ?? 0) + 1;
      }
      safeUpdate();
      return true;
    }
    return false;
  }

  void favoriteToggle() {
    if (detailBean == null) {
      return;
    }
    if (!AppRoutesUtils.haveLogin(title: '请登录后收藏', content: '您当前的身份为访客，登录/注册后即可收藏精彩内容')) {
      return;
    }
    NetRequest().favoriteToggle(
      NetRequest.COMMENT_TYPE_CONTENT,
      detailBean!.id,
      !(detailBean!.favorited ?? false),
      (data) {
        if (detailBean!.favorited != true) {
          DialogUtil.showToast('收藏成功');
        } else {
          DialogUtil.showToast('取消收藏成功');
        }
        if (detailBean!.favorited == true) {
          detailBean!.favorited = false;
          detailBean!.favoriteCount = (detailBean!.favoriteCount ?? 0) - 1;
        } else {
          detailBean!.favorited = true;
          detailBean!.favoriteCount = (detailBean!.favoriteCount ?? 0) + 1;
        }
        safeUpdate();
      },
      (msg) {
        AppRoutesUtils.haveCollect();
      },
    );
  }

  void toShare() {
    NetRequest().upCount(detailBean!.id, (data) async {
      await Clipboard.setData(ClipboardData(text: '${Env.shareHost}/${VideoDetailController.of.shareLink}'));
      DialogUtil.showToast('分享成功，链接已复制');
      TrackUtils.trackEvent(userLogType: '103005', params: detailBean!.id);
      detailBean!.shareCount = (detailBean!.shareCount ?? 0) + 1;
      safeUpdate();
    });
  }
}

extension CommentLogic on VideoDetailController {
  void onRefresh() async {
    _pageNum = 1;
    _loadComments();
  }

  void onLoading() async {
    if (noMore) {
      refreshController.loadNoData();
      return;
    }
    _pageNum++;
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      int recordsSize = 0;
      await NetRequest().commentList(
        {
          'pageNum': _pageNum,
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
          if (_pageNum == 1) {
            comments = dataList;
            refreshController.refreshCompleted();
            if (recordsSize < pageSize) {
              noMore = true;
              refreshController.loadNoData();
            } else {
              noMore = false;
              refreshController.resetNoData();
            }
          } else {
            comments?.addAll(dataList);
            if (recordsSize < pageSize) {
              noMore = true;
              refreshController.loadNoData();
            } else {
              noMore = false;
              refreshController.loadComplete();
            }
          }
          safeUpdate();
        },
      );
      if (_pageNum == 1) {
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
