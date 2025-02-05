part of 'video_detail_screen.dart';

class VideoDetailController extends GetxController {
  int? id;

  ArticleDetailBean? detailBean;
  VideoPlayerController? videoController;
  ChewieController? chewieController;

  List<CommentBean>? comments;
  bool isInitialize = false;

  StreamSubscription? _eventSubscription;

  final autoScrollController = AutoScrollController(axis: Axis.horizontal);

  String get shareLink {
    String shareUrlSuffix = '';
    if (detailBean?.type == 'videoList') {
      shareUrlSuffix = '?id=${detailBean?.videoList?[playVideoIndex].id}';
    }
    return 'details/${detailBean?.type}-$id$shareUrlSuffix';
  }

  bool noNetwork = false;

  @override
  void onInit() {
    id = Get.arguments as int?;
    super.onInit();
    _eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      requestData(showLoading: false);
    });
    dataInit();
  }

  Future<void> dataInit() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.length > 1 && events.contains(ConnectivityResult.none);
    if (noNetwork) {
      safeUpdate();
      return;
    }
    requestData(showLoading: false);
  }

  Future<void> refreshData() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.length > 1 && events.contains(ConnectivityResult.none);
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
    super.onClose();
  }

  void requestData({bool showLoading = true}) {
    if (showLoading) {
      EasyLoading.show(status: 'loading...');
    }
    Future.wait([
      requestDetail(),
      requestCommentList(),
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
            _startVideoPlayer(detailBean!.videoList!.first.sourceUrl ?? '');
          } else {
            _startVideoPlayer(detailBean?.video?.sourceUrl ?? '');
          }
        }
      },
    );
  }

  Future<void> requestCommentList() async {
    await NetRequest().commentList(
      {
        'pageNum': 1,
        'pageSize': 10,
        'filters': {'relType': 'content', 'relId': id}
      },
      showLoading: false,
      (data) {
        List<CommentBean> dataList =
            List<CommentBean>.from(data['list'].map((comment) => CommentBean.fromJson(comment)));
        comments = dataList;
        safeUpdate();
      },
    );
  }

  void _initController(String link) {
    isInitialize = false;
    safeUpdate();
    videoController = VideoPlayerController.networkUrl(Uri.parse(link))
      ..addListener(videoListener)
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: videoController!,
          autoPlay: true,
          showOptions: false,
          showControlsOnInitialize: false,
        );
        isInitialize = true;
        safeUpdate();
      });
  }

  void videoListener() {
    if (detailBean?.videoList?.isNotEmpty != true) return;
    if (videoController == null) return;
    if (videoController!.value.isPlaying &&
        videoController!.value.position.inSeconds >= videoController!.value.duration.inSeconds) {
      if (playVideoIndex == detailBean!.videoList!.length - 1) {
        playVideoIndex = 0;
      } else {
        playVideoIndex += 1;
      }
      autoScrollController.scrollToIndex(playVideoIndex, preferPosition: AutoScrollPosition.end);
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
    autoScrollController.scrollToIndex(index, preferPosition: AutoScrollPosition.end);
    playVideoIndex = index;
    safeUpdate();
    _startVideoPlayer(detailBean!.videoList![index].sourceUrl ?? '');
  }
}
