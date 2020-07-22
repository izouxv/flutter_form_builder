import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormBuilderField<T> extends FormField<T> {
  final String attribute;
  final ValueTransformer valueTransformer;
  final ValueChanged<T> onChanged;
  final bool readOnly;
  final InputDecoration decoration;
  final VoidCallback onReset;
  final FocusNode focusNode;

  FormBuilderField({
    Key key,
    //From Super
    FormFieldSetter<T> onSaved,
    T initialValue,
    bool autovalidate = false,
    bool enabled = true,
    FormFieldValidator validator,
    @required FormFieldBuilder<T> builder,
    @required this.attribute,
    this.valueTransformer,
    this.onChanged,
    this.readOnly = false,
    this.decoration = const InputDecoration(),
    this.onReset,
    this.focusNode,
  }) : super(
          key: key,
          onSaved: onSaved,
          initialValue: initialValue,
          autovalidate: autovalidate,
          enabled: enabled,
          builder: builder,
          validator: validator,
        );

  @override
  FormBuilderFieldState<T> createState() => FormBuilderFieldState();
}

class FormBuilderFieldState<T> extends FormFieldState<T> {
  @override
  FormBuilderField<T> get widget => super.widget;

  FormBuilderState get formState => _formBuilderState;

  bool get readOnly => _readOnly;

  bool get pristine => !_dirty;

  bool get dirty => !_dirty;

  // Only autovalidate if dirty
  bool get autovalidate => dirty && widget.autovalidate;

  GlobalKey<FormFieldState> get fieldKey => _fieldKey;

  T get initialValue => _initialValue;

  final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();

  FormBuilderState _formBuilderState;

  bool _readOnly = false;

  bool _dirty = false;

  T _initialValue;

  FocusNode _focusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ??
      (_focusNode ??= FocusNode(debugLabel: '${widget.attribute}'));

  @override
  void initState() {
    super.initState();
    _formBuilderState = FormBuilder.of(context);
    _readOnly = _formBuilderState?.readOnly == true || widget.readOnly;
    _formBuilderState?.registerFieldKey(widget.attribute, _fieldKey);
    _initialValue = widget.initialValue ??
        ((_formBuilderState?.initialValue?.containsKey(widget.attribute) ??
                false)
            ? _formBuilderState.initialValue[widget.attribute]
            : null);
    setValue(_initialValue);
  }

  @override
  void save() {
    super.save();
    _formBuilderState?.setInternalAttributeValue(
        widget.attribute, widget.valueTransformer?.call(value) ?? value);
  }

  @override
  void didChange(T value) {
    setState(() {
      _dirty = true;
    });
    super.didChange(value);
    widget.onChanged?.call(value);
  }

  @override
  void reset() {
    super.reset();
    setValue(initialValue);
    widget.onReset?.call();
  }

  @override
  bool validate() {
    return super.validate() && widget.decoration?.errorText == null;
  }

  void requestFocus() {
    FocusScope.of(context).requestFocus(_effectiveFocusNode);
  }

  @override
  void dispose() {
    _formBuilderState?.unregisterFieldKey(widget.attribute);
    // The attachment will automatically be detached in dispose().
    _focusNode?.dispose();
    super.dispose();
  }
}
