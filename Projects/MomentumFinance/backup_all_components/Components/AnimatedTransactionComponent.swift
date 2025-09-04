//
//  AnimatedTransactionComponent.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// Enhanced transaction list item with smooth animations
struct AnimatedTransactionItem: View {
    let transaction: FinancialTransaction
    let index: Int
    @State private var isVisible = false
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 16) {
            // Transaction type icon with animation
            ZStack {
                Circle()
                    .fill(transaction.transactionType == .income ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: transaction.transactionType == .income ? "arrow.down.left" : "arrow.up.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(transaction.transactionType == .income ? .green : .red)
                    .rotationEffect(.degrees(isVisible ? 0 : 180))
                    .animation(AnimationManager.Springs.bouncy.delay(Double(index) * 0.05), value: isVisible)
            }

            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                    .lineLimit(1)
                    .opacity(isVisible ? 1.0 : 0)
                    .offset(x: isVisible ? 0 : -20)
                    .animation(AnimationManager.Springs.gentle.delay(Double(index) * 0.1), value: isVisible)

                if let categoryName = transaction.category?.name {
                    Text(categoryName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(isVisible ? 1.0 : 0)
                        .offset(x: isVisible ? 0 : -15)
                        .animation(AnimationManager.Springs.gentle.delay(Double(index) * 0.15), value: isVisible)
                }

                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(isVisible ? 1.0 : 0)
                    .offset(x: isVisible ? 0 : -10)
                    .animation(AnimationManager.Springs.gentle.delay(Double(index) * 0.2), value: isVisible)
            }

            Spacer()

            // Amount with slide-in animation
            Text(transaction.amount.formatted(.currency(code: "USD")))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.transactionType == .income ? .green : .red)
                .opacity(isVisible ? 1.0 : 0)
                .offset(x: isVisible ? 0 : 30)
                .animation(AnimationManager.Springs.smooth.delay(Double(index) * 0.1), value: isVisible)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .opacity(isPressed ? 1.0 : 0)
                .animation(AnimationManager.Springs.snappy, value: isPressed)
        )
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0)
        .animation(AnimationManager.transactionEntry(index: index), value: isVisible)
        .onAppear {
            isVisible = true
        }
        .onTapGesture {
            withAnimation(AnimationManager.Springs.snappy) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(AnimationManager.Springs.snappy) {
                    isPressed = false
                }
            }

            #if os(iOS)
                HapticManager.shared.selection()
            #endif
        }
    }
}
