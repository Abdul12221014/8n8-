# Personalized AI Language Tutor (n8n)

A minimal, production-ready n8n setup with two workflows:
- Workflow 1: Onboarding (POST /onboard) → saves user preferences to Airtable.
- Workflow 2: Conversational Tutor (POST /tutor) → uses preferences + last 10 messages, returns AI reply and MP3 audio.

## Repository Structure
```
workflows/
  onboarding.json   # Webhook /onboard → Airtable upsert to Users
  tutor.json        # Webhook /tutor → history, OpenAI(JSON), Airtable, Google TTS → MP3
```

## Airtable Schema
Create base: `Personalized Tutor`
- Table `Users`
  - user_id (Primary, Single line text)
  - native_language (Single line text)
  - target_language (Single line text)
  - topic (Single line text)
  - ai_mood (Single line text)
  - created_at (Created time)
  - updated_at (Last modified time)
- Table `Messages`
  - user_id (Single line text)
  - role (Single select: user, assistant)
  - content (Long text)
  - timestamp (Created time)

## Credentials Needed in n8n
- Airtable: Personal Access Token
- OpenAI: API Key
- Google Cloud Text-to-Speech: Service Account JSON

## Import & Configure
1) In n8n, import both workflows from `workflows/onboarding.json` and `workflows/tutor.json`.
2) Open each Airtable node and select your Airtable credential; choose your base (replaces `BASE_ID_HERE`) and table by name (`Users`, `Messages`).
3) Open the OpenAI node and select your OpenAI credential; model is `gpt-4o-mini` and response format is JSON Object.
4) Open the Google Text-to-Speech node and select your Google credential; output is binary MP3.
5) Activate both workflows.

## Endpoints
- POST `http://localhost:5678/webhook/onboard`
- POST `http://localhost:5678/webhook/tutor`

## Deploy to Render (Permanent URL)
1) Create a new Web Service on Render from this repo.
2) Choose Deploy from Docker, Render will auto-detect `Dockerfile`.
3) After first deploy, set environment variables:
   - `N8N_PORT` = `$PORT`
   - `N8N_PROTOCOL` = `https`
   - `N8N_HOST` = your Render service hostname (auto-filled if using `render.yaml`)
   - `WEBHOOK_URL` = your Render service URL (auto-filled if using `render.yaml`)
4) Redeploy. Your permanent URLs will be:
   - POST `https://<your-service>.onrender.com/webhook/onboard`
   - POST `https://<your-service>.onrender.com/webhook/tutor`

## Test Commands
Onboarding:
```bash
curl -X POST "http://localhost:5678/webhook/onboard" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"u123","native_language":"Turkish","target_language":"English","topic":"Travel","ai_mood":"Encouraging"}'
```

Tutor:
```bash
curl -X POST "http://localhost:5678/webhook/tutor" \
  -H "Content-Type: application/json" \
  --output reply.mp3 \
  -d '{"user_id":"u123","message":"How do I ask for directions politely?"}'
```

You should receive an MP3. `file reply.mp3` should show `audio/mpeg` and the file should play.

## Notes
- The OpenAI node enforces JSON-only responses via Response Format = JSON Object. If your n8n version lacks this, replace the OpenAI node with an HTTP Request to `https://api.openai.com/v1/chat/completions` and include `"response_format": { "type": "json_object" }`.
- History retrieval is limited to last 10 messages ordered oldest → newest.
