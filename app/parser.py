import pypdf
import io

def extract_text(file_bytes: bytes) -> str:
    reader = pypdf.PdfReader(io.BytesIO(file_bytes))
    text = ""
    for page in reader.pages:
        text += page.extract_text()
    return text.strip()

# import fitz
# import os

# def extract_text(file_bytes: bytes) -> str:
#     doc = fitz.open(stream=file_bytes, filetype="pdf")
#     text = ""
#     for page in doc:
#         text += page.get_text()
#     return text.strip()