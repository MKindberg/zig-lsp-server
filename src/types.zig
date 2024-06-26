const std = @import("std");

pub const Request = struct {
    pub const Request = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        method: []u8,
    };
    pub const Initialize = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        method: []u8,
        params: Params,

        const Params = struct {
            clientInfo: ?ClientInfo,
            trace: ?TraceValue,

            const ClientInfo = struct {
                name: []u8,
                version: []u8,
            };
        };
    };

    // Used by hover, goto definition, etc.
    pub const PositionRequest = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        method: []u8,
        params: PositionParams,
    };

    pub const CodeAction = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        method: []u8,
        params: Params,

        pub const Params = struct {
            textDocument: TextDocumentIdentifier,
            range: Range,
            context: CodeActionContext,

            const CodeActionContext = struct {};
        };
    };

    pub const Shutdown = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        method: []u8,
    };
};

pub const Response = struct {
    pub const Initialize = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        result: ServerData,

        const Self = @This();

        pub fn init(id: i32, server_data: ServerData) Self {
            return Self{
                .jsonrpc = "2.0",
                .id = id,
                .result = server_data,
            };
        }
    };

    pub const Hover = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        result: ?Result = null,

        const Result = struct {
            contents: []const u8,
        };

        const Self = @This();
        pub fn init(id: i32, contents: []const u8) Self {
            return Self{
                .id = id,
                .result = .{
                    .contents = contents,
                },
            };
        }
    };

    pub const CodeAction = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        result: ?[]const Result = null,

        pub const Result = struct {
            title: []const u8,
            edit: ?WorkspaceEdit,
            const WorkspaceEdit = struct {
                changes: std.json.ArrayHashMap([]const TextEdit),
            };
        };
    };

    // Used by goto definition, etc.
    pub const LocationResponse = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        result: ?Location = null,

        const Self = @This();
        pub fn init(id: i32, location: Location) Self {
            return Self{
                .id = id,
                .result = location,
            };
        }
    };

    pub const MultiLocationResponse = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        result: ?[]const Location = null,

        const Self = @This();
        pub fn init(id: i32, locations: []const Location) Self {
            return Self{
                .id = id,
                .result = locations,
            };
        }
    };

    pub const Shutdown = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        result: void,

        const Self = @This();
        pub fn init(request: Request.Shutdown) Self {
            return Self{
                .jsonrpc = "2.0",
                .id = request.id,
                .result = {},
            };
        }
    };

    pub const Error = struct {
        jsonrpc: []const u8 = "2.0",
        id: i32,
        @"error": ErrorData,

        const Self = @This();
        pub fn init(id: i32, code: ErrorCode, message: []const u8) Self {
            return Self{
                .jsonrpc = "2.0",
                .id = id,
                .@"error" = .{
                    .code = code,
                    .message = message,
                },
            };
        }
    };
};

pub const Notification = struct {
    pub const DidOpenTextDocument = struct {
        jsonrpc: []const u8 = "2.0",
        method: []u8,
        params: Params,

        pub const Params = struct {
            textDocument: TextDocumentItem,
        };
    };

    pub const DidChangeTextDocument = struct {
        jsonrpc: []const u8 = "2.0",
        method: []u8,
        params: Params,

        pub const Params = struct {
            textDocument: VersionedTextDocumentIdentifier,
            contentChanges: []ChangeEvent,

            const VersionedTextDocumentIdentifier = struct {
                uri: []u8,
                version: i32,
            };
        };
    };

    pub const DidSaveTextDocument = struct {
        jsonrpc: []const u8 = "2.0",
        method: []u8,
        params: Params,
        pub const Params = struct {
            textDocument: TextDocumentIdentifier,
        };
    };

    pub const DidCloseTextDocument = struct {
        jsonrpc: []const u8 = "2.0",
        method: []u8,
        params: Params,
        pub const Params = struct {
            textDocument: TextDocumentIdentifier,
        };
    };

    pub const PublishDiagnostics = struct {
        jsonrpc: []const u8 = "2.0",
        method: []const u8 = "textDocument/publishDiagnostics",
        params: Params,
        pub const Params = struct {
            uri: []const u8,
            diagnostics: []const Diagnostic,
        };
    };

    pub const Exit = struct {
        jsonrpc: []const u8 = "2.0",
        method: []u8,
    };

    pub const LogMessage = struct {
        jsonrpc: []const u8 = "2.0",
        method: []const u8 = "window/logMessage",
        params: Params,
        pub const Params = struct {
            type: MessageType,
            message: []const u8,
        };
    };

    pub const LogTrace = struct {
        jsonrpc: []const u8 = "2.0",
        method: []const u8 = "$/logTrace",
        params: Params,
        pub const Params = struct {
            message: []const u8,
            verbose: ?[]const u8 = null,
        };
    };
};

const TextDocumentItem = struct {
    uri: []u8,
    languageId: []u8,
    version: i32,
    text: []u8,
};

const TextDocumentIdentifier = struct {
    uri: []u8,
};

pub const ServerData = struct {
    capabilities: ServerCapabilities = .{},
    serverInfo: ServerInfo,

    const ServerCapabilities = struct {
        textDocumentSync: TextDocumentSyncOptions = .{},
        hoverProvider: bool = false,
        codeActionProvider: bool = false,
        declarationProvider: bool = false,
        definitionProvider: bool = false,
        typeDefinitionProvider: bool = false,
        implementationProvider: bool = false,
        referencesProvider: bool = false,
    };
    const ServerInfo = struct { name: []const u8, version: []const u8 };
};

pub const Range = struct {
    start: Position,
    end: Position,
};
pub const Position = struct {
    line: usize,
    character: usize,
};

pub const PositionParams = struct {
    textDocument: TextDocumentIdentifier,
    position: Position,
};

pub const Location = struct {
    uri: []const u8,
    range: Range,
};

pub const TextEdit = struct {
    range: Range,
    newText: []const u8,
};

pub const ChangeEvent = struct {
    range: Range,
    text: []const u8,
};

pub const Diagnostic = struct {
    range: Range,
    severity: i32,
    source: ?[]const u8,
    message: []const u8,
};

pub const ErrorData = struct {
    code: ErrorCode,
    message: []const u8,
};

pub const ErrorCode = enum(i32) {
    ParseError = -32700,
    InvalidRequest = -32600,
    MethodNotFound = -32601,
    InvalidParams = -32602,
    InternalError = -32603,

    const Self = @This();
    pub fn jsonStringify(self: Self, out: anytype) !void {
        return out.print("{}", .{@intFromEnum(self)});
    }
};

pub const MessageType = enum(i32) {
    Error = 1,
    Warning = 2,
    Info = 3,
    Log = 4,
    Debug = 5,

    const Self = @This();
    pub fn jsonStringify(self: Self, out: anytype) !void {
        return out.print("{}", .{@intFromEnum(self)});
    }
};

pub const TextDocumentSyncKind = enum(i32) {
    None = 0,
    Full = 1,
    Incremental = 2,

    const Self = @This();
    pub fn jsonStringify(self: Self, out: anytype) !void {
        return out.print("{}", .{@intFromEnum(self)});
    }
};

pub const TraceValue = enum {
    Off,
    Messages,
    Verbose,

    const Self = @This();
    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Self {
        _ = options;
        switch (try source.nextAlloc(allocator, .alloc_if_needed)) {
            inline .string, .allocated_string => |s| {
                if (std.mem.eql(u8, s, "off")) {
                    return .Off;
                } else if (std.mem.eql(u8, s, "messages")) {
                    return .Messages;
                } else if (std.mem.eql(u8, s, "verbose")) {
                    return .Verbose;
                } else {
                    return error.UnexpectedToken;
                }
            },
            else => return error.UnexpectedToken,
        }
    }
};

pub const TextDocumentSyncOptions = struct {
    openClose: bool = true,
    change: TextDocumentSyncKind = .Incremental,
    save: bool = false,
};
