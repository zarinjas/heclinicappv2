import { Bot, webhookCallback } from "grammy";
import express from "express";
import { Octokit } from "@octokit/rest";
import { readFileSync, writeFileSync, existsSync } from "fs";

const BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN!;
const GH_PAT = process.env.GH_PAT!;
const GH_OWNER = process.env.GH_OWNER!;
const GH_REPO = process.env.GH_REPO!;
const GH_WORKFLOW_ID = process.env.GH_WORKFLOW_ID || "agent-director.yml";
const CHAT_ID = process.env.TELEGRAM_CHAT_ID!;
const PORT = parseInt(process.env.PORT || "3000");

if (!BOT_TOKEN || !GH_PAT || !GH_OWNER || !GH_REPO || !CHAT_ID) {
  console.error("Missing required environment variables.");
  console.error("Required: TELEGRAM_BOT_TOKEN, GH_PAT, GH_OWNER, GH_REPO, TELEGRAM_CHAT_ID");
  process.exit(1);
}

const bot = new Bot(BOT_TOKEN);
const app = express();
const octokit = new Octokit({ auth: GH_PAT });

interface ApprovalRequest {
  task_id: string;
  title: string;
  qa_result: string;
  reviewer_decision: string;
}

let pendingApproval: ApprovalRequest | null = null;

app.use(express.json());

// --- Director API ---

app.post("/bot/request-approval", async (req, res) => {
  const { task_id, title, qa_result, reviewer_decision } = req.body;

  if (!task_id || !title) {
    res.status(400).json({ error: "task_id and title are required" });
    return;
  }

  pendingApproval = { task_id, title, qa_result, reviewer_decision };

  const message = [
    `🤖 <b>Task Selesai — Perlukan Approval</b>`,
    ``,
    `<b>Task:</b> ${task_id}`,
    `<b>Tajuk:</b> ${title}`,
    `<b>QA:</b> ${qa_result || "N/A"}`,
    `<b>Reviewer:</b> ${reviewer_decision || "N/A"}`,
    ``,
    `Sila pilih:`,
  ].join("\n");

  try {
    await bot.api.sendMessage(CHAT_ID, message, {
      parse_mode: "HTML",
      reply_markup: {
        inline_keyboard: [
          [
            { text: "✅ Approve", callback_data: `approve_${task_id}` },
            { text: "❌ Reject", callback_data: `reject_${task_id}` },
          ],
        ],
      },
    });
    console.log(`Approval request sent for ${task_id}`);
    res.json({ ok: true, message: "Approval request sent to Telegram" });
  } catch (err) {
    console.error("Failed to send Telegram message:", err);
    res.status(500).json({ error: "Failed to send Telegram message" });
  }
});

app.get("/bot/health", (_req, res) => {
  res.json({ ok: true, pending: pendingApproval?.task_id || null });
});

// --- Telegram Webhook ---

bot.callbackQuery(/^(approve|reject)_(.+)$/, async (ctx) => {
  const action = ctx.match[1];
  const taskId = ctx.match[2];

  if (!pendingApproval || pendingApproval.task_id !== taskId) {
    await ctx.answerCallbackQuery({ text: "Tiada pending approval untuk task ini." });
    return;
  }

  if (action === "approve") {
    await ctx.answerCallbackQuery({ text: "Approved! Trigger workflow..." });
    await ctx.editMessageText(
      `✅ <b>Approved:</b> ${taskId} — ${pendingApproval.title}`,
      { parse_mode: "HTML" }
    );

    try {
      await octokit.actions.createWorkflowDispatch({
        owner: GH_OWNER,
        repo: GH_REPO,
        workflow_id: GH_WORKFLOW_ID,
        ref: "develop",
        inputs: {
          action: "approve",
        },
      });
      console.log(`Workflow dispatched for approval of ${taskId}`);
    } catch (err) {
      console.error("Failed to dispatch workflow:", err);
      await ctx.reply("⚠️ Gagal trigger workflow. Sila check log.");
    }

    pendingApproval = null;
  } else if (action === "reject") {
    await ctx.answerCallbackQuery({ text: "Rejected. Kembali ke in-progress..." });
    await ctx.editMessageText(
      `❌ <b>Rejected:</b> ${taskId} — ${pendingApproval.title}`,
      { parse_mode: "HTML" }
    );

    try {
      await octokit.actions.createWorkflowDispatch({
        owner: GH_OWNER,
        repo: GH_REPO,
        workflow_id: GH_WORKFLOW_ID,
        ref: "develop",
        inputs: {
          action: "reject",
        },
      });
      console.log(`Workflow dispatched for rejection of ${taskId}`);
    } catch (err) {
      console.error("Failed to dispatch workflow:", err);
      await ctx.reply("⚠️ Gagal trigger workflow. Sila check log.");
    }

    pendingApproval = null;
  }
});

bot.command("status", async (ctx) => {
  if (pendingApproval) {
    await ctx.reply(
      `⏳ Pending: ${pendingApproval.task_id} — ${pendingApproval.title}`,
      { parse_mode: "HTML" }
    );
  } else {
    await ctx.reply("Tiada pending approval. Semua clear.");
  }
});

bot.command("start", async (ctx) => {
  await ctx.reply(
    "🤖 <b>He Clinic Agentic AI Bot</b>\n\n" +
      "Bot ini akan hantar approval request bila AI Director siapkan task.\n" +
      "Guna /status untuk check pending approval.",
    { parse_mode: "HTML" }
  );
});

// --- Start ---

app.use(webhookCallback(bot, "express"));

app.listen(PORT, () => {
  console.log(`He Clinic Bot running on port ${PORT}`);
  console.log(`Webhook: /bot/webhook (must be registered with Telegram)`);
  console.log(`Health: /bot/health`);
  console.log(`Approval API: POST /bot/request-approval`);
});
