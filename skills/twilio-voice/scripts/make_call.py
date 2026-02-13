#!/usr/bin/env python3
"""
Twilio Voice Calling Script for OpenClaw
Makes outbound phone calls using Twilio API
"""

import os
import sys
import json
from twilio.rest import Client
from twilio.twiml.voice_response import VoiceResponse

def make_call(to_number, message=None, from_number=None, account_sid=None, auth_token=None):
    """
    Make an outbound call using Twilio
    
    Args:
        to_number: The phone number to call (format: +1234567890)
        message: Optional text message to convert to speech (TTS)
        from_number: Your Twilio phone number (defaults to env/config)
        account_sid: Twilio Account SID (defaults to env/config)
        auth_token: Twilio Auth Token (defaults to env/config)
    
    Returns:
        dict with call SID and status
    """
    # Load from auth profiles if not provided
    if not account_sid or not auth_token:
        try:
            auth_path = os.path.expanduser("~/.openclaw/agents/main/agent/auth-profiles.json")
            with open(auth_path, 'r') as f:
                auth_data = json.load(f)
                twilio_config = auth_data.get('twilio', {})
                account_sid = account_sid or twilio_config.get('accountSid')
                auth_token = auth_token or twilio_config.get('authToken')
                from_number = from_number or twilio_config.get('fromNumber')
        except Exception as e:
            print(f"Error loading auth profiles: {e}", file=sys.stderr)
    
    # Validate credentials
    if not account_sid or not auth_token:
        return {"error": "Missing Twilio credentials. Please configure account_sid and auth_token."}
    
    if not from_number:
        return {"error": "Missing 'from' phone number. Please provide your Twilio number."}
    
    # Initialize Twilio client
    client = Client(account_sid, auth_token)
    
    # Create TwiML for the call
    twiml = VoiceResponse()
    if message:
        twiml.say(message)
    else:
        twiml.say("Hello, this is a call from OpenClaw.")
    
    try:
        # Make the call
        call = client.calls.create(
            twiml=str(twiml),
            to=to_number,
            from_=from_number
        )
        
        return {
            "success": True,
            "callSid": call.sid,
            "status": call.status,
            "to": to_number,
            "from": from_number,
            "message": message
        }
    except Exception as e:
        return {
            "error": str(e),
            "to": to_number,
            "from": from_number
        }

def check_call_status(call_sid, account_sid=None, auth_token=None):
    """
    Check the status of a call
    
    Args:
        call_sid: The call SID to check
        account_sid: Twilio Account SID
        auth_token: Twilio Auth Token
    
    Returns:
        dict with call status details
    """
    if not account_sid or not auth_token:
        try:
            auth_path = os.path.expanduser("~/.openclaw/agents/main/agent/auth-profiles.json")
            with open(auth_path, 'r') as f:
                auth_data = json.load(f)
                twilio_config = auth_data.get('twilio', {})
                account_sid = account_sid or twilio_config.get('accountSid')
                auth_token = auth_token or twilio_config.get('authToken')
        except Exception as e:
            return {"error": f"Error loading auth profiles: {e}"}
    
    client = Client(account_sid, auth_token)
    
    try:
        call = client.calls(call_sid).fetch()
        return {
            "callSid": call.sid,
            "status": call.status,
            "duration": call.duration,
            "price": call.price,
            "to": call.to,
            "from": call.from_
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Twilio Voice Calling")
    parser.add_argument("--to", required=True, help="Phone number to call (+1234567890)")
    parser.add_argument("--message", help="Message to speak during the call")
    parser.add_argument("--status", help="Check status of call with this SID")
    parser.add_argument("--from", dest="from_number", help="From phone number (optional)")
    
    args = parser.parse_args()
    
    if args.status:
        result = check_call_status(args.status)
        print(json.dumps(result, indent=2))
    else:
        result = make_call(
            to_number=args.to,
            message=args.message,
            from_number=args.from_number
        )
        print(json.dumps(result, indent=2))
