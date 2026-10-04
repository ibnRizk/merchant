import '../../../../../core/entities/merchant_approval_status.dart';
import '../../../domain/entities/launch_destination.dart';

sealed class SplashState {
  const SplashState();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashResolved extends SplashState {
  final LaunchDestination destination;

  /// Set when [destination] is [LaunchDestination.pendingApproval].
  final MerchantApprovalStatus? approvalStatus;

  const SplashResolved(this.destination, {this.approvalStatus});
}
