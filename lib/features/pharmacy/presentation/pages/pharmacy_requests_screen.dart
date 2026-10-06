import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/back_title_bar.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../../../core/widgets/status_views.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../cubit/requests/pharmacy_requests_cubit.dart';
import '../widgets/pharmacy_request_card.dart';

/// The pharmacy's prescription requests, newest first. Reached from home;
/// [PharmacyRequestsCubit] is provided by the route.
class PharmacyRequestsScreen extends StatelessWidget {
  const PharmacyRequestsScreen({super.key});

  Future<void> _open(BuildContext context, PharmacyRequest request) async {
    final PharmacyRequestsCubit cubit = context.read<PharmacyRequestsCubit>();
    await context.pushNamed(
      AppRoutes.pharmacyRequestName,
      pathParameters: <String, String>{'id': '${request.id}'},
    );
    // A quote may have been sent there.
    if (!cubit.isClosed) cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleCubit>();
    final PharmacyRequestsCubit cubit = context.read<PharmacyRequestsCubit>();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocListener<PharmacyRequestsCubit, PharmacyRequestsState>(
        listenWhen:
            (PharmacyRequestsState previous, PharmacyRequestsState current) =>
                current is PharmacyRequestsLoaded &&
                current.refreshFailure != null &&
                !identical(
                  previous is PharmacyRequestsLoaded
                      ? previous.refreshFailure
                      : null,
                  current.refreshFailure,
                ),
        listener: (BuildContext context, PharmacyRequestsState state) =>
            showBrandSnackBar(
              context,
              (state as PharmacyRequestsLoaded).refreshFailure!.message,
              isError: true,
            ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            color: context.colors.primary,
            child: BlocBuilder<PharmacyRequestsCubit, PharmacyRequestsState>(
              builder: (BuildContext context, PharmacyRequestsState state) =>
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: <Widget>[
                      BackTitleBar(title: Strings.pharmacyRequestsTitle),
                      const SizedBox(height: 20),
                      ...switch (state) {
                        PharmacyRequestsLoading() => <Widget>[
                          const SectionLoadingView(),
                        ],
                        PharmacyRequestsLoadFailure(:final message) => <Widget>[
                          RetryErrorView(message: message, onRetry: cubit.load),
                        ],
                        PharmacyRequestsLoaded(:final requests)
                            when requests.isEmpty =>
                          <Widget>[
                            NoDataFound(text: Strings.noPharmacyRequests),
                          ],
                        PharmacyRequestsLoaded(:final requests) => <Widget>[
                          for (final PharmacyRequest request in requests)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PharmacyRequestCard(
                                key: ValueKey<int>(request.id),
                                request: request,
                                onTap: () => _open(context, request),
                              ),
                            ),
                        ],
                      },
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
