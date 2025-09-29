import SwiftUI

@MainActor
public final class AnimationManager: ObservableObject {
    public static let shared = AnimationManager()

    private init() {}

    public struct DescribedAnimation: CustomStringConvertible {
        public let animation: Animation
        private let providedDescription: String

        public init(animation: Animation, description: String) {
            self.animation = animation
            self.providedDescription = description
        }

        public nonisolated var description: String { self.providedDescription }
    }

    public enum Duration {
        public static let ultraFast: Double = 0.1
        public static let fast: Double = 0.2
        public static let standard: Double = 0.3
        public static let medium: Double = 0.5
        public static let slow: Double = 0.8
        public static let loading: Double = 1.5
    }

    public enum Springs {
        public static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
        public static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)
        public static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0)
        public static let smooth = Animation.spring(response: 0.4, dampingFraction: 1.0, blendDuration: 0)
    }

    public enum Easing {
        public static let easeIn = Animation.easeIn(duration: Duration.standard)
        public static let easeOut = Animation.easeOut(duration: Duration.standard)
        public static let easeInOut = Animation.easeInOut(duration: Duration.standard)
        public static let linear = Animation.linear(duration: Duration.standard)
    }

    public static func cardEntry(delay: Double = 0) -> Animation {
        Springs.gentle.delay(delay)
    }

    public static func transactionEntry(index: Int) -> Animation {
        Springs.snappy.delay(Double(index) * 0.05)
    }

    public static var buttonPress: Animation {
        Springs.snappy
    }

    public static var loading: DescribedAnimation {
        let animation = Animation.easeInOut(duration: Duration.loading).repeatForever(autoreverses: true)
        return DescribedAnimation(animation: animation, description: "repeatForever(autoreverses: true)")
    }

    public static var error: DescribedAnimation {
        let animation = Animation.easeInOut(duration: Duration.fast).repeatCount(3, autoreverses: true)
        return DescribedAnimation(animation: animation, description: "repeatCount(3, autoreverses: true)")
    }

    public static var loadingAnimation: Animation { self.loading.animation }

    public static var errorAnimation: Animation { self.error.animation }

    public static var budgetProgress: Animation {
        Animation.easeInOut(duration: Duration.medium)
    }
}

public extension View {
    func cardEntrance(delay: Double = 0) -> some View {
        self.scaleEffect(0.95)
            .opacity(0)
            .onAppear {
                withAnimation(AnimationManager.cardEntry(delay: delay)) {}
            }
    }

    func buttonPressAnimation() -> some View {
        self.scaleEffect(1.0)
            .animation(AnimationManager.buttonPress, value: false)
    }

    func fadeIn(delay: Double = 0) -> some View {
        self.opacity(0)
            .onAppear {
                withAnimation(AnimationManager.Easing.easeIn.delay(delay)) {}
            }
    }
}

public extension AnyTransition {
    @MainActor static var scaleAndFade: AnyTransition {
        .modifier(
            active: scaleopacityTransitionModifier(scale: 0.95, opacity: 0),
            identity: scaleopacityTransitionModifier(scale: 1, opacity: 1)
        )
    }

    static var cardFlip: AnyTransition {
        .asymmetric(
            insertion: .modifier(active: CardFlipModifier(rotation: 90), identity: CardFlipModifier(rotation: 0)),
            removal: .modifier(active: CardFlipModifier(rotation: -90), identity: CardFlipModifier(rotation: 0))
        )
    }
}

public struct CardFlipModifier: ViewModifier {
    public let rotation: Double

    public func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(self.rotation), axis: (x: 0, y: 1, z: 0))
    }
}

// swiftlint:disable type_name
public struct scaleopacityTransitionModifier: ViewModifier, CustomStringConvertible {
    let scale: CGFloat
    let opacity: Double

    public init(scale: CGFloat, opacity: Double) {
        self.scale = scale
        self.opacity = opacity
    }

    public nonisolated var description: String {
        "scale transition with scale \(self.scale) and opacity \(self.opacity)"
    }

    public func body(content: Content) -> some View {
        content
            .scaleEffect(self.scale)
            .opacity(self.opacity)
    }
}

// swiftlint:enable type_name

public struct LoadingIndicator: View {
    @State private var isAnimating = false
    public let style: Style

    public enum Style {
        case dots
        case spinner
        case pulse
    }

    public init(style: Style) {
        self.style = style
    }

    public var body: some View {
        Group {
            switch self.style {
            case .dots:
                HStack(spacing: 4) {
                    ForEach(0 ..< 3, id: \.self) { index in
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 8, height: 8)
                            .scaleEffect(self.isAnimating ? 1.2 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2),
                                value: self.isAnimating
                            )
                    }
                }
            case .spinner:
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.accentColor, lineWidth: 3)
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(self.isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1).repeatForever(autoreverses: false),
                        value: self.isAnimating
                    )
            case .pulse:
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 20, height: 20)
                    .scaleEffect(self.isAnimating ? 1.2 : 0.8)
                    .opacity(self.isAnimating ? 0.5 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1).repeatForever(autoreverses: true),
                        value: self.isAnimating
                    )
            }
        }
        .onAppear { self.isAnimating = true }
        .onDisappear { self.isAnimating = false }
    }
}

public struct AnimatedProgressBar: View {
    public let progress: Double
    public let color: Color
    public let height: CGFloat
    @State private var animatedProgress: Double = 0

    public init(progress: Double, color: Color = .accentColor, height: CGFloat = 12) {
        self.progress = progress
        self.color = color
        self.height = height
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(self.color.opacity(0.2))
                    .frame(height: self.height)

                Rectangle()
                    .fill(self.color)
                    .frame(width: geometry.size.width * self.animatedProgress, height: self.height)
                    .animation(AnimationManager.budgetProgress, value: self.animatedProgress)
            }
        }
        .frame(height: self.height)
        .clipShape(RoundedRectangle(cornerRadius: self.height / 2))
        .onAppear {
            self.animatedProgress = min(max(self.progress, 0), 1)
        }
        .onChange(of: self.progress) { _, newValue in
            self.animatedProgress = min(max(newValue, 0), 1)
        }
    }
}

public extension Edge {
    var opposite: Edge {
        switch self {
        case .top:
            return .bottom
        case .bottom:
            return .top
        case .leading:
            return .trailing
        case .trailing:
            return .leading
        @unknown default:
            return self
        }
    }
}
