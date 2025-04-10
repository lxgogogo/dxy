import 'dart:async';

import 'package:dio/dio.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/api.dart';
import 'package:holdem/utils/http_utils.dart';
import 'package:holdem/utils/response.dart' as util_response;
import 'package:holdem/utils/storage.dart';
import 'package:holdem/utils/toast_utils.dart';

import '../model/upload_file.dart';
import 'log_utils.dart';

typedef SuccessCallback = void Function(dynamic data);
typedef FailureCallback = void Function(String errorMsg);

class NetRequest {
  Future courseCategory(Map<String, Object> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.indexCategory, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future indexList(Map<String, dynamic> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.indexList, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }
  Future hotVideo(Map<String, dynamic> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.hotVideo,params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }
  Future bookSuggest(Map<String, dynamic> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.hotVideo,params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future competitionLoop(Map<String, Object> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.competitionLoop, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future competitionRelated(Map<String, Object> params, SuccessCallback onSuccess) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.competitionRelated, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future courseList(Map<String, dynamic> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<dynamic, dynamic> response = await HttpUtils.post(Api.courseList, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future contentShow(Map<String, dynamic> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.contentShow, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      onSuccess(null);
    }
  }

  Future indexBanner(Map<String, Object> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.indexBanner, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future bookRecommend(Map<String, Object> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.bookSuggest, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future messageList(Map<String, Object> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.messageList, params: params,showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.message != null && resp.message!.isNotEmpty) {
        if (resp.code != 402) {
          ToastUtils.showToast(resp.message!);
        }
      }
    }
  }

  Future commentList(Map<String, Object> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<dynamic, dynamic> response = await HttpUtils.post(Api.commentList, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("commentList===>$response");
      onSuccess(response['data']);
    }
  }

  Future contentLike(Map<String, dynamic> params, SuccessCallback onSuccess) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.like, params: params, showLoading: false);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    }
  }

  Future newContentLike(Map<String, dynamic> params) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.like, params: params, showLoading: false);
    util_response.Response resp = util_response.Response.fromJson(response);
    return response['data'];
  }

  Future getBoardList() async {
    var data = await HttpUtils.post(Api.boardList);
    print(data);
    return data;
  }

  ///论坛顶部板块列表
  Future getBoardData(SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, Object> params = {};

    Map<String, dynamic> response = await HttpUtils.post(Api.boardList, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
      LogUtils.printAll("getBoardData===>$response");
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///论坛顶部板块所属子列表
  ///"pageNum" : 1,
  ///"pageSize": 10,
  ///"ordered": "time", // 排序 time 时间最新，comment 评论最多，like 点赞最多
  ///"filters": {
  ///"boardId": 1, // 可选 板块id
  ///"ownerId": 1, // 可选 某人的帖子
  ///"q": ""       // 可选 关键词
  static const String BOARD_SORT_TIME = "time";
  static const String BOARD_SORT_COMMENT = "comment";
  static const String BOARD_SORT_LIKE = "like";

  Future getThreadListByBoard(Map<String, dynamic> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.threadList, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///帖子详情
  Future threadShow(Map<String, dynamic> params, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.threadShow, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("threadShow===>$response");
      onSuccess(response['data']);
    } else {
      onSuccess(null);
    }
  }

  ///上传文件
  Future uploadFile(
      String filePath, SuccessCallback onSuccess, FailureCallback onFail, ProgressCallback onSendProgress) async {
    Map<String, Object> params = {};
    params['file'] = filePath;

    Map<String, dynamic> response = await HttpUtils.postFile(Api.uploadFile,
        params: params, onSendProgress: onSendProgress, showLoading: false, onFail: onFail);

    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("uploadFile===>$response");
      onSuccess(response['data']);
    } else {
      onFail(resp.message!);
      print('uploadFile============fail=======');
      // ToastUtils.showToast('上传文件失败，请重新上传');
    }
  }

  Future uploadBytesFile(
      var data, SuccessCallback onSuccess, FailureCallback onFail, ProgressCallback onSendProgress) async {
    Map<String, dynamic> response =
        await HttpUtils.postBytesFile(Api.uploadFile, data, params: {}, onSendProgress: onSendProgress, onFail: onFail);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("uploadFile===>$response");
      onSuccess(response['data']);
    } else {
      onFail(resp.message!);
    }
  }

  ///关注列表
  Future followedList(String pageNum, String pageSize, String q, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    if (q.isNotEmpty) {
      filters['q'] = q;
    }
    params['filters'] = filters;

    Map<String, dynamic> response = await HttpUtils.post(Api.followedList, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("followedList===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///粉丝列表
  Future fansList(String pageNum, String pageSize, String q, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    if (q.isNotEmpty) {
      filters['q'] = q;
    }
    params['filters'] = filters;

    Map<String, dynamic> response = await HttpUtils.post(Api.fansList, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("fansList===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///关注、取消关注
  Future followerToggle(int userId, bool state, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['userId'] = userId;
    params['state'] = state;

    Map<String, dynamic> response = await HttpUtils.post(Api.followerToggle, params: params, showLoading: false);
    util_response.Response resp = util_response.Response.fromJson(response);
    LogUtils.printAll("followerToggle params===>$params");
    if (resp.code == 200) {
      LogUtils.printAll("followerToggle===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///收藏列表 user/favorite/list
  Future userFavoriteList(int pageNum, int pageSize, String relType, SuccessCallback onSuccess,
      {bool showLoading = true, int categoryId = 0}) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    //"relType": "thread" // 可选 评论类型, thread 帖子、 content 内容
    if (relType.isNotEmpty) {
      filters['relType'] = relType;
    }
    if (categoryId > 0) {
      filters['categoryId'] = categoryId;
    }
    params['filters'] = filters;

    LogUtils.printAll("userFavoriteList params===>$params");
    Map<String, dynamic> response = await HttpUtils.post(Api.userFavoriteList, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("userFavoriteList===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future delFavorite(int id, SuccessCallback onSuccess) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.delFavorite, params: {"id": id});
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///评论列表
  Future userCommentList(int pageNum, int pageSize, String relType, SuccessCallback onSuccess, {bool showLoading = true}) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    //"relType": "thread" // 可选 评论类型, thread 帖子、 content 内容
    if (relType.isNotEmpty) {
      filters['relType'] = relType;
    }
    params['filters'] = filters;

    Map<String, dynamic> response = await HttpUtils.post(Api.userCommentList, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///评论列表
  Future replyList(
      int pageNum, int pageSize, int? relId, String? relType, SuccessCallback onSuccess, FailureCallback onFail) async {
    Map<String, dynamic> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;
    Map<String, dynamic> filters = {};
    filters['relId'] = relId;
    filters['relType'] = relType;
    params['filters'] = filters;
    Map<String, dynamic> response = await HttpUtils.post(Api.commentList, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      onFail(resp.message ?? '');
      ToastUtils.showToast(resp.message ?? '');
    }
  }

  ///注册
  // register 注册
  static const String SEND_CODE_TYPE_REGISTER = "register";

  //resetPassword 重置密码
  static const String SEND_CODE_TYPE_RESET_PW = "resetPassword";

  static const String SEND_CODE_TYPE_CHANGE_EMAIL = "changeEmail";

  static const String SEND_CODE_DELETE_ACCOUNT = "deleteAccount";

  Future sendCode(String type, String account) async {
    Map<String, Object> params = {};
    params['type'] = type;
    params['email'] = account;

    Map<String, dynamic> response = await HttpUtils.post(Api.sendCode, params: params, showLoading: false);
    LogUtils.printAll("sendCode===>$response");
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("sendCode success===>");
    }
  }

  ///注册
  Future registerAccount(String account, String password, String code, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['password'] = password;
    params['code'] = code;

    Map<String, dynamic> response = await HttpUtils.post(Api.register, params: params);
    LogUtils.printAll("registerAccount===>$response");
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("registerAccount success===>");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///登录
  Future userLogin(String account, String password, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['password'] = password;

    Map<String, dynamic> response = await HttpUtils.post(Api.login, params: params);
    LogUtils.printAll("userLogin===>$response");
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("getUserProfile success===>");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///退出登录
  Future logout(SuccessCallback onSuccess) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.logout);
    LogUtils.printAll("logout===>$response");
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("logout success===>");
      onSuccess(response);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///获取用户本人信息
  Future getUserInfo(SuccessCallback onSuccess, FailureCallback onFailure) async {
    final id = UserStore.of.user?.id;
    if (id == null) return;
    Map<String, dynamic> response = await HttpUtils.post(Api.user, params: {'id': id}, showLoading: false);
    LogUtils.printAll("getUserInfo===>$response");
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("getUserInfo success===>");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///更新图像 FILE
  Future updateAvatarBytesFile(var data, SuccessCallback onSuccess) async {
    Map<String, dynamic> response = await HttpUtils.postBytesFile(Api.updateAvatar, data, params: {});
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("updateAvatar===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///更新图像
  Future updateAvatar(
      String filePath, SuccessCallback onSuccess, FailureCallback? onFail, ProgressCallback? onSendProgress) async {
    Map<String, Object> params = {};
    params['file'] = filePath;

    Map<String, dynamic> response = await HttpUtils.postFile(Api.updateAvatar,
        params: params, showLoading: true, onSendProgress: onSendProgress, onFail: onFail);

    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("uploadFile===>$response");
      onSuccess(response['data']);
    } else {
      onFail?.call(resp.message ?? '');
      print('uploadFile============fail=======');
      // ToastUtils.showToast('上传文件失败，请重新上传');
    }
  }

  ///更新资料
  Future userUpdate(String nickname, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['nickname'] = nickname;

    Map<String, dynamic> response = await HttpUtils.post(Api.userUpdate, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("userUpdate===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///更新资料
  Future updateEmail(String email, String code, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['email'] = email;
    params['code'] = code;

    Map<String, dynamic> response = await HttpUtils.post(Api.updateEmail, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("userUpdate===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///注销接口
  Future deleteAccount(String account, String code, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['code'] = code;

    Map<String, dynamic> response = await HttpUtils.post(Api.deleteAccount, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("userUpdate===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///版本检测
  Future appVersion(SuccessCallback onSuccess) async {
    Map<String, Object> params = {};

    Map<String, dynamic> response = await HttpUtils.post(Api.appVersion, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("appVersion===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///用户搜索
  Future userSearch(int pageNum, int pageSize, String q, SuccessCallback onSuccess, {bool showLoading = false}) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    if (q.isNotEmpty) {
      filters['q'] = q;
    }
    params['filters'] = filters;

    Map<String, dynamic> response = await HttpUtils.post(Api.userSearch, params: params, showLoading: showLoading);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("userSearch===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///发布评论
  static const String COMMENT_TYPE_THREAD = "thread";
  static const String COMMENT_TYPE_CONTENT = "content";
  static const String COMMENT_TYPE_COMMENT = "comment";

  Future commentCreate(
    String relType,
    int relId,
    String content,
    SuccessCallback onSuccess, {
    List<UploadFile> files = const [],
    List<dynamic> at = const [],
  }) async {
    Map<String, Object> params = {};
    params['relType'] = relType; //// 评论对象类型   // thread 帖子，content 内容，comment 评论
    params['relId'] = relId; // 评论对象id
    params['content'] = content;
    params['files'] = files;
    params['at'] = at;

    LogUtils.printAll("commentCreate params===>$params");

    Map<String, dynamic> response = await HttpUtils.post(Api.commentCreate, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("commentCreate===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///删除收藏
  Future favoriteDelete(int? id, SuccessCallback onSuccess) async {
    Map<String, dynamic> params = {};
    params['id'] = id; //// 收藏id

    Map<String, dynamic> response = await HttpUtils.post(Api.favoriteDelete, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("favoriteDelete===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future threadDelete(int? id, SuccessCallback onSuccess) async {
    Map<String, dynamic> params = {};
    params['id'] = id;
    Map<String, dynamic> response = await HttpUtils.post(Api.threadDelete, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("deleteThread===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future commentDelete(int? id, SuccessCallback onSuccess) async {
    Map<String, dynamic> params = {};
    params['id'] = id;
    Map<String, dynamic> response = await HttpUtils.post(Api.commentDelete, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("commentDelete===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///收藏操作 取消、收藏
  Future favoriteToggle(String? relType, int? relId, bool state, SuccessCallback onSuccess) async {
    Map<String, dynamic> params = {};
    params['relType'] = relType; //// 类型 thread 帖子，content 内容
    params['relId'] = relId; // 收藏对象id
    params['state'] = state;

    LogUtils.printAll("favoriteToggle params===>$params");

    Map<String, dynamic> response = await HttpUtils.post(Api.favoriteToggle, params: params, showLoading: false);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("favoriteToggle===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///修改密码
  Future updatePassword(String oldPassword, String newPassword, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['oldPassword'] = oldPassword;
    params['newPassword'] = newPassword;

    LogUtils.printAll("updatePassword params===>$params");

    Map<String, dynamic> response = await HttpUtils.post(Api.updatePassword, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("updatePassword===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///忘记密码 == 重置密码
  Future resetPassword(String account, String password, String code, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['password'] = password;
    params['code'] = code;

    LogUtils.printAll("resetPassword params===>$params");

    Map<String, dynamic> response = await HttpUtils.post(Api.resetPassword, params: params);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("resetPassword===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future upCount(int? id, SuccessCallback onSuccess) async {
    Map<String, dynamic> params = {};
    params['id'] = id;
    params['type'] = 'share';
    Map<String, dynamic> response = await HttpUtils.post(Api.upCount, params: params, showLoading: false);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("upCount===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future threadUpCount(int? id, SuccessCallback onSuccess) async {
    Map<String, dynamic> params = {};
    params['id'] = id;
    params['type'] = 'share';
    Map<String, dynamic> response = await HttpUtils.post(Api.threadUpCount, params: params, showLoading: false);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("threadUpCount===>$response");
      onSuccess(response['data']);
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  Future<Map<String, dynamic>?> uploadImage(String filePath) async {
    Map<String, Object> params = {};
    params['file'] = filePath;

    final response = await HttpUtils.postFile(
      Api.uploadFile,
      params: {'file': filePath},
    );
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      return response['data'];
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
  }

  ///发布帖子
  Future<bool> threadCreate(
    String title,
    String content,
    String pureText,
    int boardId, {
    List atList = const [],
    List files = const [],
    List tagIds = const [],
  }) async {
    Map<String, Object> params = {};
    params['title'] = title;
    params['content'] = content;
    params['pureText'] = pureText;
    params['boardId'] = boardId;
    params['tags'] = [];
    params['files'] = files.map((e) => {'url': e}).toList();
    params['at'] = atList;
    params['tagIds'] = tagIds;
    Map<String, dynamic> response = await HttpUtils.post(Api.threadCreate, params: params, showLoading: true);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      ToastUtils.showToast('发布成功');
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
    return resp.code == 200;
  }

  ///屏蔽帖子
  Future<bool> shieldFeed(int id) async {
    Map<String, Object> params = {};
    params['id'] = id;
    Map<String, dynamic> response = await HttpUtils.post(Api.threadShield, params: params, showLoading: false);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      // ToastUtils.showToast('屏蔽成功');
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
    return resp.code == 200;
  }

  ///屏蔽用户
  Future<bool> shieldUser(int id) async {
    Map<String, Object> params = {};
    params['id'] = id;
    Map<String, dynamic> response = await HttpUtils.post(Api.threadUserShield, params: params, showLoading: false);
    util_response.Response resp = util_response.Response.fromJson(response);
    if (resp.code == 200) {
      // ToastUtils.showToast('屏蔽成功');
    } else {
      if (resp.code != 402) {
        ToastUtils.showToast(resp.message ?? '未知错误');
      }
    }
    return resp.code == 200;
  }
}
