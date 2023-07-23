# [ITE-PUSK docker image](https://github.com/serguey/ite-pusk)

Docker image to run [ite-pusk](https://it-expertise.ru/pusk/) with [Liberica java image from Bellsoft](https://hub.docker.com/r/bellsoft/liberica-runtime-container)

to run
```
docker run -p 8080:8080 -v /data:/opt/pusk/data -v /log:/opt/pusk/log
```
