# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Add build argument for Trivy version
ARG TRIVY_VERSION=v0.58.2

# Install trivy with dynamic version
RUN apt-get update && apt-get install -y curl \
    && curl -LO "https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-64bit.deb" \
    && dpkg -i "trivy_${TRIVY_VERSION#v}_Linux-64bit.deb" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* "trivy_${TRIVY_VERSION#v}_Linux-64bit.deb"

# Set the working directory to /cvst
WORKDIR /cvst

# Copy the app directory contents into the container at /cvst
COPY app/ .

# Make trivy_scan.sh executable
RUN chmod +x trivy_scan.sh

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Expose port 5705 for the application
EXPOSE 5705

# Run CVST when the container launches
CMD ["python", "cvst.py"]