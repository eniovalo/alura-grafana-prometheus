#!/bin/bash

# Rodando via jar.
java -jar -Xms128M -Xmx128M -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=128m -Dspring.profiles.active=prod target/forum.jar

# Rodando direto.
# export SPRING_PROFILES_ACTIVE=prod
# ./mvnw spring-boot:run