# First, compile JS stuff
FROM node
WORKDIR /src/
COPY . .
RUN npm install -g requirejs uglify-js jade bower
RUN make init js

# Second, create virtualenv
FROM python:3-stretch
WORKDIR /src/
COPY --from=0 /src .
RUN apt-get -qqy update && apt-get -qqy install python3-dev sqlite3
RUN python3 -m venv /isso \
 && . /isso/bin/activate \
 && pip install gunicorn cffi \
 && python setup.py install

# Third, create final repository
FROM python:3.72-alpine3.8
RUN apk add inotify-tools
WORKDIR /isso/
RUN chmod +x boot.sh
COPY --from=1 /isso .

# Configuration
EXPOSE 8080
ENV ISSO_SETTINGS=/config/isso.cfg
CMD ["./boot.sh"]
