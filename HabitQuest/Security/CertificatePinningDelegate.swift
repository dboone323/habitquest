import Foundation

/// Certificate pinning delegate for URLSession
final class CertificatePinningDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {
    // Replace with your actual certificate data (DER format)
    private let pinnedCertificateData: Data = {
        // Load from bundle or hardcode for demo
        guard let certURL = Bundle.main.url(forResource: "server", withExtension: "cer"),
            let data = try? Data(contentsOf: certURL)
        else {
            print(
                "Warning: Pinned certificate 'server.cer' not found in bundle. Pinning disabled/failed."
            )
            return Data()
        }
        return data
    }()

    func urlSession(
        _ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // If we don't have a pinned cert, we can't pin.
        // In a strict app, you might want to cancel here.
        if pinnedCertificateData.isEmpty {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let policy = SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
        SecTrustSetPolicies(serverTrust, policy)

        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
            let serverCert = certificates.first
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let serverCertData = SecCertificateCopyData(serverCert) as Data

        if serverCertData == pinnedCertificateData {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Pinning failed
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
