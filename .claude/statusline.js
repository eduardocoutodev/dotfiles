#!/usr/bin/env node
const { execSync } = require("child_process");
const path = require("path");

function getRepoLink() {
  try {
    let remote = execSync("git remote get-url origin", {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "ignore"],
    }).trim();

    if (!remote) return null;

    remote
      .replace(/^git@github\.com:/, "https://github.com/")
      .replace(/\.git$/, "");

    const repoName = path.basename(remote);

    return `\x1b]8;;${remote}\x07${repoName}\x1b]8;;\x07`;
  } catch {
    return null;
  }
}

let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  const data = JSON.parse(input);
  const model = data.model.display_name;

  // Optional chaining (?.) safely handles null fields
  const pct = Math.floor(data.context_window?.used_percentage || 0);

  // String.repeat() builds the bar
  const filled = Math.floor((pct * 10) / 100);
  const bar = "▓".repeat(filled) + "░".repeat(10 - filled);

  const remoteLink = getRepoLink();
  const remoteDisplay = remoteLink ? `| 🔗 ${remoteLink}` : "";

  console.log(`[${model}] ${bar} ${pct}% ${remoteDisplay}`);
});
