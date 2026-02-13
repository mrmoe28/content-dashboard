---
name: twilio-voice
description: Make outbound phone calls using Twilio API. Use when the user wants to (1) Make a phone call to someone, (2) Send a voice message or TTS (text-to-speech) call, (3) Check call status, or (4) Any voice calling needs. Automatically loads Twilio credentials from auth profiles.
---

# Twilio Voice Calling

This skill enables making outbound phone calls using Twilio's voice API.

## Quick Start

Make a call:
```bash
python scripts/make_call.py --to "+1234567890" --message "Hello, this is OpenClaw calling"
```

Check call status:
```bash
python scripts/make_call.py --to "+1234567890" --status "CAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## Requirements

- Twilio account with valid credentials
- From phone number configured in Twilio
- Recipient phone number in E.164 format (+1234567890)

## Credentials

Credentials are automatically loaded from `auth-profiles.json`:
- `twilio.accountSid` - Your Twilio Account SID
- `twilio.authToken` - Your Twilio Auth Token  
- `twilio.fromNumber` - Your Twilio phone number

Or pass them as environment variables:
- `TWILIO_ACCOUNT_SID`
- `TWILIO_AUTH_TOKEN`
- `TWILIO_PHONE_NUMBER`

## Usage Patterns

### Simple Voice Call with Message

Uses text-to-speech to speak a message:

```python
from scripts.make_call import make_call

result = make_call(
    to_number="+1234567890",
    message="Hello, calling to confirm our meeting tomorrow at 3 PM."
)
print(result["callSid"])  # Save this to check status later
```

### Check Call Status

```python
from scripts.make_call import check_call_status

status = check_call_status("CAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
print(f"Call status: {status['status']}")
print(f"Duration: {status['duration']} seconds")
```

## Output Format

All functions return JSON-serializable dicts:

**Success:**
```json
{
  "success": true,
  "callSid": "CAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "status": "queued",
  "to": "+1234567890",
  "from": "+18778792960",
  "message": "Hello from OpenClaw"
}
```

**Error:**
```json
{
  "error": "Invalid phone number format",
  "to": "invalid-number"
}
```

## Important Notes

- Calls cost approximately $0.013-$0.025 per minute depending on destination
- Calls are placed immediately when the script runs
- The message is converted to speech using Twilio's default TTS voice
- Call records are available in your Twilio console for tracking
