from flask import Flask, render_template, request, send_file
from subprocess import run, PIPE
import os
import re
from werkzeug.middleware.proxy_fix import ProxyFix

app = Flask(__name__)

app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)


@app.route("/", methods=["GET", "POST"])
# /cvst/ for reverse proxy prefix
@app.route("/cvst/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        images_input = request.form.get("images")
        if images_input:
            # Disable the scan button during processing
            disable_button = True

            # Split the input string into a list of images
            images_list = [image.strip() for image in re.split(r'\s+|\n+', images_input) if image.strip()]

            # Pass the images list and the dynamically generated CSV file name as environment variables to the shell script
            command = ["./trivy_scan.sh"]
            
            # Set the CSV_RESULT_FILE directly in the env dictionary ## NOT USED
            env = {"IMAGES": " ".join(images_list)}

            # Check if Docker registry credentials are provided from ENV variables and set the DOCKER_CONFIG environment variable
            docker_registry = os.environ.get("DOCKER_REGISTRY")
            docker_username = os.environ.get("DOCKER_USERNAME")
            docker_password = os.environ.get("DOCKER_PASSWORD")

            if docker_registry and docker_username and docker_password:
                # Create a temporary Docker configuration directory
                docker_config_dir = "docker_config"
                os.makedirs(docker_config_dir, exist_ok=True)

                # Create the Docker configuration file
                docker_config_file = os.path.join(docker_config_dir, "config.json")
                with open(docker_config_file, "w") as config_file:
                    config_file.write('{"auths": {"' + docker_registry + '": {"username":"' + docker_username + '","password":"' + docker_password + '"}}}')

                # Set the Docker configuration directory as an environment variable
                env["DOCKER_CONFIG"] = docker_config_dir

            # Create a 'logs' directory if it doesn't exist
            logs_dir = "logs"
            os.makedirs(logs_dir, exist_ok=True)

            # Run the command and capture the output, output to stdout from shell script is captured in the result.stdout. "$csv_output_file" and "$html_output_file" are the variables in the shell script
            result = run(command, env=env, stdout=PIPE, stderr=PIPE, text=True)            

            # Save the output to a file in the 'logs' directory for debugging the echo output in the shell script
            output_file_path = os.path.join(logs_dir, "script_output.txt")
            with open(output_file_path, "w") as output_file:
                output_file.write(result.stdout)            

            ## This section determines how Flask extracts the report file names and assigns them to the respective download and view paths
            # Use regular expressions to extract the desired filename patterns
            match_csv = re.search(r'cvst_report-.*\.csv', result.stdout)
            match_html = re.search(r'cvst_report-.*\.html', result.stdout)               

            # Check if a match is found for CSV
            if match_csv:
                csv_result_file = match_csv.group()
                
                # Return CSV file for download with the extracted filename
                csv_download_path = f"/reports/download/{csv_result_file}"
            else:
                csv_download_path = None

            # Check if a match is found for HTML
            if match_html:
                html_result_file = match_html.group()
                
                # Return HTML file for view with the extracted filename
                html_view_path = f"/reports/view/{html_result_file}"
            else:
                html_view_path = None

            return render_template("index.html", disable_button=disable_button, csv_download_path=csv_download_path, html_view_path=html_view_path)

    return render_template("index.html", disable_button=False, csv_download_path=None, html_view_path=None)

@app.route("/reports/view/<filename>", methods=["GET"])
def view_scan_results(filename):
    file_path = os.path.join("reports", filename)
    # You might want to render the HTML file here or return it as needed
    return send_file(file_path)

@app.route("/reports/download/<filename>", methods=["GET"])
def download_scan_results(filename):
    file_path = os.path.join("reports", filename)
    return send_file(file_path, as_attachment=True)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5705, debug=True, use_reloader=False)