#!/bin/bash
# Copia espejo del script de arranque. La fuente usada por Terraform es:
# terraform/aws/templates/ec2-user-data.sh.tpl (bucket y región inyectados al aplicar).
exec > /var/log/user-data.log 2>&1  # Log all output

sudo yum install -y python3-pip

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install AWS CLI
install_aws_cli() {
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    echo "AWS CLI installed successfully!"
}

# Install AWS CLI if not installed
if ! command_exists aws; then
    install_aws_cli
else
    echo "AWS CLI is already installed!"
fi

# Pull application code from S3
mkdir -p /home/ec2-user/myflaskapp
echo "Pulling application code from S3..."
aws s3 sync s3://ritual-roast-dev-339712719836-us-east-1   /home/ec2-user/myflaskapp --region us-east-1  # Ensure correct region
cd /home/ec2-user/myflaskapp

# Verify that files were downloaded
ls -lah

# Ensure the "flask" directory exists before changing into it
if [ -d "flask" ]; then
    cd flask
else
    echo "Error: 'flask' directory not found in /home/ec2-user/myflaskapp!"
    exit 1
fi

# Install dependencies
pip3 install --upgrade pip  # Ensure pip is up to date
pip3 install -r requirements.txt

# Run Flask application (Use nohup to prevent it from stopping)
nohup python3 ritual-roast.py > /var/log/flask-app.log 2>&1 &

echo "Setup completed successfully!"
