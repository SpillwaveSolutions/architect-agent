import { definePlugin } from "opencode/plugin";
import fs from "fs";
import path from "path";

/**
 * OpenCode Logging Plugin - Equivalent to Claude Code hooks.json
 *
 * This plugin provides automated logging for the architect-agent hybrid logging protocol v2.0.
 * It implements three lifecycle hooks that mirror Claude Code's hook system:
 *
 * - onUserMessage → user-prompt-submit-hook
 * - onToolCalled → tool-call-hook
 * - onToolResult → tool-result-hook
 */

export default definePlugin({
  name: "architect-agent-logger",

  async onUserMessage({ message }) {
    const logFile = getActiveLogFile();
    if (!logFile) return;

    const timestamp = formatTimestamp();
    appendToLog(
      logFile,
      `[${timestamp}] 💬 USER MESSAGE: ${truncateMessage(message.text)}`
    );
  },

  async onToolCalled({ tool, params }) {
    const logFile = getActiveLogFile();
    if (!logFile) return;

    const timestamp = formatTimestamp();
    const paramStr = formatParams(params);

    appendToLog(
      logFile,
      `\n---\n[${timestamp}] TOOL: ${tool}\nPARAMS: ${paramStr}`
    );
  },

  async onToolResult({ tool, result, error }) {
    const logFile = getActiveLogFile();
    if (!logFile) return;

    const timestamp = formatTimestamp();

    if (error) {
      appendToLog(
        logFile,
        `[${timestamp}] RESULT: ❌ Failed\nERROR: ${error}\n---`
      );
    } else {
      const output = formatOutput(result);
      appendToLog(
        logFile,
        `[${timestamp}] RESULT: ✅ Success\nOUTPUT:\n${output}\n---`
      );
    }
  },
});

function getActiveLogFile(): string | null {
  const sessionFile = path.join(process.cwd(), "debugging/current_log_file.txt");
  if (!fs.existsSync(sessionFile)) return null;
  const logFilePath = fs.readFileSync(sessionFile, "utf8").trim();
  if (!logFilePath || logFilePath.length === 0) return null;
  return logFilePath;
}

function appendToLog(filePath: string, text: string): void {
  try {
    fs.appendFileSync(filePath, text + "\n", "utf8");
  } catch (error) {}
}

function formatTimestamp(): string {
  const now = new Date();
  const hours = String(now.getHours()).padStart(2, "0");
  const minutes = String(now.getMinutes()).padStart(2, "0");
  const seconds = String(now.getSeconds()).padStart(2, "0");
  return `${hours}:${minutes}:${seconds}`;
}

function formatParams(params: any): string {
  if (params === null || params === undefined) return "(none)";
  if (typeof params === "string") return truncateMessage(params);
  try {
    return JSON.stringify(params, null, 2);
  } catch {
    return String(params);
  }
}

function formatOutput(result: any): string {
  if (result === null || result === undefined) return "(no output)";
  const resultStr = typeof result === "string" ? result : JSON.stringify(result, null, 2);
  const MAX_OUTPUT_LENGTH = 5000;
  if (resultStr.length > MAX_OUTPUT_LENGTH) {
    return resultStr.substring(0, MAX_OUTPUT_LENGTH) + "\n... (output truncated)";
  }
  return resultStr;
}

function truncateMessage(message: string, maxLength: number = 200): string {
  if (message.length <= maxLength) return message;
  return message.substring(0, maxLength) + "...";
}
