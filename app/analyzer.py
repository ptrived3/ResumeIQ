import json
from openai import OpenAI

client = OpenAI()

def analyze_resume(text: str) -> dict:
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": "You are a technical recruiter. Analyze the resume and return JSON only with keys: skills (list), experience_gaps (list), suggestions (list), summary (string)."
            },
            {
                "role": "user",
                "content": f"Analyze this resume:\n\n{text}"
            }
        ],
        response_format={"type": "json_object"}
    )
    return json.loads(response.choices[0].message.content)