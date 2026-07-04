import Foundation

/// Copies the static web files from the app bundle to the sandbox directory.
/// Called once at first launch before starting the Go service.
/// Mirrors Android's asset extraction in GoServerRunner.start().
class StaticFileManager {
    private static let didExtractKey = "static_files_extracted"

    enum StaticFileError: LocalizedError {
        case missingBundleDirectory

        var errorDescription: String? {
            switch self {
            case .missingBundleDirectory:
                return "Static files are missing from the app bundle"
            }
        }
    }

    static func ensureStaticFiles() throws {
        let targetDir = URL(fileURLWithPath: DirectoryHelper.staticDir)
        guard let bundleDir = Bundle.main.resourceURL?.appendingPathComponent("Static") else {
            throw StaticFileError.missingBundleDirectory
        }

        if FileManager.default.fileExists(atPath: targetDir.path) {
            try FileManager.default.removeItem(at: targetDir)
        }
        try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true)

        let files = try FileManager.default.contentsOfDirectory(at: bundleDir, includingPropertiesForKeys: nil)
        if files.isEmpty {
            throw StaticFileError.missingBundleDirectory
        }
        for file in files {
            let dest = targetDir.appendingPathComponent(file.lastPathComponent)
            try FileManager.default.copyItem(at: file, to: dest)
        }
    }
}
