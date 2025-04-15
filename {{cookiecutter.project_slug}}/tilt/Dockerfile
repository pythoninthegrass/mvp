FROM python:3-alpine

ARG flask_debug=False

ENV FLASK_DEBUG $flask_debug

WORKDIR /app

COPY requirements.txt .

RUN python -m pip install -r requirements.txt

COPY . .

ENTRYPOINT ["python", "/app/app.py"]
