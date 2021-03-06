import Foundation

extension FileManager {
    public func fileExistsAtURL(_ url: URL) -> Bool {
//        guard let path = url.path else { fatalError("Couldn't get path for url: \(url)") }

        return fileExists(atPath: url.path)
    }

    public func removeFileAtURL(_ url: URL) {
//        guard let path = url.path else { fatalError("Couldn't get path for url: \(url)") }

        do {
            try FileManager.default.removeItem(atPath: url.path)
        } catch let error as NSError {
            fatalError("Couldn't remove item at path: \(url.path), error: \(error)")
        }
    }
}
