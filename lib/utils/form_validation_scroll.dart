import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Validates [formKey] and scrolls to the first field with a validation error.
bool validateFormAndScrollToError(GlobalKey<FormState> formKey) {
  final formState = formKey.currentState;
  if (formState == null) return false;
  if (formState.validate()) return true;

  SchedulerBinding.instance.addPostFrameCallback((_) {
    final errorContext = findFirstFormFieldError(formState.context);
    if (errorContext != null) {
      scrollToContext(errorContext);
    }
  });
  return false;
}

void scrollToContext(BuildContext context) {
  Scrollable.ensureVisible(
    context,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeInOut,
    alignment: 0.12,
    alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
  );
}

void scrollToKey(GlobalKey key) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    final context = key.currentContext;
    if (context != null) scrollToContext(context);
  });
}

BuildContext? findFirstFormFieldError(BuildContext root) {
  BuildContext? found;
  void walk(Element element) {
    if (found != null) return;
    if (element.widget is FormField) {
      final stateful = element;
      if (stateful is StatefulElement) {
        final state = stateful.state;
        if (state is FormFieldState<dynamic> && state.hasError) {
          found = state.context;
          return;
        }
      }
    }
    element.visitChildren(walk);
  }
  final element = root as Element?;
  if (element != null) walk(element);
  return found;
}
