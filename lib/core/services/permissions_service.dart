class PermissionsService {
  Future<bool> requestMicrophone() async {
    // Replace with permission_handler or equivalent if you want runtime prompts
    // centralized here later. For now, platform manifests/plists must be correct.
    return true;
  }

  Future<bool> requestNotifications() async {
    // iOS notification permission should be requested from app flow when reminders
    // are enabled. Android 13+ also needs runtime notification permission.
    return true;
  }
}
