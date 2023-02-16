FROM quay.io/keycloak/keycloak:20.0.3 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

ARG keycloak_admin_password
ENV DOCKER_ENV_KEYCLOAK_ADMIN_PASSWORD=${keycloak_admin_password}

WORKDIR /opt/keycloak
# For demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass ${DOCKER_ENV_KEYCLOAK_ADMIN_PASSWORD} -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:20.0.3
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY realm-config/chorus-realm.json /opt/keycloak/data/import/chorus-realm.json

# Change these values to point to a running postgres instance
#  ENV KC_DB_URL=<DBURL>
#  ENV KC_DB_USERNAME=<DBUSERNAME>
#  ENV KC_DB_PASSWORD=<DBPASSWORD>

# Chorus settings
ENV KC_HOSTNAME=keycloak
ENV KC_HTTP_PORT=9080
ENV DB_VENDOR=h2
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=${DOCKER_ENV_KEYCLOAK_ADMIN_PASSWORD}

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]