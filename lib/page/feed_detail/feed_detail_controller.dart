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
    noNetwork = events.length > 1 && events.contains(ConnectivityResult.none);
    if (noNetwork) {
      safeUpdate();
      return;
    }
    requestDetail(showLoading: false);
  }

  Future<void> refreshData() async {
    final events = await Connectivity().checkConnectivity();
    noNetwork = events.length > 1 && events.contains(ConnectivityResult.none);
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
      },
    );

    NetRequest().commentList(
      {
        'pageNum': 1,
        'pageSize': 10,
        'filters': {
          'relType': 'Thread',
          'relId': id,
        },
      },
      showLoading: showLoading,
      (data) {
        comments = List<CommentBean>.from(
          data['list'].map(
            (comment) => CommentBean.fromJson(comment),
          ),
        );
        safeUpdate();
      },
    );
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

  void _followToggle() {
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
