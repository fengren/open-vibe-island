import AppKit
import Foundation
import Observation
import VibeIslandCore

@MainActor
@Observable
final class AppModel {
    var state = SessionState()
    var selectedSessionID: String?
    var isOverlayVisible = false
    var lastActionMessage = "No interaction yet."

    @ObservationIgnored
    private var bridgeTask: Task<Void, Never>?

    @ObservationIgnored
    private let overlayPanelController = OverlayPanelController()

    var sessions: [AgentSession] {
        state.sessions
    }

    var focusedSession: AgentSession? {
        state.session(id: selectedSessionID) ?? state.activeActionableSession ?? state.sessions.first
    }

    func startIfNeeded() {
        guard bridgeTask == nil else {
            return
        }

        resetDemo()
        bridgeTask = Task { [weak self] in
            guard let self else {
                return
            }

            while !Task.isCancelled {
                for scheduledEvent in MockAgentScenario.timeline(referenceDate: .now) {
                    let sleepNanoseconds = UInt64(scheduledEvent.delay * 1_000_000_000)
                    try? await Task.sleep(nanoseconds: sleepNanoseconds)

                    guard !Task.isCancelled else {
                        return
                    }

                    self.state.apply(scheduledEvent.event)

                    if let activeAction = self.state.activeActionableSession {
                        self.selectedSessionID = activeAction.id
                    }
                }

                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard !Task.isCancelled else {
                    return
                }

                self.resetDemo()
            }
        }
    }

    func resetDemo() {
        state = SessionState()
        MockAgentScenario.initialEvents.forEach { state.apply($0) }
        selectedSessionID = state.activeActionableSession?.id ?? state.sessions.first?.id
        lastActionMessage = "Demo reset."
    }

    func select(sessionID: String) {
        selectedSessionID = sessionID
    }

    func toggleOverlay() {
        if isOverlayVisible {
            overlayPanelController.hide()
            isOverlayVisible = false
        } else {
            overlayPanelController.show(model: self)
            isOverlayVisible = true
        }
    }

    func approveFocusedPermission(_ approved: Bool) {
        guard let session = focusedSession else {
            return
        }

        state.resolvePermission(sessionID: session.id, approved: approved)
        lastActionMessage = approved
            ? "Approved permission for \(session.title)."
            : "Denied permission for \(session.title)."
    }

    func answerFocusedQuestion(_ answer: String) {
        guard let session = focusedSession else {
            return
        }

        state.answerQuestion(sessionID: session.id, answer: answer)
        lastActionMessage = "Answered \(session.title) with \"\(answer)\"."
    }

    func jumpToFocusedSession() {
        guard let session = focusedSession, let jumpTarget = session.jumpTarget else {
            lastActionMessage = "No jump target is available yet."
            return
        }

        lastActionMessage = "Jump target: \(jumpTarget.terminalApp) · \(jumpTarget.workspaceName) · \(jumpTarget.paneTitle)"
        NSApp.activate(ignoringOtherApps: true)
    }
}
