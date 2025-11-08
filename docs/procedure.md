# Blue-Green Deployment Lab Procedure

## 1. Requirements gathering
- Read lab brief: containerize Node.js app, publish to Docker Hub, orchestrate blue-green deployment with Jenkins.
- Decide on tooling: Node.js + Express, Docker Compose, Jenkins declarative pipeline.

## 2. Build the Node.js service
1. Initialize project with `npm init -y` and install Express.
2. Implement `src/server.js` exposing `/` and `/health` and rendering color/version information from environment variables.
3. Verify locally via `npm start` and `curl http://localhost:3000`.

## 3. Containerize the app
1. Create `Dockerfile` based on `node:20-alpine`.
2. Add `.dockerignore` to reduce build context.
3. Build locally: `docker build -t bluegreen-demo:dev .` and run `docker run -p 3000:3000 bluegreen-demo:dev`.

## 4. Compose blue/green stacks
1. Define `.env` with Docker Hub repo + default tags for blue and green.
2. Create `docker-compose.bluegreen.yml` with three services:
   - `blue` and `green` containers sharing the same image but different env vars.
   - `proxy` (NGINX) that routes to `$ACTIVE_COLOR` using a templated config.
3. Start everything: `docker compose -f docker-compose.bluegreen.yml up -d --build`.
4. Hit ports `3001`, `3002`, and `8080` to confirm routing.

## 5. Operational scripts
- `scripts/build-and-push.sh <tag>`: builds/pushes Docker image to `${DOCKERHUB_USERNAME}/${APP_NAME}:<tag>`.
- `scripts/deploy-color.sh <color> <image> <version>`: updates `.env`, redeploys target color, and records semantic version.
- `scripts/switch-color.sh <color>`: rewrites `.env` `ACTIVE_COLOR` and hot-reloads proxy.

## 6. Jenkins pipeline
1. Create credentials entry `dockerhub-creds`.
2. Create a Pipeline job pointing at this repository.
3. Add parameters: `DEPLOY_COLOR`, `DOCKERHUB_REPO`, `IMAGE_TAG`, `SMOKE_TEST_URL`, `SWITCH_TRAFFIC`.
4. Run the pipeline. It performs checkout → npm ci → tests → docker build → docker push → deploy idle color → smoke test → optional switch.

## 7. Verification & screenshots
- Capture Docker Hub repo showing pushed image.
- Take terminal screenshot showing `docker compose ps` with blue/green containers.
- Capture Jenkins pipeline success view.
- Place PNG files under `report/images/` and update filenames in `report/main.tex` if changed.

## 8. Deliverables
- Working source tree (this repo).
- PDF export of LaTeX report under `report/bluegreen-lab-report.pdf`.
- Screenshots supporting build/deploy/switch evidence.
