import 'dart:async';

import 'package:dio/dio.dart';
import 'package:holdem/utils/api.dart';
import 'package:holdem/utils/http_utils.dart';
import 'package:holdem/utils/response.dart' as HttpUtilsResonse;
import 'package:holdem/view/forum/ToastUtils.dart';

import '../model/upload_file.dart';
import 'log_utils.dart';

typedef SuccessCallback = void Function(dynamic data);
typedef FailureCallback = void Function(String errorMsg);

class NetRequest {
  Future courseCategory(
      Map<String, Object> params, SuccessCallback onSuccess) async {
    Map<String, dynamic> response =
        await HttpUtils.post(Api.indexCategory, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  Future indexList(
      Map<String, Object> params, SuccessCallback onSuccess) async {
    Map<String, dynamic> response =
        await HttpUtils.post(Api.indexList, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  Future articleDetail(
      Map<String, Object> params, SuccessCallback onSuccess) async {
    Map<String, dynamic> response =
        await HttpUtils.post(Api.contentShow, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  Future indexBanner(
      Map<String, Object> params, SuccessCallback onSuccess) async {
    Map<String, dynamic> response =
        await HttpUtils.post(Api.indexBanner, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  Future messageList(
      Map<String, Object> params, SuccessCallback onSuccess) async {
    Map<String, dynamic> response =
        await HttpUtils.post(Api.messageList, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  Future commentList(
      Map<String, Object> params, SuccessCallback onSuccess) async {
    Map<String, dynamic> response =
        await HttpUtils.post(Api.commentList, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  Future getBoardList() async {
    var data = await HttpUtils.post(Api.boardList);
    print(data);
    return data;
  }

  ///论坛顶部板块列表
  Future getBoardData(SuccessCallback onSuccess) async {
    Map<String, Object> params = {};

    Map<String, dynamic> response =
        await HttpUtils.post(Api.boardList, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
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

  Future getThreadListByBoard(
      int pageNum,
      int pageSize,
      String boardSort,
      String boardId,
      String ownerId,
      String q,
      SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;
    params['ordered'] = boardSort;

    Map<String, Object> filters = {};
    if (boardId.isNotEmpty) {
      filters['boardId'] = boardId;
    }
    if (ownerId.isNotEmpty) {
      filters['ownerId'] = ownerId;
    }
    if (q.isNotEmpty) {
      filters['q'] = q;
    }
    params['filters'] = filters;
    LogUtils.printAll("getThreadListByBoard params===>$params");
    Map<String, dynamic> response =
        await HttpUtils.post(Api.threadList, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("getThreadListByBoard===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///帖子详情
  Future threadShow(String id, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['id'] = id;
    Map<String, dynamic> response =
        await HttpUtils.post(Api.threadShow, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("threadShow===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///上传文件
  Future uploadFile(String filePath, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['file'] = filePath;

    Map<String, dynamic> response =
        await HttpUtils.postFile(Api.uploadFile, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("uploadFile===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///关注列表
  Future followedList(String pageNum, String pageSize, String q,
      SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    if (q.isNotEmpty) {
      filters['q'] = q;
    }
    params['filters'] = filters;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.followedList, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("followedList===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///粉丝列表
  Future fansList(String pageNum, String pageSize, String q,
      SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    if (q.isNotEmpty) {
      filters['q'] = q;
    }
    params['filters'] = filters;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.fansList, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("fansList===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///关注、取消关注
  Future followerToggle(
      String userId, bool state, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['userId'] = userId;
    params['state'] = state;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.followerToggle, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("followerToggle===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///收藏列表 user/favorite/list
  Future userFavoriteList(int pageNum, int pageSize, String relType,
      SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    //"relType": "thread" // 可选 评论类型, thread 帖子、 content 内容
    if (relType.isNotEmpty) {
      filters['relType'] = relType;
    }
    params['filters'] = filters;

    LogUtils.printAll("userFavoriteList params===>$params");
    Map<String, dynamic> response =
        await HttpUtils.post(Api.userFavoriteList, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("userFavoriteList===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///评论列表
  Future userCommentList(int pageNum, int pageSize, String relType,
      SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    //"relType": "thread" // 可选 评论类型, thread 帖子、 content 内容
    if (relType.isNotEmpty) {
      filters['relType'] = relType;
    }
    params['filters'] = filters;

    LogUtils.printAll("userCommentList params===>$params");
    Map<String, dynamic> response =
        await HttpUtils.post(Api.userCommentList, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("userCommentList===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///发布帖子
  Future threadCreate(
      String title,
      String content,
      int boardId,
      List<String> tags,
      List<UploadFile> files,
      List<int> at,
      SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['title'] = title;
    params['content'] = content;
    params['boardId'] = boardId;
    params['tags'] = tags;
    params['files'] = files;
    params['at'] = at;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.threadCreate, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("threadCreate===>$response");
      onSuccess(response['data']);
      ToastUtils.showToast('发布成功');
    } else {
      LogUtils.printAll("threadCreate===>$response");
      ToastUtils.showToast(resp.message!);
    }
  }

  ///注册
  // register 注册
  static const String SEND_CODE_TYPE_REGISTER = "register";
  //resetPassword 重置密码
  static const String SEND_CODE_TYPE_RESET_PW = "resetPassword";

  Future sendCode(
      String type, String account, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['type'] = type;
    params['email'] = account;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.sendCode, params: params);
    LogUtils.printAll("sendCode===>$response");
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("sendCode success===>");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///注册
  Future registerAccount(String account, String password, String code,
      SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['password'] = password;
    params['code'] = code;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.register, params: params);
    LogUtils.printAll("registerAccount===>$response");
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("registerAccount success===>");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///登录
  Future userLogin(
      String account, String password, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['password'] = password;

    Map<String, dynamic> response =
        await HttpUtils.post(Api.login, params: params);
    LogUtils.printAll("userLogin===>$response");
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("getUserProfile success===>");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///退出登录
  Future logout(SuccessCallback onSuccess) async {
    Map<String, dynamic> response = await HttpUtils.post(Api.logout);
    LogUtils.printAll("logout===>$response");
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("logout success===>");
      onSuccess(response);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///获取用户本人信息
  Future getUserInfo(String account, String password, SuccessCallback onSuccess,
      FailureCallback onFailure) async {
    Map<String, Object> params = {};
    params['account'] = account;
    params['password'] = password;

    Map<String, dynamic> response =
        await HttpUtils.get(Api.user, params: params);
    LogUtils.printAll("getUserInfo===>$response");
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("getUserInfo success===>");
      onSuccess(response['data']);
    } else {
      onFailure(resp.message!);
    }
  }

  ///更新图像
  Future updateAvatar(String filePath, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['file'] = filePath;

    Map<String, dynamic> response =
        await HttpUtils.postFile(Api.updateAvatar, params: params);
    HttpUtilsResonse.Response resp =
        HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("updateAvatar===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///更新资料
  Future userUpdate(String nickname, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['nickname'] = nickname;

    Map<String, dynamic> response =
    await HttpUtils.post(Api.userUpdate, params: params);
    HttpUtilsResonse.Response resp =
    HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("userUpdate===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///版本检测
  Future appVersion(SuccessCallback onSuccess) async {
    Map<String, Object> params = {};

    Map<String, dynamic> response =
    await HttpUtils.post(Api.appVersion, params: params);
    HttpUtilsResonse.Response resp =
    HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("appVersion===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///用户搜索
  Future userSearch(int pageNum, int pageSize,
      String q, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['pageNum'] = pageNum;
    params['pageSize'] = pageSize;

    Map<String, Object> filters = {};
    if (q.isNotEmpty) {
      filters['q'] = q;
    }
    params['filters'] = filters;

    Map<String, dynamic> response =
    await HttpUtils.post(Api.userSearch, params: params);
    HttpUtilsResonse.Response resp =
    HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("appVersion===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///发布评论
  static const String COMMENT_TYPE_THREAD = "thread";
  static const String COMMENT_TYPE_CONTENT = "content";
  static const String COMMENT_TYPE_COMMENT = "comment";
  Future commentCreate(String relType, int relId,
      String content, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['relType'] = relType; //// 评论对象类型   // thread 帖子，content 内容，comment 评论
    params['relId'] = relId; // 评论对象id
    params['content'] = content;

    LogUtils.printAll("commentCreate params===>$params");

    Map<String, dynamic> response =
    await HttpUtils.post(Api.commentCreate, params: params);
    HttpUtilsResonse.Response resp =
    HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("commentCreate===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///删除收藏
  Future favoriteDelete(int id, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['id'] = id; //// 收藏id

    Map<String, dynamic> response =
    await HttpUtils.post(Api.favoriteDelete, params: params);
    HttpUtilsResonse.Response resp =
    HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("favoriteDelete===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }

  ///收藏操作 取消、收藏
  Future favoriteToggle(String relType, int relId,
      bool state, SuccessCallback onSuccess) async {
    Map<String, Object> params = {};
    params['relType'] = relType; //// 类型 thread 帖子，content 内容
    params['relId'] = relId; // 收藏对象id
    params['state'] = state;

    LogUtils.printAll("favoriteToggle params===>$params");

    Map<String, dynamic> response =
    await HttpUtils.post(Api.favoriteToggle, params: params);
    HttpUtilsResonse.Response resp =
    HttpUtilsResonse.Response.fromJson(response);
    if (resp.code == 200) {
      LogUtils.printAll("favoriteToggle===>$response");
      onSuccess(response['data']);
    } else {
      ToastUtils.showToast(resp.message!);
    }
  }
}
