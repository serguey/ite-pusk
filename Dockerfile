# syntax = docker/dockerfile:1.4
FROM bellsoft/liberica-runtime-container:jre-17-glibc AS base

FROM base AS java-api
ADD https://its.1c.ru/db/files/1CITS/EXE/java-api-8.3.11/java-api-8.3.11.zip /root
WORKDIR /root
RUN <<EOT
	mkdir -p tmp
	unzip -oj java*.zip -d tmp
	unzip -oj tmp/java*.zip -d ./
	unzip -oj com*.zip -d tmp
	mkdir -p lib
	cp tmp/*.jar ./lib/
EOT

FROM base AS ite-pusk 
ADD https://cloud.it-expertise.ru/s/ite-pusk-distr/download/ite-pusk-v1.0.tar.gz /root
WORKDIR /root
RUN tar xvzf ite-pusk-*.tar.gz -C /opt/

FROM base
COPY --from=ite-pusk /opt/pusk /opt/pusk/
COPY --from=java-api /root/lib /opt/pusk/lib/

LABEL maintainer="Sergey Kutovoy <ya.serguey@yandex.ru>"

WORKDIR /

COPY --chmod=777 <<'EOF' /entrypoint.sh
#!/bin/sh

if [ -z "${1}" ]; then

	if [ -f "/opt/pusk/data/application.properties" ]; then
		export APP_PROP=--spring.config.import=optional:/opt/pusk/data/application.properties
	else
		export APP_PROP=
	fi
	cd /opt/pusk/bin/
	exec java -cp ite-pusk.jar:/opt/pusk/lib/* \
		-Dloader.main=com.ite.utils.pusk.Application \
		org.springframework.boot.loader.PropertiesLauncher \
		"$APP_PROP" 

else
  exec "$@"
fi

EOF

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
EXPOSE 8080
LABEL version="1.3"
