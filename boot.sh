#!/bin/sh

/isso/bin/gunicorn -b 0.0.0.0:8080 -w 3 --preload isso.run --access-logfile=- --error-logfile=- &

if [ ! -e /var/lib/config/isso.cfg ]
then
    echo Create config.
    touch /var/lib/config/isso.cfg
fi

while true; do
    while inotifywait -q -e modify -e move_self /var/lib/config/isso.cfg >/dev/null; do
        echo "Isso Config Changed."
        pkill gunicorn
	/isso/bin/gunicorn -b 0.0.0.0:8080 -w 3 --preload isso.run --access-logfile=- --error-logfile=- &
    done
done
