import Foundation
import os

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

private let analyticsLogger = Logger(subsystem: "edu.uts.tuannm3812.Circleu", category: "Analytics")

/// Privacy-safe analytics tracker that logs to the console/OSLog for debugging
/// and sends events to Firebase Analytics if configured.
struct FirebaseAnalyticsTracker: AnalyticsTracking {
    nonisolated func track(_ event: AnalyticsEvent) {
        // 1. Log locally for developer debugging and console review
        analyticsLogger.info("Analytics Event: \(event.name) with properties: \(event.properties)")

        // 2. Log to live Firebase Analytics if available
        #if canImport(FirebaseAnalytics)
        if FirebaseRuntime.canUseLiveFirebase {
            Analytics.logEvent(event.name, parameters: event.properties)
        }
        #endif
    }
}

/// Global shared registry for the analytics tracking boundary.
enum AnalyticsService {
    nonisolated(unsafe) static var shared: any AnalyticsTracking = NoOpAnalyticsTracker()
}
