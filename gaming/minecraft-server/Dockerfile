# Use an official Java runtime as a parent image
FROM openjdk:21-ubuntu

# Set the working directory
WORKDIR /usr/src/minecraft

# Copy the server jar into the container
COPY paper-1.21.4.jar /usr/src/minecraft/

# Expose the Minecraft default port
EXPOSE 25565

# Set the entry point to run the Minecraft server
CMD ["java", "-Xmx2G", "-Xms1G", "-jar", "paper-1.19.3-123.jar", "nogui"]
