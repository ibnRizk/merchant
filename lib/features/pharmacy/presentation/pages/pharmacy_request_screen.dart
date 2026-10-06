import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/back_title_bar.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../app_config/presentation/cubit/app_config_cubit.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../cubit/request/pharmacy_request_cubit.dart';
import '../utils/pharmacy_display.dart';
import '../widgets/prescription_view.dart';
import '../widgets/quote_form.dart';

/// One prescription request: the customer's note and prescription, and the
/// price quote. [PharmacyRequestCubit] is provided by the route.
class PharmacyRequestScreen extends StatelessWidget {
  const PharmacyRequestScreen({super.key, required this.requestId});

  final int requestId;

  void _onNotice(BuildContext context, PharmacyRequestState state) {
    switch (state is PharmacyRequestLoaded ? state.notice : null) {
      case QuoteSentNotice():
        showBrandSnackBar(context, Strings.quoteSent);
      case QuoteInvalidNotice(:final error):
        showBrandSnackBar(context, error.message, isError: true);
      case RequestNotActionableNotice():
        showBrandSnackBar(
          context,
          Strings.pharmacyRequestNotActionable,
          isError: true,
          duration: const Duration(seconds: 4),
        );
      case PharmacyFailureNotice(:final message):
        showBrandSnackBar(context, message, isError: true);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleCubit>();
    final PharmacyRequestCubit cubit = context.read<PharmacyRequestCubit>();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocListener<PharmacyRequestCubit, PharmacyRequestState>(
        listenWhen:
            (PharmacyRequestState previous, PharmacyRequestState current) =>
                current is PharmacyRequestLoaded &&
                current.notice != null &&
                !identical(
                  previous is PharmacyRequestLoaded ? previous.notice : null,
                  current.notice,
                ),
        listener: _onNotice,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: <Widget>[
              BackTitleBar(
                title:
                    '${Strings.pharmacyRequestPrefix}${'#$requestId'.ltrIsolated}',
              ),
              const SizedBox(height: 20),
              BlocBuilder<PharmacyRequestCubit, PharmacyRequestState>(
                builder: (BuildContext context, PharmacyRequestState state) =>
                    switch (state) {
                      PharmacyRequestLoading() => const SectionLoadingView(),
                      PharmacyRequestLoadFailure(:final message) =>
                        RetryErrorView(
                          message: message,
                          onRetry: () => cubit.load(requestId),
                        ),
                      PharmacyRequestLoaded() => _RequestBody(state: state),
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestBody extends StatelessWidget {
  const _RequestBody({required this.state});

  final PharmacyRequestLoaded state;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final PharmacyRequestCubit cubit = context.read<PharmacyRequestCubit>();
    final String currency = context.currency;
    final PharmacyRequest request = state.request;
    final (Color pillBackground, Color pillText) = request.status.pillColors(
      colors,
    );
    final TextStyle body = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13.5,
      color: colors.textPrimary,
    );
    final TextStyle muted = body.copyWith(
      fontSize: 12.5,
      color: colors.textSecondary,
    );
    final DateTime? createdAt = request.createdAt;
    final PharmacyQuote? quote = request.quote;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      request.customerName.isEmpty
                          ? Strings.customerLabel
                          : request.customerName.bidiIsolated,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  StatusPill(
                    label: request.status.label,
                    background: pillBackground,
                    textColor: pillText,
                  ),
                ],
              ),
              if (createdAt != null)
                Text(
                  formatRequestTime(
                    createdAt,
                    Localizations.localeOf(context).languageCode,
                  ),
                  style: muted,
                ),
              if (request.customerNote.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(Strings.customerRequestNote, style: muted),
                const SizedBox(height: 2),
                Text(request.customerNote.bidiIsolated, style: body),
              ],
            ],
          ),
        ),
        if (request.hasPrescription) ...<Widget>[
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SectionTitle(Strings.prescription),
                const SizedBox(height: 10),
                PrescriptionView(
                  status: state.prescriptionStatus,
                  bytes: state.prescription,
                  onRetry: cubit.loadPrescription,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SectionTitle(Strings.priceQuote),
              const SizedBox(height: 4),
              if (request.status.canQuote) ...<Widget>[
                Text(
                  request.status == PharmacyRequestStatus.quoted
                      ? Strings.quoteWaitingForCustomer
                      : Strings.quoteHint,
                  style: muted,
                ),
                const SizedBox(height: 12),
                QuoteForm(
                  // A new form when the saved quote changes (after a send
                  // or a reload), so it shows what the server holds.
                  key: ValueKey<PharmacyQuote?>(quote),
                  initial: quote,
                  currency: currency,
                  isSending: state.isSending,
                  onSubmit: cubit.sendQuote,
                ),
              ] else if (quote != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  formatMoney(quote.amount, currency),
                  style: body.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (quote.summary.isNotEmpty)
                  Text(quote.summary.bidiIsolated, style: body),
                if (quote.note.isNotEmpty)
                  Text(quote.note.bidiIsolated, style: muted),
              ] else
                Text(Strings.pharmacyRequestClosed, style: muted),
            ],
          ),
        ),
      ],
    );
  }
}
