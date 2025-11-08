# Blue-Green Deployment Demo

This lab implements a minimal Node.js application packaged with Docker and orchestrated via a Jenkins pipeline to illustrate blue-green deployments with zero downtime.

## Project layout

- `src/server.js` – Express application exposing `/` and `/health` endpoints.
- `Dockerfile` – Builds a production-ready Node.js image.
- `docker-compose.bluegreen.yml` – Runs blue, green, and proxy services locally.
- `scripts/` – Helper scripts for building, pushing, deploying, and switching traffic.
- `Jenkinsfile` – Declarative pipeline automating CI/CD.
- `report/` – LaTeX lab report (compiled PDF will live here too).

## Prerequisites

- Node.js 18+ and npm
- Docker + Docker Compose v2
- Jenkins controller with Docker access
- A Docker Hub account + credentials stored in Jenkins as `dockerhub-creds`

## Local development

```bash
npm install
npm start
```

Visit http://localhost:3000 to see the running app.

## Container workflow

1. Build and push a tagged image:
   ```bash
   ./scripts/build-and-push.sh build-001
   ```
2. Deploy the image to the idle color:
   ```bash
   ./scripts/deploy-color.sh green dockerhub-user/bluegreen-demo:build-001 1.0.1
   ```
3. Run smoke tests (e.g., curl the `/health` endpoint on the green stack).
4. When satisfied, switch traffic through the proxy:
   ```bash
   ./scripts/switch-color.sh green
   ```
5. (Optional) Re-deploy the old color so both stacks run the new release.

`docker-compose.bluegreen.yml` exposes:
- Blue app on `localhost:3001`
- Green app on `localhost:3002`
- NGINX proxy on `localhost:8080`

Update `.env` with your Docker Hub handle and preferred tags before running the scripts.

## Jenkins pipeline summary

The declarative pipeline performs these steps:
1. Checkout + `npm ci`
2. Run placeholder tests
3. Build a Docker image tagged with either the supplied `IMAGE_TAG` parameter or `build-$BUILD_NUMBER`
4. Push image to Docker Hub using stored credentials
5. Call `scripts/deploy-color.sh` to update the idle environment
6. Hit a smoke-test URL
7. Optionally switch traffic to the new color

Trigger the job with parameters: `DEPLOY_COLOR`, `DOCKERHUB_REPO`, `IMAGE_TAG`, `SMOKE_TEST_URL`, `SWITCH_TRAFFIC`.
# bluegreen_deployment_assignment
