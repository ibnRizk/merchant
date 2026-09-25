import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../../core/widgets/tip_banner.dart';
import '../../domain/entities/merchant_order.dart';
import '../../domain/entities/order_line.dart';
import '../../domain/entities/order_status.dart';
import '../cubit/order_details/order_details_cubit.dart';
import '../utils/order_display.dart';
import '../utils/order_notice_messages.dart';
import '../widgets/active_order_detail_card.dart' show progressSteps;
import '../widgets/order_action_buttons.dart';
import '../widgets/order_card_header.dart';
import '../widgets/order_details_section.dart';
import '../widgets/order_item_row.dart';
import '../widgets/order_progress_stepper.dart';
import '../widgets/orders_screen_header.dart';
import '../widgets/reject_order_sheet.dart';
import '../widgets/system_notice_banner.dart';

/// One order's summary, lines and next action. [OrderDetailsCubit] is
/// provided by the route.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleCubit>();
    final OrderDetailsCubit cubit = context.read<OrderDetailsCubit>();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocListener<OrderDetailsCubit, OrderDetailsState>(
        listenWhen: (OrderDetailsState previous, OrderDetailsState current) =>
            current is OrderDetailsLoaded &&
            isNewNotice(
              previous is OrderDetailsLoaded ? previous.notice : null,
              current.notice,
            ),
        listener: (BuildContext context, OrderDetailsState state) =>
            showOrderNotice(
              context,
              state is OrderDetailsLoaded ? state.notice : null,
            ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            color: context.colors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: <Widget>[
                OrdersScreenHeader(
                  title: Strings.orderDetailsTitle,
                  leading: const BrandBackButton(),
                ),
                const SizedBox(height: 16),
                BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
                  builder: (BuildContext context, OrderDetailsState state) =>
                      switch (state) {
                        OrderDetailsLoading() => const SectionLoadingView(),
                        OrderDetailsLoadFailure(:final message) =>
                          RetryErrorView(
                            message: message,
                            onRetry: cubit.refresh,
                          ),
                        OrderDetailsLoaded() => _OrderDetailsBody(state: state),
                      },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailsBody extends StatelessWidget {
  const _OrderDetailsBody({required this.state});

  final OrderDetailsLoaded state;

  Future<void> _reject(BuildContext context) async {
    final OrderDetailsCubit cubit = context.read<OrderDetailsCubit>();
    final RejectDecision? decision = await showRejectOrderSheet(context);
    if (decision == null || cubit.isClosed) return;
    cubit.reject(reason: decision.reason, note: decision.note);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final OrderDetailsCubit cubit = context.read<OrderDetailsCubit>();
    final MerchantOrder order = state.order;
    final (Color pillBackground, Color pillText) = order.status.pillColors(
      colors,
    );
    final OrderAction? next = order.status.nextAction;
    final bool showProgress =
        order.status == OrderStatus.accepted ||
        order.status == OrderStatus.preparing ||
        order.status == OrderStatus.readyForPickup;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OrderDetailsSection(
          children: <Widget>[
            OrderCardHeader(
              title: order.number,
              subtitle: order.createdAt == null
                  ? ''
                  : formatOrderTime(
                      order.createdAt!,
                      Localizations.localeOf(context).languageCode,
                    ),
              trailingWidget: StatusPill(
                label: order.status.label,
                background: pillBackground,
                textColor: pillText,
              ),
            ),
            if (showProgress) ...<Widget>[
              const SizedBox(height: 16),
              OrderProgressStepper(steps: progressSteps(order.status, colors)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        OrderDetailsSection(
          children: <Widget>[
            if (order.customerName.isNotEmpty)
              OrderInfoField(
                label: Strings.customerLabel,
                value: order.customerLabel,
              ),
            if (order.address.isNotEmpty)
              OrderInfoField(
                label: Strings.deliveryAddressLabel,
                value: order.address.bidiIsolated,
                maxLines: 3,
              ),
            if (order.paymentLabel.isNotEmpty)
              OrderInfoField(
                label: Strings.paymentMethodLabel,
                value: order.paymentLabel,
              ),
          ],
        ),
        const SizedBox(height: 12),
        OrderDetailsSection(
          title: Strings.orderItems,
          children: <Widget>[
            for (final OrderLine line in state.lines) OrderItemRow(line: line),
            const SizedBox(height: 6),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 6),
            if (order.deliveryCharge > 0)
              OrderAmountRow(
                label: Strings.deliveryFee,
                amount: formatOrderAmount(order.deliveryCharge),
              ),
            OrderAmountRow(
              label: Strings.orderTotal,
              amount: order.amountLabel,
              isEmphasized: true,
            ),
          ],
        ),
        if (order.note.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          TipBanner(
            boldPrefix: Strings.customerNote,
            text: order.note.bidiIsolated,
          ),
        ],
        const SizedBox(height: 20),
        if (next == OrderAction.accept)
          OrderActionButtons(
            onAccept: cubit.accept,
            onReject: () => _reject(context),
            isBusy: state.isBusy,
          )
        else if (next != null)
          PrimaryButton(
            label: next == OrderAction.startPreparing
                ? Strings.startPreparing
                : Strings.statusReadyForPickup,
            isLoading: state.isBusy,
            onPressed: cubit.advance,
          ),
        if (next == OrderAction.readyForPickup) ...<Widget>[
          const SizedBox(height: 12),
          SystemNoticeBanner(text: Strings.systemWillNotifyDriver),
        ],
      ],
    );
  }
}
