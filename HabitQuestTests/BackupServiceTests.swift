import XCTest
@testable import HabitQuest

@MainActor
final class BackupServiceTests: XCTestCase {
    var backupService: BackupService!
    var createdBackupURL: URL?

    override func setUp() {
        super.setUp()
        backupService = BackupService()
    }

    override func tearDown() {
        if let url = createdBackupURL {
            try? FileManager.default.removeItem(at: url)
        }
        backupService = nil
        super.tearDown()
    }

    func testCreateBackup() throws {
        // Given
        // When
        let url = try backupService.createBackup()
        createdBackupURL = url
        
        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertTrue(url.lastPathComponent.hasPrefix("HabitQuest_Backup_"))
        XCTAssertTrue(url.pathExtension == "json")
        
        // Verify Content
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(json?["backup_date"])
    }

    func testRestoreBackup() throws {
        // Given
        let url = try backupService.createBackup()
        createdBackupURL = url
        
        // When
        // In the prototype, this just prints, so we ensure it doesn't throw
        XCTAssertNoThrow(try backupService.restoreBackup(from: url))
    }
}
