# MCPHub Tool Invocation Prompt

## How to Use MCPHub REST API to Execute Tools

MCPHub exposes a REST API endpoint for tool execution. Agents (such as opencode) can invoke tools on MCPHub by sending a POST request to the following endpoint:

```
POST http://localhost:8081/api/servers/tools
```

### How to discover tools
MCP servers and their tools are defined in a file at `~/.config/mcphub/servers.json`. Read this file so that you understand what tools are available to you and how to interact with them.

### Request Payload Format

The payload must be a JSON object with the following fields:
- `tool`: The name of the tool to execute (e.g., `get_current_time`).
- `server`: The MCPHub server name (e.g., `time`).
- `args`: Arguments for the tool as a JSON object (e.g., `{ "city": "Berlin" }`).

**Example Request:**
```json
{
  "tool": "get_current_time",
  "server": "time",
  "args": { "city": "Berlin" }
}
```

### Example cURL Command
```bash
curl -X POST http://localhost:8081/api/servers/tools \
  -H "Content-Type: application/json" \
  -d '{
    "tool": "get_current_time",
    "server": "time",
    "args": { "city": "Berlin" }
  }'
```

### Example Response
```json
{
  "result": "2025-07-29T12:34:56+02:00"
}
```

## Notes
- The MCPHub server name must match the name in your MCPHub configuration (see `~/.config/mcphub/servers.json`).
- The tool name and arguments must match the tool's specification.
- The response will be a JSON object containing the result.

---
This prompt documents how agents can reliably invoke MCPHub tools via REST API in your config-driven workspace.

