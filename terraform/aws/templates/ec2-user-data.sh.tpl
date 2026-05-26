#!/bin/bash
set -euo pipefail
exec > /var/log/user-data.log 2>&1

dnf install -y python3-pip python3-devel unzip

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists aws; then
    echo "Installing AWS CLI..."
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install
fi

python3 --version
pip3 --version

APP_ROOT="/home/ec2-user/myflaskapp"
mkdir -p "$APP_ROOT"
echo "Pulling application code from S3..."
aws s3 sync "s3://${s3_bucket_name}" "$APP_ROOT" --region "${aws_region}"
chown -R ec2-user:ec2-user "$APP_ROOT"

cd "$APP_ROOT"
ls -lah

if [ ! -d "flask" ]; then
    echo "Error: 'flask' directory not found in $APP_ROOT"
    exit 1
fi

cd flask
# No actualizar pip del sistema (rpm): falla "Cannot uninstall pip ... RECORD file not found"
python3 -m pip install -r requirements.txt

export AWS_DEFAULT_REGION="${aws_region}"
export MYSQL_SECRET_NAME="${mysql_secret_name}"
export MYSQL_DATABASE_NAME="${mysql_database_name}"

echo "MYSQL_SECRET_NAME=$${MYSQL_SECRET_NAME}"
echo "MYSQL_DATABASE_NAME=$${MYSQL_DATABASE_NAME}"

nohup python3 ritual-roast.py > /var/log/flask-app.log 2>&1 &

ok=0
for i in $(seq 1 36); do
    if curl -sf "http://127.0.0.1:5000/health" >/dev/null; then
        ok=1
        echo "Flask /health OK tras $${i} intento(s)"
        break
    fi
    sleep 10
done

if [ "$ok" -ne 1 ]; then
    echo "Flask no responde en 5000/health tras 6 min"
    tail -80 /var/log/flask-app.log || true
    ps aux | grep -E 'python|flask' || true
    ss -tlnp | grep 5000 || true
    exit 1
fi

echo "Setup completed successfully!"
