import SwiftUI // For Color
import Foundation // For UUID

public struct PriceAnnotation: Identifiable, Hashable {
    public let id: UUID
    public var priceLevel: Double
    public var color: Color // Allow customization later, default for now
    public var label: String? // Optional text label for the annotation

    public init(id: UUID = UUID(), priceLevel: Double, color: Color = .orange, label: String? = nil) {
        self.id = id
        self.priceLevel = priceLevel
        self.color = color
        self.label = label
    }
}
