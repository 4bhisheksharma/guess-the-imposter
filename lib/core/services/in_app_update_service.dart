import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Status of the app update process
enum AppUpdateStatus {
  idle,
  checking,
  available,
  notAvailable,
  downloading,
  downloaded,
  installing,
  failed,
  unsupported,
}

/// Result object for update checks
class UpdateCheckResult {
  final bool isAvailable;
  final AppUpdateInfo? info;
  final String message;
  final bool isSupported;
  final bool isError;

  const UpdateCheckResult({
    required this.isAvailable,
    this.info,
    required this.message,
    this.isSupported = true,
    this.isError = false,
  });
}

/// Service to handle Google Play In-App Updates safely across all platforms
class InAppUpdateService extends ChangeNotifier {
  InAppUpdateService._internal();

  static final InAppUpdateService instance = InAppUpdateService._internal();
  factory InAppUpdateService() => instance;

  /// Global ScaffoldMessengerKey to show SnackBar notifications across the entire app
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  AppUpdateStatus _status = AppUpdateStatus.idle;
  AppUpdateInfo? _updateInfo;
  String? _lastErrorMessage;
  StreamSubscription<InstallStatus>? _installSubscription;

  /// Testing hook to bypass platform channel calls during unit testing
  @visibleForTesting
  static bool isTesting = false;

  /// Getters
  AppUpdateStatus get status => _status;
  AppUpdateInfo? get updateInfo => _updateInfo;
  String? get lastErrorMessage => _lastErrorMessage;
  bool get isChecking => _status == AppUpdateStatus.checking;
  bool get isUpdateAvailable => _status == AppUpdateStatus.available;
  bool get isDownloaded => _status == AppUpdateStatus.downloaded;
  bool get isDownloading => _status == AppUpdateStatus.downloading;

  /// In-app updates via Play Core are only supported on Android devices
  bool get isPlatformSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android && !isTesting;

  /// Checks for available updates on Google Play
  Future<UpdateCheckResult> checkForUpdate({bool isManual = false}) async {
    if (_status == AppUpdateStatus.checking) {
      return UpdateCheckResult(
        isAvailable: _status == AppUpdateStatus.available,
        info: _updateInfo,
        message: 'An update check is already in progress.',
      );
    }

    if (!isPlatformSupported) {
      _status = AppUpdateStatus.unsupported;
      notifyListeners();
      return const UpdateCheckResult(
        isAvailable: false,
        isSupported: false,
        message: 'In-app updates are only supported on Android via Google Play.',
      );
    }

    try {
      _status = AppUpdateStatus.checking;
      _lastErrorMessage = null;
      notifyListeners();

      final info = await InAppUpdate.checkForUpdate();
      _updateInfo = info;

      // Case 1: Flexible update was already downloaded and is waiting to be installed
      if (info.installStatus == InstallStatus.downloaded) {
        _status = AppUpdateStatus.downloaded;
        notifyListeners();
        showDownloadedSnackBar();
        return UpdateCheckResult(
          isAvailable: true,
          info: info,
          message: 'An update has finished downloading and is ready to install.',
        );
      }

      // Case 2: Update is currently downloading
      if (info.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress ||
          info.installStatus == InstallStatus.downloading) {
        _status = AppUpdateStatus.downloading;
        _listenToInstallUpdates();
        notifyListeners();
        return UpdateCheckResult(
          isAvailable: true,
          info: info,
          message: 'An update is currently downloading in the background.',
        );
      }

      // Case 3: An update is available
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _status = AppUpdateStatus.available;
        notifyListeners();
        return UpdateCheckResult(
          isAvailable: true,
          info: info,
          message: 'A new version of ${AppConstants.appName} is available!',
        );
      }

      // Case 4: No update available / up to date
      _status = AppUpdateStatus.notAvailable;
      notifyListeners();
      return UpdateCheckResult(
        isAvailable: false,
        info: info,
        message: '${AppConstants.appName} is up to date.',
      );
    } on PlatformException catch (e) {
      _status = AppUpdateStatus.failed;
      final userMessage = _mapPlatformError(e);
      _lastErrorMessage = userMessage;
      notifyListeners();
      debugPrint('InAppUpdate PlatformException: ${e.code} - ${e.message}');
      return UpdateCheckResult(
        isAvailable: false,
        isError: true,
        message: userMessage,
      );
    } on MissingPluginException catch (e) {
      _status = AppUpdateStatus.unsupported;
      _lastErrorMessage = 'In-app update plugin is not supported on this platform.';
      notifyListeners();
      debugPrint('InAppUpdate MissingPluginException: $e');
      return const UpdateCheckResult(
        isAvailable: false,
        isSupported: false,
        isError: true,
        message: 'In-app update is not available on this platform.',
      );
    } catch (e) {
      _status = AppUpdateStatus.failed;
      _lastErrorMessage = 'Unable to check for updates at this time.';
      notifyListeners();
      debugPrint('InAppUpdate unexpected error: $e');
      return const UpdateCheckResult(
        isAvailable: false,
        isError: true,
        message: 'Unable to check for updates at this time.',
      );
    }
  }

  /// Automatically performs a silent background update check (e.g. on launch or home mount)
  Future<void> performAutomaticCheck() async {
    if (!isPlatformSupported) return;

    try {
      final result = await checkForUpdate(isManual: false);
      if (!result.isAvailable || result.info == null) return;

      final info = result.info!;

      // If already downloaded, show the install prompt
      if (info.installStatus == InstallStatus.downloaded) {
        showDownloadedSnackBar();
        return;
      }

      // If high priority (e.g. priority >= 4 or staleness >= 7 days) and immediate update allowed
      final isHighPriority = info.updatePriority >= 4 ||
          (info.clientVersionStalenessDays != null &&
              info.clientVersionStalenessDays! >= 7);

      if (isHighPriority && info.immediateUpdateAllowed) {
        await performImmediateUpdate();
      } else if (info.flexibleUpdateAllowed) {
        // Start background flexible update without blocking gameplay
        await startFlexibleUpdate();
      }
    } catch (e) {
      debugPrint('Automatic update check skipped: $e');
    }
  }

  /// Starts a flexible background update
  Future<AppUpdateResult?> startFlexibleUpdate() async {
    if (!isPlatformSupported) return null;

    try {
      _listenToInstallUpdates();
      _status = AppUpdateStatus.downloading;
      notifyListeners();

      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.userDeniedUpdate) {
        _status = AppUpdateStatus.available;
        notifyListeners();
      }
      return result;
    } on PlatformException catch (e) {
      debugPrint('startFlexibleUpdate PlatformException: $e');
      _status = AppUpdateStatus.failed;
      _lastErrorMessage = _mapPlatformError(e);
      notifyListeners();
      return AppUpdateResult.inAppUpdateFailed;
    } catch (e) {
      debugPrint('startFlexibleUpdate unexpected error: $e');
      _status = AppUpdateStatus.failed;
      notifyListeners();
      return AppUpdateResult.inAppUpdateFailed;
    }
  }

  /// Performs a full-screen immediate update
  Future<AppUpdateResult?> performImmediateUpdate() async {
    if (!isPlatformSupported) return null;

    try {
      _status = AppUpdateStatus.installing;
      notifyListeners();

      final result = await InAppUpdate.performImmediateUpdate();
      if (result == AppUpdateResult.userDeniedUpdate) {
        _status = AppUpdateStatus.available;
        notifyListeners();
      }
      return result;
    } on PlatformException catch (e) {
      debugPrint('performImmediateUpdate PlatformException: $e');
      _status = AppUpdateStatus.failed;
      _lastErrorMessage = _mapPlatformError(e);
      notifyListeners();
      return AppUpdateResult.inAppUpdateFailed;
    } catch (e) {
      debugPrint('performImmediateUpdate unexpected error: $e');
      _status = AppUpdateStatus.failed;
      notifyListeners();
      return AppUpdateResult.inAppUpdateFailed;
    }
  }

  /// Completes a flexible update by restarting the app to apply the installed files
  Future<bool> completeFlexibleUpdate() async {
    if (!isPlatformSupported) return false;

    try {
      _status = AppUpdateStatus.installing;
      notifyListeners();
      await InAppUpdate.completeFlexibleUpdate();
      return true;
    } catch (e) {
      debugPrint('completeFlexibleUpdate error: $e');
      _status = AppUpdateStatus.failed;
      notifyListeners();
      return false;
    }
  }

  /// Listens to Google Play download/install status events
  void _listenToInstallUpdates() {
    _installSubscription?.cancel();
    try {
      _installSubscription = InAppUpdate.installUpdateListener.listen(
        (InstallStatus status) {
          debugPrint('InAppUpdate InstallStatus: $status');
          switch (status) {
            case InstallStatus.downloading:
              _status = AppUpdateStatus.downloading;
              notifyListeners();
              break;
            case InstallStatus.downloaded:
              _status = AppUpdateStatus.downloaded;
              notifyListeners();
              showDownloadedSnackBar();
              break;
            case InstallStatus.installing:
              _status = AppUpdateStatus.installing;
              notifyListeners();
              break;
            case InstallStatus.installed:
              _status = AppUpdateStatus.idle;
              notifyListeners();
              break;
            case InstallStatus.failed:
            case InstallStatus.canceled:
              _status = AppUpdateStatus.failed;
              notifyListeners();
              break;
            default:
              break;
          }
        },
        onError: (error) {
          debugPrint('installUpdateListener stream error: $error');
          _status = AppUpdateStatus.failed;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error attaching installUpdateListener: $e');
    }
  }

  /// Displays a floating SnackBar notifying the user that the update is ready to install
  void showDownloadedSnackBar() {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.system_update_rounded, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'An update has finished downloading!',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(days: 1), // Persistent until action or dismiss
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF1E293B),
        action: SnackBarAction(
          label: 'RESTART',
          textColor: AppColors.primary,
          onPressed: () {
            completeFlexibleUpdate();
          },
        ),
      ),
    );
  }

  /// Maps native Play Core error codes to clear, friendly user explanations
  String _mapPlatformError(PlatformException e) {
    final code = e.code.toUpperCase();
    final message = e.message ?? '';

    if (code.contains('ERROR_API_NOT_AVAILABLE') ||
        message.contains('ERROR_API_NOT_AVAILABLE') ||
        code == '-3') {
      return 'In-app updates require the app to be installed via Google Play Store.';
    }
    if (code.contains('ERROR_PLAY_STORE_NOT_FOUND') ||
        message.contains('ERROR_PLAY_STORE_NOT_FOUND')) {
      return 'Google Play Store was not found on this device.';
    }
    if (code.contains('APP_NOT_OWNED') || message.contains('APP_NOT_OWNED')) {
      return 'The app is not associated with your active Google Play account.';
    }
    if (code.contains('ERROR_CANNOT_SHOW_INSTALL_DIALOG')) {
      return 'Cannot display Google Play update dialog at this time.';
    }
    if (code.contains('USER_DENIED_UPDATE')) {
      return 'Update cancelled by user.';
    }
    return message.isNotEmpty
        ? message
        : 'Update check could not be completed.';
  }

  @override
  void dispose() {
    _installSubscription?.cancel();
    super.dispose();
  }
}

