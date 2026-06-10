#!/usr/bin/env node
const { execSync } = require("child_process");
const path = require("path");

// ANSI color helpers
const c = {
  reset: "\x1b[0m",
  bold: "\x1b[1m",
  dim: "\x1b[2m",
  white: "\x1b[97m",
  gray: "\x1b[90m",
  cyan: "\x1b[96m",
  green: "\x1b[92m",
  yellow: "\x1b[93m",
  orange: "\x1b[33m",
  red: "\x1b[91m",
  magenta: "\x1b[95m",
  blue: "\x1b[94m",
  bgBlack: "\x1b[40m",
};

function colorForPct(pct) {
  if (pct < 50) return c.green;
  if (pct < 75) return c.yellow;
  if (pct < 90) return c.orange;
  return c.red;
}

function miniBar(pct, width = 8) {
  const filled = Math.round((pct * width) / 100);
  const color = colorForPct(pct);
  return (
    color + "▰".repeat(filled) + c.gray + "▱".repeat(width - filled) + c.reset
  );
}

function pctLabel(pct) {
  const color = colorForPct(pct);
  const padded = String(pct).padStart(3, " ");
  return `${color}${c.bold}${padded}%${c.reset}`;
}

function formatCountdown(resetsAt) {
  if (!resetsAt) return null;
  const nowSec = Math.floor(Date.now() / 1000);
  const diffSec = resetsAt - nowSec;
  if (diffSec <= 0) return `${c.green}now${c.reset}`;

  const d = Math.floor(diffSec / 86400);
  const h = Math.floor((diffSec % 86400) / 3600);
  const m = Math.floor((diffSec % 3600) / 60);

  if (d > 0) return `${c.dim}↺${c.reset} ${c.gray}${d}d${h}h${c.reset}`;
  if (h > 0) return `${c.dim}↺${c.reset} ${c.gray}${h}h${m}m${c.reset}`;
  return `${c.dim}↺${c.reset} ${c.yellow}${m}m${c.reset}`;
}

function getRepoLink() {
  try {
    let remote = execSync("git remote get-url origin", {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "ignore"],
    }).trim();

    if (!remote) return null;

    const url = remote
      .replace(/^git@github\.com:/, "https://github.com/")
      .replace(/\.git$/, "");

    const repoName = path.basename(url);
    return `\x1b]8;;${url}\x07${c.cyan}${repoName}${c.reset}\x1b]8;;\x07`;
  } catch {
    return null;
  }
}

let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  const data = JSON.parse(input);

  const model = data.model?.display_name ?? "Claude";
  const rate_limits = data.rate_limits || {};

  const ctx_pct = Math.floor(data.context_window?.used_percentage || 0);
  const session_pct = Math.floor(rate_limits.five_hour?.used_percentage || 0);
  const week_pct = Math.floor(rate_limits.seven_day?.used_percentage || 0);

  const session_reset = formatCountdown(rate_limits.five_hour?.resets_at);
  const week_reset = formatCountdown(rate_limits.seven_day?.resets_at);

  const remoteLink = getRepoLink();

  // ── Separators ──────────────────────────────────────────────────────────────
  const sep = `${c.gray} │ ${c.reset}`;

  // ── Model badge ─────────────────────────────────────────────────────────────
  const modelBadge = `${c.bold}${c.magenta}◆${c.reset} ${c.bold}${model}${c.reset}`;

  // ── Context window ──────────────────────────────────────────────────────────
  const ctxSegment =
    `${c.dim}Context${c.reset} ` + miniBar(ctx_pct) + ` ${pctLabel(ctx_pct)}`;

  // ── 5-hour session ──────────────────────────────────────────────────────────
  const sessionSegment =
    `${c.dim}5h${c.reset}  ` +
    miniBar(session_pct) +
    ` ${pctLabel(session_pct)}` +
    (session_reset ? `  ${session_reset}` : "");

  // ── 7-day week ──────────────────────────────────────────────────────────────
  const weekSegment =
    `${c.dim}7d${c.reset}  ` +
    miniBar(week_pct) +
    ` ${pctLabel(week_pct)}` +
    (week_reset ? `  ${week_reset}` : "");

  // ── Repo link ───────────────────────────────────────────────────────────────
  const repoSegment = remoteLink ? `${c.gray}⎇${c.reset}  ${remoteLink}` : null;

  // ── Assemble ────────────────────────────────────────────────────────────────
  const parts = [modelBadge, ctxSegment, sessionSegment, weekSegment];
  if (repoSegment) parts.push(repoSegment);

  console.log(parts.join(sep));
});
