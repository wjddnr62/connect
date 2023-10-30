import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/setting_list.dart';
import 'package:http/src/response.dart';

class TrackerGetSettingListService extends BaseService<SettingList> {
  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/tracking/settingList';
  }

  @override
  success(body) {
    return SettingList.fromJson(body);
  }

}