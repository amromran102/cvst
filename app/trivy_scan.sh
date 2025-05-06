#!/bin/bash

# Print the value of IMAGES to stdout
echo "Image List: $IMAGES"

# Get input from environment variable
images=$IMAGES

# CSV Output file
csv_output_file="reports/cvst_report-$(date +"%Y-%m-%d_%H-%M-%S").csv"
# HTML Output file
html_output_file="reports/cvst_report-$(date +"%Y-%m-%d_%H-%M-%S").html"

# Print the dynamically generated output file name
echo "$csv_output_file"
echo "$html_output_file"

# Create 'reports' directory if it doesn't exist
mkdir -p reports

# Print header line
echo "Image,Target,PackageName,VulnerabilityID,Severity,CVSS,InstalledVersion,FixedVersion,Description,VulnerabilityLink" > "$csv_output_file"

# Loop through each image
for image in $images; do
  echo "Scanning image: $image"

  # scan trivy image in html format
  trivy image --scanners vuln --format template --template '@./templates/html.tpl' "$image" >> "$html_output_file"  

  # Redirect trivy output to the file, filter out empty lines, and process each line
  trivy image --scanners vuln --format template --template '@./templates/csv.tpl' "$image" |
  awk NF |
  while IFS=, read -r target package_name vulnerability_id severity score installed_version fixed_version title vulnerability_link; do
    echo "$image,$target,$package_name,$vulnerability_id,$severity,$score,$installed_version,$fixed_version,$title,$vulnerability_link" >> "$csv_output_file"
  done
done
