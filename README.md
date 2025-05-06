<div align="center">
<img src="img/cvst.png" width="200">

[![License: MIT][license-img]][license]
![Docker Pulls][docker-pulls]
</div>

# CVST (Container Vulnerability Scan Tool)

"CVST is a scanning tool built on top of Trivy, leveraging its capabilities to enable seamless scanning of multiple container images in the browser. It generates CSV & HTML reports for thorough vulnerability analysis, ensuring robust security for containerized environments."

<div align="center">
  <img src="img/cvst.png" alt="cvst" width="800">
</div>

## Features

1. **Docker-based Application**: CVST is a Docker-based application that runs a user-friendly UI directly in your browser, ensuring effortless vulnerability assessment.

2. **Multiple Image Scanning**: Effortlessly scan multiple container images by submitting them through the intuitive interface and clicking the scan button, streamlining your vulnerability assessment process.

3. **Support for Public and Private Images**: Scan both public and private container images with ease, providing flexibility for various environments.

4. **Comprehensive Reports**: Generate comprehensive vulnerability reports in both HTML and CSV formats, empowering you to analyze and prioritize security risks effectively.

## Getting Started

1. **Pull CVST Docker Image**: 
`docker pull aomran102/cvst:latest`
&nbsp;
2. **Run CVST Container**: 
`docker run -d -p 5705:5705 aomran102/cvst:latest`
&nbsp;
3. **Enable Private Image Scanning (Optional)**:
- To scan private repo images, you need to provide your Docker registry details as environment variables. You can do this by creating a `docker-compose.yml` file with the following content:
    &nbsp;
    ``` yaml
    version: '3'
    services:
      cvst:
        image: aomran102/cvst:latest
        ports:
          - "5705:5705"
        environment:
          DOCKER_REGISTRY: ""
          DOCKER_USERNAME: ""
          DOCKER_PASSWORD: ""
        volumes:
          - "./reports:/app/reports"
    ```
- Replace the `DOCKER_REGISTRY`, `DOCKER_USERNAME`, and `DOCKER_PASSWORD` environment variables with your Docker registry details.
- Run `docker compose up -d` to start CVST with private image scanning support.

Open your browser and navigate to http://localhost:5705 to access CVST's user-friendly interface and start scanning container images.

## Support

If you encounter any issues with CVST or have questions about how to use it, please feel free to [open an issue](https://github.com/amromran102/cvst/issues) on GitHub. We'll do our best to help you out and address any concerns you may have.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


[license]: https://github.com/amromran102/cvst/blob/main/LICENSE
[license-img]: https://img.shields.io/badge/License-MIT-yellow.svg
[docker-pulls]: https://img.shields.io/docker/pulls/aomran102/cvst?logo=docker&label=docker%20pulls%20%2F%20cvst