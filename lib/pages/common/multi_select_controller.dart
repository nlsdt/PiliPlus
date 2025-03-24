import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/common/common_controller.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/extension.dart';

abstract class MultiSelectController extends CommonController {
  late final RxBool enableMultiSelect = false.obs;
  late final RxInt checkedCount = 0.obs;

  onSelect(int index) {
    List list = (loadingState.value as Success).response;
    list[index].checked = !(list[index]?.checked ?? false);
    checkedCount.value = list.where((item) => item.checked == true).length;
    loadingState.value = LoadingState.success(list);
    if (checkedCount.value == 0) {
      enableMultiSelect.value = false;
    }
  }

  void handleSelect([bool checked = false]) {
    if (loadingState.value is Success) {
      List list = (loadingState.value as Success).response;
      if (list.isNotEmpty) {
        loadingState.value = LoadingState.success(
            list.map((item) => item..checked = checked).toList());
        checkedCount.value = checked ? list.length : 0;
      }
    }
    if (checked.not) {
      enableMultiSelect.value = false;
    }
  }
}
