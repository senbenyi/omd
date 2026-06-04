import 'package:common/utils/SharedStorageUtil.dart';
import 'package:store/common/user/go_user_controller.dart';

class GoPersonalInfoStatusStore {
  static const _jobSeekerCompletedPrefix = 'offer_job_seeker_profile_completed';

  static String get userId => GoUserController.to.loginInfo.value?.displayUserId ?? '0';

  static String get token => GoUserController.to.token.value;

  static bool get isLogin => GoUserController.to.isLogin.value;

  static String get _jobSeekerCompletedKey {
    return '${_jobSeekerCompletedPrefix}_$userId';
  }

  static bool get hasCompletedJobSeekerProfile {
    return SharedStorageUtil.getBool(_jobSeekerCompletedKey);
  }

  static Future<void> markJobSeekerProfileCompleted() async {
    await SharedStorageUtil.setBool(_jobSeekerCompletedKey, true);
  }
}
