const std = @import("std");
const lsp = @import("lsp");

const Lsp = lsp.Lsp(std.fs.File);

const builtin = @import("builtin");

pub const std_options = .{
    .log_level = .debug,
    .logFn = lsp.log,
};

pub fn main() !u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const server_data = lsp.types.ServerData{
        .serverInfo = .{
            .name = "tester",
            .version = "0.1.0",
        },
    };

    var file = try std.fs.cwd().createFile("output.txt", .{ .truncate = true });
    defer file.close();

    var server = Lsp.init(allocator, server_data);
    defer server.deinit();

    server.registerDocOpenCallback(handleOpenDoc);
    server.registerDocChangeCallback(handleChangeDoc);
    server.registerDocSaveCallback(handleSaveDoc);
    server.registerDocCloseCallback(handleCloseDoc);
    server.registerHoverCallback(handleHover);
    server.registerCodeActionCallback(handleCodeAction);

    server.registerGoToDeclarationCallback(handleGoToDeclaration);
    server.registerGoToDefinitionCallback(handleGotoDefinition);
    server.registerGoToTypeDefinitionCallback(handleGoToTypeDefinition);
    server.registerGoToImplementationCallback(handleGoToImplementation);
    server.registerFindReferencesCallback(handleFindReferences);

    return try server.start();
}

fn handleOpenDoc(_: std.mem.Allocator, context: *Lsp.Context) void {
    const file = std.fs.cwd().createFile("output.txt", .{ .truncate = true }) catch unreachable;
    context.state = file;
    _ = context.state.?.write("Opened document\n") catch unreachable;
}
fn handleCloseDoc(_: std.mem.Allocator, context: *Lsp.Context) void {
    _ = context.state.?.write("Closed document\n") catch unreachable;
    context.state.?.close();
}
fn handleChangeDoc(_: std.mem.Allocator, context: *Lsp.Context, _: []lsp.types.ChangeEvent) void {
    _ = context.state.?.write("Changed document\n") catch unreachable;
}
fn handleSaveDoc(_: std.mem.Allocator, context: *Lsp.Context) void {
    _ = context.state.?.write("Saved document\n") catch unreachable;
}
fn handleHover(_: std.mem.Allocator, context: *Lsp.Context, _: lsp.types.Position) ?[]const u8 {
    _ = context.state.?.write("Hover\n") catch unreachable;
    return null;
}
fn handleCodeAction(_: std.mem.Allocator, context: *Lsp.Context, _: lsp.types.Range) ?[]const lsp.types.Response.CodeAction.Result {
    _ = context.state.?.write("Code action\n") catch unreachable;
    return null;
}
fn handleGoToDeclaration(_: std.mem.Allocator, context: *Lsp.Context, _: lsp.types.Position) ?lsp.types.Location {
    _ = context.state.?.write("Go to declaration\n") catch unreachable;
    return null;
}
fn handleGotoDefinition(_: std.mem.Allocator, context: *Lsp.Context, _: lsp.types.Position) ?lsp.types.Location {
    _ = context.state.?.write("Go to definition\n") catch unreachable;
    return null;
}
fn handleGoToTypeDefinition(_: std.mem.Allocator, context: *Lsp.Context, _: lsp.types.Position) ?lsp.types.Location {
    _ = context.state.?.write("Go to type definition\n") catch unreachable;
    return null;
}
fn handleGoToImplementation(_: std.mem.Allocator, context: *Lsp.Context, _: lsp.types.Position) ?lsp.types.Location {
    _ = context.state.?.write("Go to implementation\n") catch unreachable;
    return null;
}
fn handleFindReferences(_: std.mem.Allocator, context: *Lsp.Context, _: lsp.types.Position) ?[]lsp.types.Location {
    _ = context.state.?.write("Find references\n") catch unreachable;
    return null;
}

test "Run nvim" {
    const nvim_config =
        \\ vim.lsp.set_log_level("TRACE")
        \\local start_tester = function()
        \\    local client = vim.lsp.start_client { name = "tester", cmd = { "zig-out/bin/test" }, trace = "verbose"}
        \\
        \\    if not client then
        \\        vim.notify("Failed to start tester")
        \\    else
        \\        vim.api.nvim_create_autocmd("FileType",
        \\            { pattern = "text", callback = function() vim.lsp.buf_attach_client(0, client) end }
        \\        )
        \\    end
        \\end
        \\start_tester()
    ;
    std.fs.cwd().writeFile(.{ .sub_path = "nvim_config.lua", .data = nvim_config }) catch unreachable;
    defer std.fs.cwd().deleteFile("nvim_config.lua") catch {};

    const commands =
        \\vim.cmd(":norm itext")
        \\vim.lsp.buf.hover()
        \\vim.cmd(":norm itext")
        \\vim.lsp.buf.code_action()
        \\vim.lsp.buf.definition()
        \\vim.lsp.buf.declaration()
        \\vim.lsp.buf.type_definition()
        \\vim.lsp.buf.implementation()
        \\vim.lsp.buf.references()
        \\vim.cmd(":wq")
    ;
    std.fs.cwd().writeFile(.{ .sub_path = "commands.lua", .data = commands }) catch unreachable;
    defer std.fs.cwd().deleteFile("commands.lua") catch {};
    const argv = [_][]const u8{
        "nvim",
        "--headless",
        "-u",
        "nvim_config.lua",
        "test.txt",
        "-c",
        "sleep 1", // ls doesn't start properly without this sleep
        "-l",
        "commands.lua",
    };
    var child = std.process.Child.init(&argv, std.testing.allocator);

    try child.spawn();
    const term = try child.wait();
    defer std.fs.cwd().deleteFile("output.txt") catch {};
    defer std.fs.cwd().deleteFile("test.txt") catch {};

    try std.testing.expectEqual(term.Exited, 0);

    const expected =
        \\Opened document
        \\Changed document
        \\Hover
        \\Changed document
        \\Code action
        \\Go to definition
        \\Go to declaration
        \\Go to type definition
        \\Go to implementation
        \\Find references
        \\Saved document
        \\
    ;
    const actual = try std.fs.cwd().readFileAlloc(std.testing.allocator, "output.txt", 1000000);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualStrings(expected, actual);
}
