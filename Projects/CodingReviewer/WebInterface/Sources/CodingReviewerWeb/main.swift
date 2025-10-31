import JavaScriptKit
import SwiftWebAPI

@main
struct CodingReviewerWeb {
    static func main() {
        // Initialize JavaScript environment
        let document = JSObject.global.document
        let console = JSObject.global.console

        console.log("CodingReviewer Web - Initializing...")

        // Create main container
        let container = document.createElement("div")
        container.id = "coding-reviewer-container"
        container.innerHTML = """
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px;">
            <header style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #2563eb; margin-bottom: 10px;">🤖 CodingReviewer Web</h1>
                <p style="color: #6b7280; font-size: 16px;">AI-Powered Code Review Platform</p>
            </header>

            <div style="display: grid; grid-template-columns: 250px 1fr; gap: 20px; height: 600px;">
                <!-- Sidebar -->
                <nav style="background: #f8fafc; border-radius: 8px; padding: 20px; border: 1px solid #e2e8f0;">
                    <h3 style="margin-top: 0; color: #1e293b;">Navigation</h3>
                    <ul style="list-style: none; padding: 0; margin: 0;">
                        <li style="margin-bottom: 10px;">
                            <button id="welcome-btn" style="width: 100%; padding: 10px; background: #3b82f6; color: white; border: none; border-radius: 6px; cursor: pointer;">Welcome</button>
                        </li>
                        <li style="margin-bottom: 10px;">
                            <button id="review-btn" style="width: 100%; padding: 10px; background: #64748b; color: white; border: none; border-radius: 6px; cursor: pointer;">Code Review</button>
                        </li>
                        <li>
                            <button id="analysis-btn" style="width: 100%; padding: 10px; background: #64748b; color: white; border: none; border-radius: 6px; cursor: pointer;">Analysis</button>
                        </li>
                    </ul>
                </nav>

                <!-- Main Content -->
                <main id="main-content" style="background: white; border-radius: 8px; padding: 20px; border: 1px solid #e2e8f0; overflow-y: auto;">
                    <div id="welcome-content">
                        <h2>Welcome to CodingReviewer Web</h2>
                        <p>This is a web-deployed version of the CodingReviewer application, built with SwiftWasm.</p>
                        <div style="background: #f0f9ff; border: 1px solid #0ea5e9; border-radius: 6px; padding: 15px; margin: 20px 0;">
                            <h3 style="margin-top: 0; color: #0c4a6e;">🚀 Features</h3>
                            <ul style="color: #0c4a6e;">
                                <li>AI-powered code analysis</li>
                                <li>Automated code review</li>
                                <li>Performance optimization suggestions</li>
                                <li>Security vulnerability detection</li>
                                <li>Cross-platform compatibility</li>
                            </ul>
                        </div>
                        <p><strong>Status:</strong> <span style="color: #059669;">Web deployment successful! 🎉</span></p>
                    </div>
                </main>
            </div>
        </div>
        """

        // Add to document body
        _ = document.body.appendChild(container)

        // Add event listeners
        setupEventListeners(document, console)

        console.log("CodingReviewer Web - Initialization complete!")
    }

    static func setupEventListeners(_ document: JSObject, _ console: JSObject) {
        // Welcome button
        if let welcomeBtn = document.getElementById("welcome-btn") {
            _ = welcomeBtn.addEventListener("click", JSClosure { _ in
                updateMainContent(document, "welcome")
                console.log("Welcome view selected")
                return .undefined
            })
        }

        // Review button
        if let reviewBtn = document.getElementById("review-btn") {
            _ = reviewBtn.addEventListener("click", JSClosure { _ in
                updateMainContent(document, "review")
                console.log("Code review view selected")
                return .undefined
            })
        }

        // Analysis button
        if let analysisBtn = document.getElementById("analysis-btn") {
            _ = analysisBtn.addEventListener("click", JSClosure { _ in
                updateMainContent(document, "analysis")
                console.log("Analysis view selected")
                return .undefined
            })
        }
    }

    static func updateMainContent(_ document: JSObject, _ view: String) {
        guard let mainContent = document.getElementById("main-content") else { return }

        switch view {
        case "welcome":
            mainContent.innerHTML = """
            <div id="welcome-content">
                <h2>Welcome to CodingReviewer Web</h2>
                <p>This is a web-deployed version of the CodingReviewer application, built with SwiftWasm.</p>
                <div style="background: #f0f9ff; border: 1px solid #0ea5e9; border-radius: 6px; padding: 15px; margin: 20px 0;">
                    <h3 style="margin-top: 0; color: #0c4a6e;">🚀 Features</h3>
                    <ul style="color: #0c4a6e;">
                        <li>AI-powered code analysis</li>
                        <li>Automated code review</li>
                        <li>Performance optimization suggestions</li>
                        <li>Security vulnerability detection</li>
                        <li>Cross-platform compatibility</li>
                    </ul>
                </div>
                <p><strong>Status:</strong> <span style="color: #059669;">Web deployment successful! 🎉</span></p>
            </div>
            """

        case "review":
            mainContent.innerHTML = """
            <div id="review-content">
                <h2>AI Code Review</h2>
                <p>Upload your code files for AI-powered review and analysis.</p>
                <div style="background: #fef3c7; border: 1px solid #f59e0b; border-radius: 6px; padding: 15px; margin: 20px 0;">
                    <h3 style="margin-top: 0; color: #92400e;">📁 File Upload</h3>
                    <input type="file" id="file-input" multiple style="margin: 10px 0;">
                    <button id="analyze-btn" style="padding: 10px 20px; background: #f59e0b; color: white; border: none; border-radius: 6px; cursor: pointer;">Analyze Code</button>
                </div>
                <div id="review-results" style="margin-top: 20px;"></div>
            </div>
            """

        case "analysis":
            mainContent.innerHTML = """
            <div id="analysis-content">
                <h2>Code Analysis Dashboard</h2>
                <p>Comprehensive analysis of your codebase with AI insights.</p>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px 0;">
                    <div style="background: #ecfdf5; border: 1px solid #10b981; border-radius: 6px; padding: 15px;">
                        <h4 style="margin-top: 0; color: #065f46;">✅ Code Quality</h4>
                        <p style="color: #065f46; margin: 5px 0;">Excellent - 95% score</p>
                        <div style="background: #d1fae5; height: 8px; border-radius: 4px; overflow: hidden;">
                            <div style="background: #10b981; width: 95%; height: 100%;"></div>
                        </div>
                    </div>
                    <div style="background: #fef3c7; border: 1px solid #f59e0b; border-radius: 6px; padding: 15px;">
                        <h4 style="margin-top: 0; color: #92400e;">⚠️ Performance</h4>
                        <p style="color: #92400e; margin: 5px 0;">Good - 78% optimized</p>
                        <div style="background: #fde68a; height: 8px; border-radius: 4px; overflow: hidden;">
                            <div style="background: #f59e0b; width: 78%; height: 100%;"></div>
                        </div>
                    </div>
                    <div style="background: #fee2e2; border: 1px solid #ef4444; border-radius: 6px; padding: 15px;">
                        <h4 style="margin-top: 0; color: #991b1b;">🔒 Security</h4>
                        <p style="color: #991b1b; margin: 5px 0;">Needs attention - 2 issues</p>
                        <div style="background: #fecaca; height: 8px; border-radius: 4px; overflow: hidden;">
                            <div style="background: #ef4444; width: 60%; height: 100%;"></div>
                        </div>
                    </div>
                </div>
            </div>
            """

        default:
            break
        }
    }
}
