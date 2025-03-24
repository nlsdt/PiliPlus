import 'dart:convert';

import 'package:PiliPlus/models/dynamics/article_content_model.dart';
import 'package:PiliPlus/utils/url_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'index.dart';

class HtmlHttp {
  // article
  static Future reqHtml(id, dynamicType) async {
    var response = await Request().get(
      "https://www.bilibili.com/opus/$id",
      extra: {'ua': 'pc'},
      options: Options(
        followRedirects: false,
        validateStatus: (status) => true,
      ),
    );
    if (response.data is! String && response.data is! List<int>) {
      return;
    }
    try {
      if (response.data.contains('Redirecting to')) {
        String? cvid = RegExp(r'cv\d+').firstMatch(response.data)?.group(0);
        if (cvid != null) {
          return await reqReadHtml(cvid, dynamicType, false);
        }

        RegExp regex = RegExp(r'//([\w\.]+)/(\w+)/(\w+)');
        Match match = regex.firstMatch(response.data)!;
        String matchedString = match.group(0)!;
        response = await Request().get(
          'https:$matchedString/',
          extra: {'ua': 'pc'},
        );
      }
      dom.Document rootTree = parser.parse(response.data);
      // log(response.data.body.toString());
      dom.Element body = rootTree.body!;
      dom.Element appDom = body.querySelector('#app')!;
      dom.Element authorHeader = appDom.querySelector('.fixed-author-header')!;
      // 头像
      String avatar = authorHeader.querySelector('img')!.attributes['src']!;
      avatar = 'https:${avatar.split('@')[0]}';
      String uname = authorHeader
          .querySelector('.fixed-author-header__author__name')!
          .text;

      // 动态详情
      dom.Element opusDetail = appDom.querySelector('.opus-detail')!;
      // 发布时间
      String updateTime =
          opusDetail.querySelector('.opus-module-author__pub__text')!.text;
      //
      String opusContent =
          opusDetail.querySelector('.opus-module-content')!.innerHtml;
      String? test;
      try {
        test = opusDetail
            .querySelector('.horizontal-scroll-album__pic__img')!
            .innerHtml;
      } catch (_) {}

      String commentId = opusDetail
          .querySelector('.bili-comment-container')!
          .className
          .split(' ')[1]
          .split('-')[2];
      // List imgList = opusDetail.querySelectorAll('bili-album__preview__picture__img');
      return {
        'status': true,
        'avatar': avatar,
        'uname': uname,
        'updateTime': updateTime,
        'content': (test ?? '') + opusContent,
        'commentId': int.parse(commentId)
      };
    } catch (err) {
      debugPrint('err: $err');
    }
  }

  // read
  static Future reqReadHtml(id, dynamicType, [bool redirect = true]) async {
    if (redirect) {
      String? redirectUrl = await UrlUtils.parseRedirectUrl(
          'https://www.bilibili.com/$dynamicType/$id/');
      if (redirectUrl != null) {
        return await reqHtml(redirectUrl.split('/').last, dynamicType);
      }
    }

    var response = await Request().get(
      "https://www.bilibili.com/$dynamicType/$id/",
      extra: {'ua': 'pc'},
      options: Options(
        headers: {
          'cookie': 'opus-goback=1',
        },
      ),
    );
    if (response.data is! String && response.data is! List<int>) {
      return;
    }
    try {
      dom.Document rootTree = parser.parse(response.data);
      dom.Element body = rootTree.body!;
      dom.Element appDom = body.querySelector('#app')!;
      dom.Element authorHeader = appDom.querySelector('.up-left')!;
      // 头像
      // String avatar =
      //     authorHeader.querySelector('.bili-avatar-img')!.attributes['data-src']!;
      // 正则寻找形如"author":{"mid":\d+,"name":".*","face":"xxxx"的匹配项
      String avatar =
          RegExp(r'"author":\{"mid":\d+?,"name":".+?","face":"(.+?)"')
              .firstMatch(response.data)!
              .group(1)!
              .replaceAll(r'\u002F', '/')
              .split('@')[0];
      // debugPrint(avatar);
      String uname = authorHeader.querySelector('.up-name')!.text.trim();
      // 动态详情
      dom.Element opusDetail = appDom.querySelector('.article-content')!;
      // 发布时间
      // String updateTime =
      //     opusDetail.querySelector('.opus-module-author__pub__text')!.text;
      // debugPrint(updateTime);

      //
      dynamic opusContent =
          opusDetail.querySelector('#read-article-holder')?.innerHtml ?? '';

      bool isJsonContent = false;
      if (opusContent.isEmpty) {
        final regex = RegExp(r'window\.__INITIAL_STATE__\s*=\s*(\{.*?\});');
        final match = regex.firstMatch(response.data);
        if (match != null) {
          final jsonString = match.group(1);
          if (jsonString != null) {
            try {
              dynamic json = jsonDecode(jsonString);
              opusContent = json['readInfo']['content'];
              try {
                opusContent = (json['readInfo']?['opus']?['content']
                        ?['paragraphs'] as List)
                    .map((item) => ArticleContentModel.fromJson(item))
                    .toList();
                isJsonContent = true;
              } catch (e) {
                debugPrint('second: $e');
              }
            } catch (e) {
              debugPrint('first: $e');
            }
          }
        }
      }

      RegExp digitRegExp = RegExp(r'\d+');
      Iterable<Match> matches = digitRegExp.allMatches(id);
      String number = matches.first.group(0)!;
      return {
        'status': true,
        'avatar': avatar,
        'uname': uname,
        'updateTime': '',
        'content': opusContent,
        'isJsonContent': isJsonContent,
        'commentId': int.parse(number),
      };
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
