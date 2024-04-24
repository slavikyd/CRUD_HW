FROM python:3.11.4

WORKDIR /crudhw

COPY /. .
COPY app.py .
COPY dbquery.py .
COPY extras.py .
COPY http_code.py .
COPY creds.py .

COPY /requirements.txt .

RUN pip install -r requirements.txt
CMD ["gunicorn", "--preload"]