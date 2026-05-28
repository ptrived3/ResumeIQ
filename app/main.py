# main.py


import os
import uuid
import json
import boto3
from fastapi import FastAPI, UploadFile, File, HTTPException
from parser import extract_text
from analyzer import analyze_resume

app = FastAPI()

s3 = boto3.client('s3')
BUCKET = os.environ['S3_BUCKET_NAME']

@app.post("/analyze")
async def analyze(file: UploadFile = File(...)):
    if not file.filename.endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed.")
    
    job_id = str(uuid.uuid4())
    file_bytes = await file.read()

    # store original PDF in S3
    s3.put_object(Bucket=BUCKET, Key=f"resumes/{job_id}.pdf", Body=file_bytes)

    # extract text from PDF
    text = extract_text(file_bytes)
    results = analyze_resume(text)

    # store results in S3
    s3.put_object (
        Bucket=BUCKET, 
        Key=f"results/{job_id}.json", 
        Body=json.dumps(results),
        ContentType='application/json'
    )

    return {"job_id": job_id, "results": results}

@app.get("/results/{job_id}")
def get_results(job_id: str):
    try:
        obj = s3.get_object(Bucket=BUCKET, Key=f"results/{job_id}.json")
        return json.loads(obj['Body'].read())
    except Exception as e:
        raise HTTPException(status_code=404, detail="Results not found.")


from mangum import Mangum
handler = Mangum(app)
