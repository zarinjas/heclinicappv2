module.exports = {
  apps: [
    {
      name: "heclinic-bot",
      script: "node",
      args: "--import tsx server.ts",
      cwd: "/var/www/heclinic-bot",
      env: {
        NODE_ENV: "production",
        PORT: "3000",
        TELEGRAM_BOT_TOKEN: process.env.TELEGRAM_BOT_TOKEN,
        GH_PAT: process.env.GH_PAT,
        GH_OWNER: process.env.GH_OWNER,
        GH_REPO: process.env.GH_REPO,
        GH_WORKFLOW_ID: "agent-director.yml",
        TELEGRAM_CHAT_ID: process.env.TELEGRAM_CHAT_ID,
      },
      autorestart: true,
      max_restarts: 10,
      restart_delay: 5000,
      log_date_format: "YYYY-MM-DD HH:mm:ss Z",
      error_file: "/var/log/heclinic-bot-error.log",
      out_file: "/var/log/heclinic-bot-out.log",
    },
  ],
};
