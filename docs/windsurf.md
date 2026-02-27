---
nav_order: 16
---

# Windsurf

Windsurf is a tool that allows you to generate code based on your existing codebase.

When prompted by you, it can run what it calls 'workflows', which are scripts that you feed into the LLM to perform useful tasks for you.

It can also draw on 'skills', which are small scripts that perform specific tasks. The difference is that skills are run automatically by the LLM when it deems it appropriate.

It's good to have open as a second window to call on if needed. Rubymine is (for now) the primary IDE for development.

## Setup

1. Install Windsurf
2. Open the repository in Windsurf
3. To see what workflows have been added, look inside the .windsurf/workflows directory.
4. To see what skills have been added, look inside the .windsurf/skills directory.
5. When it's time to complete a task for a workflow, give it a run by starting by typing "/workflow-name" into the Cascade window.

## Workflow specific setup
### GitHub MCP
Allows workflows to view the GitHub repository to see state of pull requests and pipeline runs.

To setup, access your MCP config file and add the following:

```json
{
  "mcpServers": {
    "github-mcp-server": {
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_TOOLSETS=default,actions",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN=<generate PAT token>",
        "ghcr.io/github/github-mcp-server"
      ],
      "disabled": false,
      "command": "docker"
    }
  }
}
```

For the PAT token, recommended scopes are repo:* and workflow.

### Playwright

Screenshot pipelines need playwright-cli. Install playwright cli globally like so:

```bash
npm install -g @playwright/cli@latest
```

See more: https://github.com/microsoft/playwright-cli.

You may want to add playwright-cli * to the Windsurf allowlist so it can run commands automatically.

Right now the script tells the LLM that a server is already running on port 3000. Make sure this is true before running the script with the changes you want screenshots of.