//
//  AnimationHelpers.swift
//  Multi-User Family Quiz Arena
//
//  Helper utilities for animations and transitions
//  Provides reusable animation modifiers and effects
//

import SwiftUI

// MARK: - Custom Transitions

extension AnyTransition {
    /// Slide and fade transition from bottom
    static var slideUpFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }

    /// Scale and fade transition
    static var scaleFade: AnyTransition {
        .scale(scale: 0.5).combined(with: .opacity)
    }

    /// Slide from trailing edge
    static var slideFromTrailing: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    /// Bounce scale effect
    static var bounceScale: AnyTransition {
        .modifier(
            active: ScaleModifier(scale: 0.1),
            identity: ScaleModifier(scale: 1.0)
        )
    }
}

struct ScaleModifier: ViewModifier {
    let scale: CGFloat

    func body(content: Content) -> some View {
        content.scaleEffect(scale)
    }
}

// MARK: - Animation Modifiers

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

extension View {
    /// Apply shake animation
    func shake(trigger: Int) -> some View {
        modifier(ShakeEffect(animatableData: CGFloat(trigger)))
    }

    /// Pulse animation
    func pulse(isAnimating: Bool) -> some View {
        scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
    }

    /// Glow effect
    func glow(color: Color = .white, radius: CGFloat = 20, isActive: Bool = true) -> some View {
        self.shadow(color: isActive ? color : .clear, radius: radius)
    }
}

// MARK: - Particle System for Celebrations

struct ParticleEffect: View {
    let particleCount: Int
    let particleColor: Color
    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particleColor)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        for _ in 0..<particleCount {
            let particle = Particle(
                position: CGPoint(x: size.width / 2, y: size.height / 2),
                size: CGFloat.random(in: 5...15),
                opacity: 1.0
            )
            particles.append(particle)

            animateParticle(particle, in: size)
        }
    }

    private func animateParticle(_ particle: Particle, in size: CGSize) {
        withAnimation(.easeOut(duration: 1.5)) {
            if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                particles[index].position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
                particles[index].opacity = 0.0
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .white.opacity(0.3),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1000
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Focus Animation Helper

struct FocusableButton<Content: View>: View {
    let content: Content
    let action: () -> Void

    @FocusState private var isFocused: Bool
    @State private var isPressed = false

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: {
            isPressed = true
            SoundManager.shared.playButtonTap()
            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            content
                .scaleEffect(isFocused ? 1.08 : (isPressed ? 0.95 : 1.0))
                .brightness(isFocused ? 0.1 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFocused)
                .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .focused($isFocused)
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    let colors: [Color]

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Counting Number Animation

struct AnimatedNumber: View {
    let value: Int
    let duration: Double

    @State private var displayValue: Int = 0

    var body: some View {
        Text("\(displayValue)")
            .onAppear {
                animateNumber()
            }
            .onChange(of: value) { newValue in
                animateNumber()
            }
    }

    private func animateNumber() {
        let steps = 20
        let stepValue = Double(value) / Double(steps)
        let stepDuration = duration / Double(steps)

        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                displayValue = Int(stepValue * Double(i))
            }
        }
    }
}

// MARK: - Loading Indicator

struct PulsingDot: View {
    @State private var isPulsing = false
    let delay: Double

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 20, height: 20)
            .scaleEffect(isPulsing ? 1.2 : 0.8)
            .opacity(isPulsing ? 1.0 : 0.5)
            .animation(
                .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct LoadingIndicator: View {
    var body: some View {
        HStack(spacing: 15) {
            PulsingDot(delay: 0.0)
            PulsingDot(delay: 0.2)
            PulsingDot(delay: 0.4)
        }
    }
}

// MARK: - Progress Ring Animation

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let ringColor: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(ringColor.opacity(0.3), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}
