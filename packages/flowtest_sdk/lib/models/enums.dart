enum FlowAction {
  tap,
  input,
  scroll,
  longPress,
  wait, // fixed time or until condition
  expect, // standalone assertion step
}

enum ExpectCondition {
  isVisible,
  isHidden,
  isEnabled,
  isDisabled,
  hasText,
  containsText,
  matchesRegex,
  exists,
  notExists,
}
