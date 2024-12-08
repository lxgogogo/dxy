part of 'video_detail_screen.dart';

class VideoDetailController extends GetxController {
  int? id;

  ArticleDetailBean? articleDetailBean;
  VideoPlayerController? videoController;
  ChewieController? chewieController;

  List<CommentBean>? comments;
  bool loaded = false;

  StreamSubscription? _eventSubscription;

  final autoScrollController = AutoScrollController(axis: Axis.horizontal);

  @override
  void onInit() {
    id = Get.arguments as int?;
    super.onInit();
    requestDetail();
    _eventSubscription = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      requestDetail();
    });
  }

  @override
  void onClose() {
    _eventSubscription?.cancel();
    videoController?.dispose();
    chewieController?.dispose();
    super.onClose();
  }

  requestDetail() {
    NetRequest().contentShow({'id': id}, (data) async {
      if (data == null) {
        showToast('该视频已删除');
        Get.back();
        return;
      }
      articleDetailBean = ArticleDetailBean.fromJson(data);
      safeUpdate();
      if (articleDetailBean?.videoList?.isNotEmpty == true) {
        _startVideoPlayer(articleDetailBean!.videoList!.first.sourceUrl ?? '');
      } else {
        _startVideoPlayer(articleDetailBean?.video?.sourceUrl ?? '');
      }
    });

    NetRequest().commentList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {'relType': 'content', 'relId': id}
    }, (data) {
      List<CommentBean> dataList = List<CommentBean>.from(data['list'].map((comment) => CommentBean.fromJson(comment)));
      comments = dataList;
      safeUpdate();
    });
  }

  void _initController(String link) {
    loaded = false;
    safeUpdate();
    videoController = VideoPlayerController.networkUrl(Uri.parse(link))
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: videoController!,
          autoPlay: true,
          showOptions: false,
        );
        loaded = true;
        safeUpdate();
      });
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

  void playVideo() {
    if (loaded) {
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
    _startVideoPlayer(articleDetailBean!.videoList![index].sourceUrl ?? '');
  }
}
