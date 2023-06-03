FROM python:3.11-slim

WORKDIR /geoip

RUN pip install --no-cache-dir -U \
ipaddr==2.2.0

COPY /files/* ./

ENTRYPOINT ["./geolite2legacy.py"]
