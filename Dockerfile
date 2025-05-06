# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Install Docker
# RUN apt-get update && apt-get install -y docker.io

# Install trivy
RUN apt-get update && apt-get install -y curl \
    && curl -LO https://github.com/aquasecurity/trivy/releases/download/v0.58.2/trivy_0.58.2_Linux-64bit.deb \
    && dpkg -i trivy_0.58.2_Linux-64bit.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* trivy_0.58.2_Linux-64bit.deb

# Set the working directory to /cvst
WORKDIR /cvst

# Copy the app directory contents into the container at /cvst
COPY app/ .

# Make trivy_scan.sh executable
RUN chmod +x trivy_scan.sh

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 5705 available to the world outside this container
EXPOSE 5705

# Use Gunicorn to run the Flask app
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5705", "cvst:app"]