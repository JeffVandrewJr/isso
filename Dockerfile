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
FROM python:3.7.2-alpine3.8
RUN apk add inotify-tools
WORKDIR /isso/
COPY --from=1 /isso .
COPY ./boot.sh .
COPY ./isso.cfg /var/lib/config/isso.cfg
RUN chmod +x boot.sh

# Configuration
EXPOSE 8080
ENV ISSO_SETTINGS=/var/lib/config/isso.cfg
CMD ["./boot.sh"]
