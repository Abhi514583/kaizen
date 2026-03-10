import SwiftUI

extension Font {
    // MARK: - Kaizen Typography System
    // Utilizing SF Pro Rounded to create a friendly but structured appearance.
    
    /// Large Header (Day / Ritual Header)
    static var kaizenLargeHeader: Font {
        .system(size: 48, weight: .bold, design: .rounded)
    }
    
    /// Section Header
    static var kaizenSectionHeader: Font {
        .system(size: 24, weight: .semibold, design: .rounded)
    }
    
    /// Body Text
    static var kaizenBody: Font {
        .system(size: 16, weight: .medium, design: .rounded)
    }
    
    /// Secondary Metadata Text
    static var kaizenMetadata: Font {
        .system(size: 14, weight: .regular, design: .rounded)
    }
}
