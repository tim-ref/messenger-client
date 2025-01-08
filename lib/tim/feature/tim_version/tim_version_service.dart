import 'package:fluffychat/tim/feature/tim_version/tim_version.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_repository.dart';

const _defaultTimVersion = TimVersion.classic;

/// Wraps [TimVersionRepository] with a default value.
class TimVersionService {
  final TimVersionRepository repository;

  TimVersionService(this.repository);

  Future<void> set(TimVersion version) async {
    return await repository.set(version);
  }

  Future<TimVersion> get() async {
    return repository.getOrDefault(_defaultTimVersion);
  }

  Future<bool> versionFeaturesClientSideInviteRejection() async {
    final version = await get();
    return featuresClientSideInviteRejection(version);
  }
}
