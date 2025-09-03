import Foundation
import PDFKit
import SwiftData
import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif

// MARK: - PDF Export Functionality

extension DataExporter {

    /// Export data to PDF format
    func exportToPDF(with settings: ExportSettings) async throws -> URL {
        let pdfData = try await generatePDFData(with: settings)
        return try saveToFile(data: pdfData, filename: "momentum_finance_report.pdf")
    }

    private func generatePDFData(with settings: ExportSettings) async throws -> Data {
        #if os(iOS)
            let renderer = UIGraphicsPDFRenderer(
                bounds: CGRect(x: 0, y: 0, width: 612, height: 792))

            var pdfError: Error?

            let pdfData = renderer.pdfData { context in
                context.beginPage()

                // Title
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.black,
                ]
                let title = "Momentum Finance Report"
                title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)

                // Date range
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                let dateRange =
                    "Period: \(dateFormatter.string(from: settings.startDate)) - \(dateFormatter.string(from: settings.endDate))"
                let dateAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.gray,
                ]
                dateRange.draw(at: CGPoint(x: 50, y: 80), withAttributes: dateAttributes)

                var yPosition = 120.0

                // Add sections based on settings
                if settings.includeTransactions {
                    do {
                        yPosition = try drawTransactionsSummary(
                            context: context.cgContext, yPosition: yPosition, settings: settings
                        )
                    } catch {
                        pdfError = error
                        return
                    }
                }

                if settings.includeAccounts {
                    do {
                        yPosition = try drawAccountsSummary(
                            context: context.cgContext, yPosition: yPosition, settings: settings
                        )
                    } catch {
                        pdfError = error
                        return
                    }
                }
            }

            if let error = pdfError {
                throw error
            }

            return pdfData
        #else
            // For macOS, create PDF data manually
            let pdfData = NSMutableData()
            let pdfInfo = [kCGPDFContextCreator: "Momentum Finance"] as CFDictionary
            guard let dataConsumer = CGDataConsumer(data: pdfData as CFMutableData),
                  let pdfContext = CGContext(consumer: dataConsumer, mediaBox: nil, pdfInfo)
            else {
                throw ExportError.pdfGenerationFailed
            }

            let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
            pdfContext.beginPDFPage(nil)

            // Set up drawing context
            NSGraphicsContext.saveGraphicsState()
            let nsContext = NSGraphicsContext(cgContext: pdfContext, flipped: false)
            NSGraphicsContext.current = nsContext

            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 24),
                .foregroundColor: NSColor.black,
            ]
            let title = "Momentum Finance Report"
            title.draw(at: CGPoint(x: 50, y: pageRect.height - 50), withAttributes: titleAttributes)

            // Date range
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateRange =
                "Period: \(dateFormatter.string(from: settings.startDate)) - \(dateFormatter.string(from: settings.endDate))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.gray,
            ]
            dateRange.draw(
                at: CGPoint(x: 50, y: pageRect.height - 80), withAttributes: dateAttributes
            )

            var yPosition = pageRect.height - 120

            // Add sections based on settings
            if settings.includeTransactions {
                yPosition = try drawTransactionsSummary(
                    context: pdfContext, yPosition: yPosition, settings: settings
                )
            }

            if settings.includeAccounts {
                yPosition = try drawAccountsSummary(
                    context: pdfContext, yPosition: yPosition, settings: settings
                )
            }

            pdfContext.endPDFPage()
            NSGraphicsContext.restoreGraphicsState()

            return pdfData as Data
        #endif
    }

    private func drawTransactionsSummary(
        context: CGContext, yPosition: Double, settings: ExportSettings
    ) throws -> Double {
        let transactions = try fetchTransactions(from: settings.startDate, to: settings.endDate)

        #if os(iOS)
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black,
            ]
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black,
            ]
        #else
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 18),
                .foregroundColor: NSColor.black,
            ]
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12),
                .foregroundColor: NSColor.black,
            ]
        #endif

        "Transactions Summary".draw(
            at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)

        let totalIncome = transactions.filter { $0.transactionType == .income }.reduce(0) {
            $0 + $1.amount
        }
        let totalExpenses = transactions.filter { $0.transactionType == .expense }.reduce(0) {
            $0 + abs($1.amount)
        }
        let netAmount = totalIncome - totalExpenses

        var currentY = yPosition + 30

        "Total Transactions: \(transactions.count)".draw(
            at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
        currentY += 20

        "Total Income: $\(String(format: "%.2f", totalIncome))".draw(
            at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
        currentY += 20

        "Total Expenses: $\(String(format: "%.2f", totalExpenses))".draw(
            at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
        currentY += 20

        "Net Amount: $\(String(format: "%.2f", netAmount))".draw(
            at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
        currentY += 40

        return currentY
    }

    private func drawAccountsSummary(
        context: CGContext, yPosition: Double, settings: ExportSettings
    ) throws -> Double {
        let accounts = try fetchAccounts()

        #if os(iOS)
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black,
            ]
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black,
            ]
        #else
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 18),
                .foregroundColor: NSColor.black,
            ]
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12),
                .foregroundColor: NSColor.black,
            ]
        #endif

        "Accounts Summary".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)

        var currentY = yPosition + 30

        for account in accounts {
            let accountInfo = "\(account.name): $\(String(format: "%.2f", account.balance))"
            accountInfo.draw(at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
            currentY += 20
        }

        return currentY + 20
    }
}
