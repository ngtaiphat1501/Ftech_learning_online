# ==========================================
# STAGE 1: Build the WAR file using Maven
# ==========================================
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app

# Copy pom.xml and source code
COPY pom.xml .
COPY src ./src

# Build WAR artifact
RUN mvn clean package -DskipTests

# ==========================================
# STAGE 2: Run with Apache Tomcat 10.1
# ==========================================
FROM tomcat:10.1-jdk21-temurin
WORKDIR /usr/local/tomcat

# Clean default webapps
RUN rm -rf webapps/*

# Deploy application as GroupASM.war and ROOT.war
COPY --from=builder /app/target/GroupASM-1.0-SNAPSHOT.war webapps/GroupASM.war
COPY --from=builder /app/target/GroupASM-1.0-SNAPSHOT.war webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
