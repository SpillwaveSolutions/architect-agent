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
 *
 * The plugin logs to the active log file specified in debugging/current_log_file.txt,
 * maintaining the same format and behavior as Claude Code hooks.
 */

export default definePlugin({
  name: "architect-agent-logger",

  /**
   * Log user messages when submitted
   * Equivalent to Claude Code's user-prompt-submit-hook
   */
  async onUserMessage({ message }) {
    const logFile = getActiveLogFile();
    if (!logFile) return;

    const timestamp = formatTimestamp();
    appendToLog(
      logFile,
      `[${timestamp}] 💬 USER MESSAGE: ${truncateMessage(message.text)}`
    );
  },

  /**
   * Log tool calls before execution
   * Equivalent to Claude Code's tool-call-hook
   */
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

  /**
   * Log tool results after execution
   * Equivalent to Claude Code's tool-result-hook
   */
  async onToolResult({ tool, result, error }) {
    const logFile = getActiveLogFile();
    if (!logFile) return;

    const timestamp = formatTimestamp();

    if (error) {
      // Tool execution failed
      appendToLog(
        logFile,
        `[${timestamp}] RESULT: ❌ Failed\nERROR: ${error}\n---`
      );
    } else {
      // Tool execution succeeded
      const output = formatOutput(result);
      appendToLog(
        logFile,
        `[${timestamp}] RESULT: ✅ Success\nOUTPUT:\n${output}\n---`
      );
    }
  },
});

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Get the active log file path from debugging/current_log_file.txt
 * Returns null if no active log session
 */
function getActiveLogFile(): string | null {
  const sessionFile = path.join(process.cwd(), "debugging/current_log_file.txt");

  // Check if session file exists
  if (!fs.existsSync(sessionFile)) {
    return null;
  }

  // Read the log file path
  const logFilePath = fs.readFileSync(sessionFile, "utf8").trim();

  // Return null if empty or invalid
  if (!logFilePath || logFilePath.length === 0) {
    return null;
  }

  return logFilePath;
}

/**
 * Append text to log file
 * Fails silently if file cannot be written
 */
function appendToLog(filePath: string, text: string): void {
  try {
    fs.appendFileSync(filePath, text + "\n", "utf8");
  } catch (error) {
    // Fail silently - matches Claude Code hook behavior (|| true)
    // This prevents blocking execution if logging fails
  }
}

/**
 * Format timestamp in HH:MM:SS format
 * Matches Claude Code hooks format: $(date +%H:%M:%S)
 */
function formatTimestamp(): string {
  const now = new Date();
  const hours = String(now.getHours()).padStart(2, "0");
  const minutes = String(now.getMinutes()).padStart(2, "0");
  const seconds = String(now.getSeconds()).padStart(2, "0");
  return `${hours}:${minutes}:${seconds}`;
}

/**
 * Format tool parameters for logging
 * Handles objects, arrays, and primitive values
 */
function formatParams(params: any): string {
  if (params === null || params === undefined) {
    return "(none)";
  }

  if (typeof params === "string") {
    return truncateMessage(params);
  }

  try {
    // Pretty-print JSON with 2-space indentation
    return JSON.stringify(params, null, 2);
  } catch {
    // Fallback if params can't be stringified
    return String(params);
  }
}

/**
 * Format tool output/result for logging
 * Truncates very long outputs to keep logs readable
 */
function formatOutput(result: any): string {
  if (result === null || result === undefined) {
    return "(no output)";
  }

  const resultStr = typeof result === "string"
    ? result
    : JSON.stringify(result, null, 2);

  // Truncate extremely long outputs (>5000 chars)
  const MAX_OUTPUT_LENGTH = 5000;
  if (resultStr.length > MAX_OUTPUT_LENGTH) {
    return resultStr.substring(0, MAX_OUTPUT_LENGTH) + "\n... (output truncated)";
  }

  return resultStr;
}

/**
 * Truncate long messages to keep logs readable
 */
function truncateMessage(message: string, maxLength: number = 200): string {
  if (message.length <= maxLength) {
    return message;
  }
  return message.substring(0, maxLength) + "...";
}
