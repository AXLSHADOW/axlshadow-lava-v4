# axlshadow-lava-v4

## Lavalink v4 Music Server on Railway

A production-ready, containerized deployment template for **Lavalink v4** optimized for [Railway.com](https://railway.com/).

---

## 1. What is Lavalink?

[Lavalink](https://github.com/lavalink-devs/Lavalink) is a standalone, lightweight audio sending node based on Java and Lavaplayer. It handles audio extraction, decoding, DSP audio filtering, and real-time audio streaming over Discord voice connections.

By running Lavalink separately on Railway, your Discord bot (e.g. **Titan 3.0**, discord.js, discord.py) is completely decoupled from high CPU/memory audio processing, ensuring zero lag, instant track playback, and high availability.

---

## 2. Folder Structure

```text
lavalink-server/
├── application.yml        # Lavalink v4 configuration (sources, plugins, filters, port mapping)
├── Dockerfile             # Production container definition based on ghcr.io/lavalink-devs/lavalink:4
├── railway.json           # Railway deployment & health check configuration
├── .dockerignore          # Build context exclusion list
├── .gitignore             # Version control exclusion list (prevents committing secrets & binaries)
├── .env.example           # Reference environment variables template
├── download-lavalink.ps1  # Helper script to download Lavalink.jar on Windows for local testing
├── download-lavalink.sh   # Helper script to download Lavalink.jar on Linux/macOS
├── README.md              # Comprehensive operational documentation
└── plugins/               # Directory for Lavalink plugins (.gitkeep preserved)
```

---

## 3. Required Environment Variables

Configure these in the Railway dashboard under **Service Settings > Variables**:

| Variable | Description | Default / Example | Required |
| :--- | :--- | :--- | :--- |
| `PORT` | The network port the server listens on | Provided automatically by Railway | **Yes (Automatic)** |
| `LAVALINK_SERVER_PASSWORD` | Authentication password for bot connections | `CxvrJMvtQyQQnI0Mvn34iximK-f7RC5j` | **Yes** |
| `JAVA_TOOL_OPTIONS` | JVM heap & container tuning | `-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0` | Optional |

> [!IMPORTANT]
> Never hardcode `LAVALINK_SERVER_PASSWORD` directly into `application.yml` or git commits. The configuration automatically resolves `${LAVALINK_SERVER_PASSWORD:youshallnotpass}` from Railway's environment variables.

---

## 4. How to Deploy to Railway

### Option A: Railway Web Dashboard (Recommended)

1. **Push your code to GitHub**:
   Ensure the `lavalink-server` folder is committed to your repository.

2. **Create a Railway Project**:
   - Go to [Railway.com Dashboard](https://railway.com/dashboard).
   - Click **New Project** → **Deploy from GitHub repo**.
   - Select your repository.

3. **Set the Root Directory**:
   - In your newly created service, navigate to **Settings** → **Build & Deploy**.
   - Set **Root Directory** to `/lavalink-server` (or `lavalink-server`).
   - Railway will detect `railway.json` and use the `Dockerfile` automatically.

4. **Configure Environment Variables**:
   - Go to the **Variables** tab.
   - Click **Add Variable** and set:
     - Key: `LAVALINK_SERVER_PASSWORD`
     - Value: `CxvrJMvtQyQQnI0Mvn34iximK-f7RC5j` (or generate your own secure secret)
   - *(Note: Railway automatically injects the `PORT` variable)*.

5. **Generate a Public Domain**:
   - Navigate to the **Settings** tab → **Networking** section.
   - Under **Public Networking**, click **Generate Domain**.
   - You will receive a domain like:
     ```text
     lavalink-production-xxxx.up.railway.app
     ```

6. **Verify Deployment**:
   - Go to the **Deployments** tab and check the deployment logs.
   - Once the build finishes and the healthcheck (`/version`) returns HTTP 200, the status badge will turn green (**ACTIVE**).

---

### Option B: Railway CLI

If you have the Railway CLI installed and authenticated:

```bash
# 1. Navigate to the lavalink-server directory
cd lavalink-server

# 2. Link or create a Railway project
railway init
# or link existing:
# railway link

# 3. Set the Lavalink password
railway variables --set "LAVALINK_SERVER_PASSWORD=CxvrJMvtQyQQnI0Mvn34iximK-f7RC5j"

# 4. Deploy the service
railway up

# 5. Generate a public domain
railway domain
```

---

## 5. How to Obtain the Connection Details

Once deployed on Railway:

| Parameter | Value on Railway | Description |
| :--- | :--- | :--- |
| **Host** | `your-service-name.up.railway.app` | Public domain generated in Railway Settings |
| **Port** | `443` | Standard HTTPS/WSS port routed by Railway's reverse proxy |
| **Secure / SSL** | `true` | Railway provides automated TLS termination |
| **Password** | Your `LAVALINK_SERVER_PASSWORD` | Configured in Railway Variables |
| **WebSocket Path** | `wss://<your-domain>/v4/websocket` | Lavalink v4 real-time event & voice stream |
| **REST API Base** | `https://<your-domain>/v4` | Track search, load, sessions & player routing |
| **Healthcheck** | `https://<your-domain>/version` | Unauthenticated HTTP GET endpoint |

> [!NOTE]
> **Railway Port Routing Note**:
> Internally inside the container, Lavalink binds to `0.0.0.0:${PORT}` where `PORT` is assigned dynamically by Railway.
> Externally, Railway routes incoming HTTPS and WebSocket traffic on standard port **`443`** directly to your container. You do **not** need to open high numbered ports when using the generated Railway domain.

---

## 6. Connecting Your Discord Bot

### A. Titan 3.0 / Shoukaku (Node.js / TypeScript)

In your bot's `LavalinkConfig.ts` or environment configuration:

```typescript
// Example: Adding the Railway node to your Shoukaku cluster
const railwayNode = {
    name: "Railway-Lavalink",
    url: "lavalink-production-xxxx.up.railway.app:443",
    auth: process.env.LAVALINK_RAILWAY_AUTH || "CxvrJMvtQyQQnI0Mvn34iximK-f7RC5j",
    secure: true,
    enabled: true
};
```

Or via JSON override in `.env`:

```env
LAVALINK_NODES=[{"name":"Railway-Node","url":"lavalink-production-xxxx.up.railway.app:443","auth":"CxvrJMvtQyQQnI0Mvn34iximK-f7RC5j","secure":true,"enabled":true}]
```

### B. Python (Wavelink / Lavalink.py / Pomice)

```python
import wavelink

async def setup_lavalink():
    node: wavelink.Node = wavelink.Node(
        identifier="Railway-Node",
        uri="https://lavalink-production-xxxx.up.railway.app:443",
        password="CxvrJMvtQyQQnI0Mvn34iximK-f7RC5j",
        inactive_player_timeout=300
    )
    await wavelink.Pool.connect(nodes=[node], client=bot)
```

### C. Lavalink-Client (Discord.js v14)

```javascript
const { LavalinkManager } = require("lavalink-client");

const client = new LavalinkManager({
    nodes: [
        {
            authorization: "CxvrJMvtQyQQnI0Mvn34iximK-f7RC5j",
            host: "lavalink-production-xxxx.up.railway.app",
            port: 443,
            secure: true,
        }
    ],
    sendToShard: (guildId, payload) => bot.guilds.cache.get(guildId)?.shard?.send(payload),
    client: { id: bot.user.id, username: bot.user.username },
});
```

---

## 7. How to Update Lavalink

The Dockerfile uses the official tag `ghcr.io/lavalink-devs/lavalink:4`:
- To upgrade to newer patch releases of Lavalink v4, trigger a **Redeploy** in the Railway dashboard with **Clear Build Cache**. Railway will pull the latest `:4` base image from GitHub Container Registry.
- To pin to a specific release (e.g. `4.2.2`), edit `Dockerfile`:
  ```dockerfile
  FROM ghcr.io/lavalink-devs/lavalink:4.2.2
  ```

To update the YouTube plugin:
- Edit `application.yml` under `lavalink.plugins`:
  ```yaml
  lavalink:
    plugins:
      - dependency: "dev.lavalink.youtube:youtube-plugin:1.18.2"
  ```
- Commit and push to deploy.

---

## 8. Password Rotation

If your Lavalink password is compromised or needs scheduled rotation:

1. Open **Railway Dashboard** → Select the Lavalink service → **Variables**.
2. Update the `LAVALINK_SERVER_PASSWORD` value to your new secret.
3. Railway will automatically perform a zero-downtime rolling restart with the new password.
4. Update the password in your Discord bot's configuration/environment.
5. Restart your Discord bot to reconnect to the node.

---

## 9. Troubleshooting & Common Issues

### 1. `401 Unauthorized`
- Cause: The password configured in your bot does not match `LAVALINK_SERVER_PASSWORD` in Railway.
- Fix: Check Railway **Variables** tab for `LAVALINK_SERVER_PASSWORD`. Confirm your bot sends the exact string in the `Authorization` header.

### 2. `Connection Refused` or `Cannot reach host`
- Cause: Bot is trying to connect to port `2333` on the public Railway domain instead of `443`.
- Fix: When using `*.up.railway.app`, always set the port to `443` and `secure: true`. Port 2333 is internal to the container; Railway terminates SSL at the edge on 443.

### 3. Railway Health Check Fails
- Cause: Container takes longer than the default timeout or listens on the wrong port.
- Fix: `railway.json` is configured with `healthcheckPath: "/version"` and `healthcheckTimeout: 300`. This queries Lavalink's unauthenticated `/version` route and allows up to 5 minutes for plugin downloading on initial cold start.

### 4. YouTube "This track is not available" / Bot Detection
- Lavalink v4 uses the modular `dev.lavalink.youtube:youtube-plugin`.
- In `application.yml`, YouTube is configured with client fallbacks:
  ```yaml
  plugins:
    youtube:
      clients:
        - MUSIC
        - ANDROID
        - WEB
  ```
- If datacenter IPs are blocked by YouTube, configure YouTube OAuth in `application.yml` or provide a proxy.

### 5. Out Of Memory (OOMKilled)
- Cause: The container exceeded Railway's assigned RAM limit.
- Fix: The Dockerfile includes `-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0` to constrain Java heap to 75% of container RAM. For high traffic servers, increase RAM allocation in Railway service settings.

---

## 10. Monitoring & Health Endpoints

- **Health Check (Unauthenticated)**:
  ```bash
  curl -i https://<your-railway-domain>/version
  ```
  Returns: `4.x.x` (HTTP 200)

- **Node Info (Authenticated)**:
  ```bash
  curl -i -H "Authorization: <YOUR_PASSWORD>" https://<your-railway-domain>/v4/info
  ```
  Returns: Complete JSON object with Lavalink build, JVM version, audio plugins, and git commit details.
