import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/back_title_bar.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../app_config/presentation/cubit/app_config_cubit.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_options.dart';
import '../cubit/product_options/product_options_cubit.dart';
import '../widgets/option_row_fields.dart';

/// Sizes (variations) and add-ons of one product. [ProductOptionsCubit] is
/// provided by the route and already loading [product].
class ProductOptionsScreen extends StatefulWidget {
  const ProductOptionsScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductOptionsScreen> createState() => _ProductOptionsScreenState();
}

class _ProductOptionsScreenState extends State<ProductOptionsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final List<OptionRowControllers> _variations = <OptionRowControllers>[];
  final List<OptionRowControllers> _addOns = <OptionRowControllers>[];

  /// The fields are filled once, from the first loaded options; later
  /// emits must not overwrite what the merchant is typing.
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    // The listener only sees later emits.
    final ProductOptionsState state = context.read<ProductOptionsCubit>().state;
    if (state is ProductOptionsReady) _seed(state.options);
  }

  @override
  void dispose() {
    _title.dispose();
    for (final OptionRowControllers row in <OptionRowControllers>[
      ..._variations,
      ..._addOns,
    ]) {
      row.dispose();
    }
    super.dispose();
  }

  void _seed(ProductOptions options) {
    _seeded = true;
    _title.text = options.variationTitle.isEmpty
        ? Strings.sizeTitleDefault
        : options.variationTitle;
    _variations.addAll(<OptionRowControllers>[
      for (final ProductVariation v in options.variations)
        OptionRowControllers(name: v.name, price: v.price, stock: v.stock),
    ]);
    _addOns.addAll(<OptionRowControllers>[
      for (final ProductAddOn a in options.addOns)
        OptionRowControllers(name: a.name, price: a.price),
    ]);
  }

  void _addRow(List<OptionRowControllers> rows) =>
      setState(() => rows.add(OptionRowControllers()));

  void _removeRow(List<OptionRowControllers> rows, OptionRowControllers row) {
    setState(() => rows.remove(row));
    // After the frame, so the removed fields are no longer listening.
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProductOptionsCubit>().save(
      ProductOptions(
        variationTitle: _title.text.trim(),
        variations: <ProductVariation>[
          for (final OptionRowControllers row in _variations)
            ProductVariation(
              name: row.name.text.trim(),
              price: parsePrice(row.price.text) ?? 0,
              stock: row.stock,
            ),
        ],
        addOns: <ProductAddOn>[
          for (final OptionRowControllers row in _addOns)
            ProductAddOn(
              name: row.name.text.trim(),
              price: parsePrice(row.price.text) ?? 0,
            ),
        ],
      ),
    );
  }

  void _onState(BuildContext context, ProductOptionsState state) {
    if (state is! ProductOptionsReady) return;
    if (!_seeded) setState(() => _seed(state.options));
    switch (state.notice) {
      case ProductOptionsSavedNotice():
        showBrandSnackBar(context, Strings.optionsSaved);
        Navigator.of(context).maybePop();
      case ProductOptionsInvalidNotice(:final error):
        showBrandSnackBar(context, _errorText(error), isError: true);
      case ProductOptionsFailedNotice(:final message):
        showBrandSnackBar(context, message, isError: true);
      case null:
        break;
    }
  }

  static String _errorText(ProductOptionsError error) => switch (error) {
    ProductOptionsError.missingTitle => Strings.optionTitleRequired,
    ProductOptionsError.emptyName => Strings.optionNameRequired,
    ProductOptionsError.duplicateName => Strings.optionDuplicateName,
    ProductOptionsError.invalidPrice => Strings.optionPriceInvalid,
  };

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleCubit>();
    final AppColors colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<ProductOptionsCubit, ProductOptionsState>(
          listener: _onState,
          builder: (BuildContext context, ProductOptionsState state) =>
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: <Widget>[
                  BackTitleBar(title: Strings.sizesAndAddOns),
                  const SizedBox(height: 6),
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  switch (state) {
                    ProductOptionsLoading() => const SectionLoadingView(),
                    ProductOptionsLoadFailure(:final message) => RetryErrorView(
                      message: message,
                      onRetry: () => context.read<ProductOptionsCubit>().load(
                        widget.product.id,
                      ),
                    ),
                    ProductOptionsReady(:final isSaving) => _buildEditor(
                      isSaving: isSaving,
                    ),
                  },
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildEditor({required bool isSaving}) {
    final String currency = context.currency;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SectionTitle(Strings.sizes),
                const SizedBox(height: 4),
                _Hint(Strings.sizesHint),
                const SizedBox(height: 12),
                AppFormField(
                  label: Strings.optionGroupTitle,
                  controller: _title,
                  validator: (String? text) =>
                      _variations.isNotEmpty && (text ?? '').trim().isEmpty
                      ? Strings.optionTitleRequired
                      : null,
                ),
                for (final OptionRowControllers row in _variations)
                  OptionRowFields(
                    key: ObjectKey(row),
                    row: row,
                    namePlaceholder: Strings.sizeNameHint,
                    currency: currency,
                    onRemove: () => _removeRow(_variations, row),
                  ),
                _AddRowButton(
                  label: Strings.addSize,
                  onPressed: () => _addRow(_variations),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SectionTitle(Strings.addOns),
                const SizedBox(height: 4),
                _Hint(Strings.addOnsHint),
                for (final OptionRowControllers row in _addOns)
                  OptionRowFields(
                    key: ObjectKey(row),
                    row: row,
                    namePlaceholder: Strings.addOnNameHint,
                    currency: currency,
                    allowFree: true,
                    onRemove: () => _removeRow(_addOns, row),
                  ),
                _AddRowButton(
                  label: Strings.addAddOn,
                  onPressed: () => _addRow(_addOns),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: Strings.saveOptions,
            isLoading: isSaving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 12.5,
      color: context.colors.textSecondary,
    ),
  );
}

class _AddRowButton extends StatelessWidget {
  const _AddRowButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
        ),
      ),
      style: TextButton.styleFrom(foregroundColor: context.colors.primary),
    ),
  );
}
