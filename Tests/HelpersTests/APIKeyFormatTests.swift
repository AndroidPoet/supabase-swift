import Helpers
import Testing

@Suite
struct APIKeyFormatTests {
  @Test(arguments: [
    "sb_publishable_abc123",
    "sb_secret_abc123",
  ])
  func isNewRecognizesNewFormatKeys(key: String) {
    #expect(APIKeyFormat.isNew(key))
  }

  @Test(arguments: [
    "sb_temp_nonce123_payload456",
    "sb_unknown_abc123",
    "header.payload.signature",
    "anon-key",
  ])
  func isNewRejectsNonNewFormatKeys(key: String) {
    #expect(!APIKeyFormat.isNew(key))
  }

  @Test
  func shouldWarnAcceptsRecognizedAndLegacyKeysSilently() {
    #expect(!APIKeyFormat.shouldWarn(for: "sb_publishable_shouldwarn1"))
    #expect(!APIKeyFormat.shouldWarn(for: "sb_secret_shouldwarn1"))
    #expect(!APIKeyFormat.shouldWarn(for: "sb_temp_shouldwarn1_payload"))
    #expect(!APIKeyFormat.shouldWarn(for: "header.payload.signature"))
    #expect(!APIKeyFormat.shouldWarn(for: "anon-key"))
  }

  @Test
  func shouldWarnOnceForUnrecognizedSubtype() {
    // NOTE: `warnedSubtypes` dedup state is module-scoped, so every distinct subtype used in
    // this file must be unique to this test (mirrors the same constraint in supabase-js's
    // fetch.test.ts `checkApiKeyFormat` suite).
    #expect(APIKeyFormat.shouldWarn(for: "sb_uniquesubtypeA_key1"))
    #expect(!APIKeyFormat.shouldWarn(for: "sb_uniquesubtypeA_key2"))
  }

  @Test
  func shouldWarnTreatsDifferentSubtypesIndependently() {
    #expect(APIKeyFormat.shouldWarn(for: "sb_uniquesubtypeB_key1"))
    #expect(APIKeyFormat.shouldWarn(for: "sb_uniquesubtypeC_key1"))
  }

  @Test
  func shouldWarnGroupsUnparsableSubtypesTogether() {
    // Keys with no second underscore share the 'unknown' dedup bucket.
    #expect(APIKeyFormat.shouldWarn(for: "sb_"))
    #expect(!APIKeyFormat.shouldWarn(for: "sb_uniqueunparseabletype"))
  }
}
