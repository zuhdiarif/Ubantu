abstract class IStorageRepository {
  Future<bool> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<bool> clear();
}
