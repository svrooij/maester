// Helpers for the "Changes since last run" feature.
//
// When Invoke-Maester is run with -CompareToPrevious, every test in the results
// carries a `PreviousResult` property: the outcome (e.g. "Passed"/"Failed") from
// the previous run, or `null` when the test did not exist in the previous run.
// When the run was not compared against a previous one the property is absent.

type TestResultLike = {
  Result?: unknown
  PreviousResult?: unknown
  [key: string]: unknown
}

/**
 * Returns true when the property `PreviousResult` is present on the test, which
 * indicates the run was compared against a previous run.
 */
export function hasPreviousResult(test: TestResultLike | null | undefined): boolean {
  return !!test && Object.prototype.hasOwnProperty.call(test, "PreviousResult")
}

/**
 * Returns true when any test in the collection carries comparison data, i.e. the
 * report was produced with -CompareToPrevious.
 */
export function hasComparisonData(tests: readonly TestResultLike[] | null | undefined): boolean {
  return Array.isArray(tests) && tests.some(hasPreviousResult)
}

/**
 * Normalizes the previous outcome to a display string, or undefined when the
 * test is new (no previous outcome) or was not compared.
 */
export function getPreviousResult(test: TestResultLike | null | undefined): string | undefined {
  if (!hasPreviousResult(test)) return undefined
  const previous = test?.PreviousResult
  return typeof previous === "string" && previous.length > 0 ? previous : undefined
}

/**
 * Returns true when a test changed since the previous run. A test counts as
 * changed when its current result differs from its previous outcome, and when a
 * test is new (comparison ran but there is no previous outcome).
 */
export function isTestChanged(test: TestResultLike | null | undefined): boolean {
  if (!hasPreviousResult(test)) return false
  const previous = getPreviousResult(test)
  // New test: comparison ran but there is no previous outcome.
  if (previous === undefined) return true
  return previous !== test?.Result
}
