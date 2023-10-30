import 'package:connect/data/remote/base_service.dart';
import 'package:http/http.dart' as http;

class GetTermsService extends BaseService<List<Map<String,dynamic>>> {

  final TermsType type;

  GetTermsService({this.type}) : super(withAccessToken: false);

  @override
  Future<http.Response> request() => this.fetchGet();

  @override
  setUrl() => baseUrl + 'user/api/v2/users/acceptTerms';

  @override
  List<Map<String, dynamic>> success(body) {
    if(body == null) return null;

    final res = List<Map<String,dynamic>>();
    final bodyMap = body as Map;

    if(type != TermsType.ALL){
      res.add(createTermsParam(type: type, html: bodyMap[describeEnum(type).toLowerCase()]));
      return res;
    }

    bodyMap.forEach((key, value) {
      final index = TermsType.values.indexWhere((element) => describeEnum(element).toLowerCase() == key);
      if(index != -1 && value.isNotEmpty){
        var type = TermsType.values.toList()[index];
        res.add(createTermsParam(type: type, html: value));
      }
    });

    return res;
  }

}

class HasNewTermsService extends BaseService<List<Map<String,dynamic>>> {
  @override
  Future<http.Response> request() => fetchGet();

  @override
  setUrl() => baseUrl + 'user/api/v2/users/checkNewTerms';

  @override
  List<Map<String, dynamic>> success(body) {
    if(body == null) return null;

    final res = List<Map<String,dynamic>>();
    final bodyMap = body as Map;

    bodyMap.forEach((key, value) {
      final index = TermsType.values.indexWhere((element) => describeEnum(element).toLowerCase() == key);
      if(index != -1 && value.isNotEmpty){
        var type = TermsType.values.toList()[index];
        res.add(createTermsParam(type: type, html: value));
      }
    });

    return res;
  }

}

class AgreeTermsService extends BaseService<bool> {

  final TermsType type;

  AgreeTermsService({this.type});

  @override
  Future<http.Response> request() => fetchPost(body: jsonEncode({
    'terms_type' : describeEnum(type)
  }));

  @override
  setUrl() => baseUrl + 'user/api/v2/users/checkNewTerms';

  @override
  bool success(body) => true;
}

enum TermsType {
  ALL,
  TERMS,
  PRIVACY_POLICY
}

Map<String,dynamic> createTermsParam({TermsType type, String html}){
  assert(type != null && html != null);
  return {
    'type' : type,
    'html' : html
  };
}