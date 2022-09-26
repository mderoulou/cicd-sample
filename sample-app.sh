#!/bin/bash
set -euo pipefail

rm -rf tempdir
mkdir tempdir
mkdir tempdir/templates
mkdir tempdir/static

cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.

cat > tempdir/Dockerfile << _EOF_
FROM python
RUN pip install flask
COPY  ./static /home/myapp/static/
COPY  ./templates /home/myapp/templates/
COPY  sample_app.py /home/myapp/
EXPOSE 5050
CMD python /home/myapp/sample_app.py
_EOF_

cd tempdir || exit
if [ -n $(docker images | grep samplerunning) ];
then
    echo "Stopping old container..."
    docker stop samplerunning || true
    docker rm samplerunning || true
    echo "Stopped"
fi
if [ -n $(docker ps -a | grep sampleapp) ];
then
    echo "Removing old image..."
    docker rmi sampleapp || true
    echo "Removed"
fi
docker build -t sampleapp .
docker run -t -d -p 5050:5050 --name samplerunning sampleapp
docker ps -a 
