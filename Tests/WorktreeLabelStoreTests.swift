import XCTest
@testable import seahelm

final class WorktreeLabelStoreTests: XCTestCase {
    private func freshPath() -> String { "/tmp/seahelm-label-test-\(UUID().uuidString)" }

    func testSetAndGetRoundTrip() {
        let path = freshPath()
        WorktreeLabelStore.shared.set(.teal, forWorktree: path)
        XCTAssertEqual(WorktreeLabelStore.shared.label(forWorktree: path), .teal)
    }

    func testUnlabelledPathIsNil() {
        XCTAssertNil(WorktreeLabelStore.shared.label(forWorktree: freshPath()))
    }

    /// "None" in the menu clears the entry rather than storing an empty value —
    /// worktree paths get reused, and a leftover would label whatever is created
    /// at that path next.
    func testClearingRemovesTheLabel() {
        let path = freshPath()
        WorktreeLabelStore.shared.set(.pink, forWorktree: path)
        WorktreeLabelStore.shared.set(nil, forWorktree: path)
        XCTAssertNil(WorktreeLabelStore.shared.label(forWorktree: path))
    }

    func testLastWriteWins() {
        let path = freshPath()
        WorktreeLabelStore.shared.set(.red, forWorktree: path)
        WorktreeLabelStore.shared.set(.blue, forWorktree: path)
        XCTAssertEqual(WorktreeLabelStore.shared.label(forWorktree: path), .blue)
    }
}
