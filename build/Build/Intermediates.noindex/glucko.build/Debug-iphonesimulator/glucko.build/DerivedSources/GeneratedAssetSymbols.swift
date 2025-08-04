import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "bell" asset catalog image resource.
    static let bell = DeveloperToolsSupport.ImageResource(name: "bell", bundle: resourceBundle)

    /// The "camera" asset catalog image resource.
    static let camera = DeveloperToolsSupport.ImageResource(name: "camera", bundle: resourceBundle)

    /// The "diary-filled" asset catalog image resource.
    static let diaryFilled = DeveloperToolsSupport.ImageResource(name: "diary-filled", bundle: resourceBundle)

    /// The "diary-outline" asset catalog image resource.
    static let diaryOutline = DeveloperToolsSupport.ImageResource(name: "diary-outline", bundle: resourceBundle)

    /// The "gluco" asset catalog image resource.
    static let gluco = DeveloperToolsSupport.ImageResource(name: "gluco", bundle: resourceBundle)

    /// The "rewards-filled" asset catalog image resource.
    static let rewardsFilled = DeveloperToolsSupport.ImageResource(name: "rewards-filled", bundle: resourceBundle)

    /// The "rewards-outline" asset catalog image resource.
    static let rewardsOutline = DeveloperToolsSupport.ImageResource(name: "rewards-outline", bundle: resourceBundle)

    /// The "user" asset catalog image resource.
    static let user = DeveloperToolsSupport.ImageResource(name: "user", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "bell" asset catalog image.
    static var bell: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bell)
#else
        .init()
#endif
    }

    /// The "camera" asset catalog image.
    static var camera: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .camera)
#else
        .init()
#endif
    }

    /// The "diary-filled" asset catalog image.
    static var diaryFilled: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .diaryFilled)
#else
        .init()
#endif
    }

    /// The "diary-outline" asset catalog image.
    static var diaryOutline: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .diaryOutline)
#else
        .init()
#endif
    }

    /// The "gluco" asset catalog image.
    static var gluco: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .gluco)
#else
        .init()
#endif
    }

    /// The "rewards-filled" asset catalog image.
    static var rewardsFilled: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rewardsFilled)
#else
        .init()
#endif
    }

    /// The "rewards-outline" asset catalog image.
    static var rewardsOutline: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rewardsOutline)
#else
        .init()
#endif
    }

    /// The "user" asset catalog image.
    static var user: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .user)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "bell" asset catalog image.
    static var bell: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bell)
#else
        .init()
#endif
    }

    /// The "camera" asset catalog image.
    static var camera: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .camera)
#else
        .init()
#endif
    }

    /// The "diary-filled" asset catalog image.
    static var diaryFilled: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .diaryFilled)
#else
        .init()
#endif
    }

    /// The "diary-outline" asset catalog image.
    static var diaryOutline: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .diaryOutline)
#else
        .init()
#endif
    }

    /// The "gluco" asset catalog image.
    static var gluco: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .gluco)
#else
        .init()
#endif
    }

    /// The "rewards-filled" asset catalog image.
    static var rewardsFilled: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rewardsFilled)
#else
        .init()
#endif
    }

    /// The "rewards-outline" asset catalog image.
    static var rewardsOutline: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rewardsOutline)
#else
        .init()
#endif
    }

    /// The "user" asset catalog image.
    static var user: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .user)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

