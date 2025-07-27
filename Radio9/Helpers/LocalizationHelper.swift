import Foundation

struct LocalizationHelper {
    static func getLocalizedString(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}