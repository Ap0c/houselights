FROM python:alpine

WORKDIR /code

ADD ./requirements.txt .
RUN pip install -r requirements.txt

ENV FLASK_APP main.py

CMD ["flask", "run", "--host", "0.0.0.0"]
