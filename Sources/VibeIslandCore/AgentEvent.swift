import Foundation

public struct SessionStarted: Equatable, Sendable {
    public var sessionID: String
    public var title: String
    public var tool: AgentTool
    public var summary: String
    public var timestamp: Date
    public var jumpTarget: JumpTarget?

    public init(
        sessionID: String,
        title: String,
        tool: AgentTool,
        summary: String,
        timestamp: Date,
        jumpTarget: JumpTarget? = nil
    ) {
        self.sessionID = sessionID
        self.title = title
        self.tool = tool
        self.summary = summary
        self.timestamp = timestamp
        self.jumpTarget = jumpTarget
    }
}

public struct SessionActivityUpdated: Equatable, Sendable {
    public var sessionID: String
    public var summary: String
    public var phase: SessionPhase
    public var timestamp: Date

    public init(
        sessionID: String,
        summary: String,
        phase: SessionPhase,
        timestamp: Date
    ) {
        self.sessionID = sessionID
        self.summary = summary
        self.phase = phase
        self.timestamp = timestamp
    }
}

public struct PermissionRequested: Equatable, Sendable {
    public var sessionID: String
    public var request: PermissionRequest
    public var timestamp: Date

    public init(
        sessionID: String,
        request: PermissionRequest,
        timestamp: Date
    ) {
        self.sessionID = sessionID
        self.request = request
        self.timestamp = timestamp
    }
}

public struct QuestionAsked: Equatable, Sendable {
    public var sessionID: String
    public var prompt: QuestionPrompt
    public var timestamp: Date

    public init(
        sessionID: String,
        prompt: QuestionPrompt,
        timestamp: Date
    ) {
        self.sessionID = sessionID
        self.prompt = prompt
        self.timestamp = timestamp
    }
}

public struct SessionCompleted: Equatable, Sendable {
    public var sessionID: String
    public var summary: String
    public var timestamp: Date

    public init(
        sessionID: String,
        summary: String,
        timestamp: Date
    ) {
        self.sessionID = sessionID
        self.summary = summary
        self.timestamp = timestamp
    }
}

public struct JumpTargetUpdated: Equatable, Sendable {
    public var sessionID: String
    public var jumpTarget: JumpTarget
    public var timestamp: Date

    public init(
        sessionID: String,
        jumpTarget: JumpTarget,
        timestamp: Date
    ) {
        self.sessionID = sessionID
        self.jumpTarget = jumpTarget
        self.timestamp = timestamp
    }
}

public enum AgentEvent: Equatable, Sendable {
    case sessionStarted(SessionStarted)
    case activityUpdated(SessionActivityUpdated)
    case permissionRequested(PermissionRequested)
    case questionAsked(QuestionAsked)
    case sessionCompleted(SessionCompleted)
    case jumpTargetUpdated(JumpTargetUpdated)
}

public struct ScheduledAgentEvent: Equatable, Sendable {
    public var delay: TimeInterval
    public var event: AgentEvent

    public init(delay: TimeInterval, event: AgentEvent) {
        self.delay = delay
        self.event = event
    }
}
