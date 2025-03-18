part of 'feed_detail_screen.dart';

class FeedDetailController extends GetxController {
  int? id;

  BoardBean? detailBean;
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  List<CommentBean>? comments;

  bool loaded = false;

  StreamSubscription? eventSubscription;

  bool noNetwork = false;
  late SearchTagChildController searchTagChildController;

  final RefreshController refreshController = RefreshController();
  int pageNum = 1;
  int pageSize = 10;
  bool noMore = false;

  @override
  void onInit() async {
    id = Get.arguments as int?;
    super.onInit();
    eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      requestDetail(showLoading: false);
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
    requestDetail(showLoading: false);
  }

  Future<void> refreshData() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.contains(ConnectivityResult.none);
    if (noNetwork) {
      ToastUtils.showToast('请检查网络');
      return;
    }
    requestDetail();
  }

  @override
  void onClose() {
    eventSubscription?.cancel();
    videoController?.dispose();
    chewieController?.dispose();
    super.onClose();
  }

  Future<void> _onShield(int id) async {
    final success = await NetRequest().shieldFeed(id);
    if (success) {
      ToastUtils.showToast('屏蔽成功');
    }
  }

  Future<void> _onShieldUser(int id) async {
    final success = await NetRequest().shieldUser(id);
    if (success) {
      ToastUtils.showToast('屏蔽成功');
    }
  }

  Future<void> _onReport(int id, int userId) async {
    final reportTypes = await ConfigStore.of.getReportTypes();
    Get.bottomSheet(
      ReportSheet(
        reportTypes: reportTypes,
        onReport: (int index) async {
          try {
            final res = await CommonService.of.reportCreate(
              'thread',
              id,
              userId,
              reason: reportTypes[index].value,
            );
            if (res.isSuccess) {
              ToastUtils.showToast('举报成功，我们将会在24小时内受理');
            }
          } finally {
            Get.back();
          }
        },
      ),
    );
  }

  requestDetail({
    bool showLoading = true,
  }) {
    NetRequest().threadShow(
      {'id': id},
      showLoading: showLoading,
      (data) async {
        if (data == null) {
          ToastUtils.showToast('该帖子已删除');
          Get.back();
          return;
        }
        detailBean = BoardBean.fromJson(data);
        safeUpdate();
        if (detailBean?.files?.isNotEmpty == true) {
          final videoIndex = detailBean!.files!.indexWhere((e) => e.type == 'video');
          if (videoIndex != -1) {
            final videoUrl = detailBean!.files![videoIndex].url ?? '';
            if (videoUrl.isNotEmpty) {
              _startVideoPlayer(videoUrl);
            }
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
    onRefresh();
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

  loadComments() async {
    try {
      int recordsSize = 0;
      await NetRequest().commentList(
        {
          'pageNum': pageNum,
          'pageSize': pageSize,
          'filters': {
            'relType': 'Thread',
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

  Future<void> _startVideoPlayer(String link) async {
    if (videoController == null) {
      _initController(link);
    } else {
      final oldController = videoController;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldController?.dispose();
        _initController(link);
      });
      videoController = null;
      safeUpdate();
    }
  }

  void _initController(String link) {
    loaded = false;
    safeUpdate();
    videoController = VideoPlayerController.networkUrl(Uri.parse(link))
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: videoController!,
          autoPlay: false,
          showOptions: false,
        );
        loaded = true;
        safeUpdate();
      });
  }

  void followToggle() {
    UserStore.of.checkLogin(() {
      if (detailBean?.user?.id == null) return;
      final followed = detailBean?.user?.followed ?? false;
      NetRequest().followerToggle(detailBean!.user!.id!, !followed, (data) {
        detailBean?.user?.followed = !followed;
        safeUpdate();
      });
    });
  }

  void playVideo() {
    if (loaded) {
      if (videoController?.value.isPlaying == true) {
        videoController?.pause();
      } else {
        videoController?.play();
      }
    }
  }
}
