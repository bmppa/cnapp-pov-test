#!/bin/bash
# source: https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/

# Install Unzip
sudo apt-get install -y unzip jq

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install kubectl
#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Import the public key used by the package management system
sudo apt-get install gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

# Create a list file for MongoDB
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Reload local package database
sudo apt-get update

# Install the MongoDB packages
sudo apt-get install -y mongodb-org

# To prevent unintended upgrades
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-database hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-mongosh hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections

# Start MongoDB
# db.version()
sudo systemctl start mongod

sleep 5

# Create user accounts
# Test using the following command:
# mongosh "mongodb://mongo-root:HpLjQn1omcsvvp3d6fa1@localhost:27017"
# mongosh admin --eval 'db.createUser({user:"superadmin", pwd:"HpLjQn1omcsvvp3d6fa1", roles:[{ role: "userAdminAnyDatabase", db: "admin" }, { role: "readWriteAnyDatabase", db: "admin" }]})'
# mongosh admin --eval 'db.createUser({user: "tasky", pwd: "TaskMeIfY0uCan!", roles: [{role: "readWrite", db: "go-mongodb"}]})'
# mongosh admin --eval 'db.createUser({user: "backup", pwd: "C@nY0uR3adThis!", roles: [{role: "backup", db: "admin"}]})'
mongosh admin --eval 'db.createUser({user: "mongo-root", pwd: "HpLjQn1omcsvvp3d6fa1", roles: [{role: "root", db: "admin"}]})'

# Use custom configuration file for MongoDB
sudo cat << EOF > /etc/mongod.conf
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb
#  engine:
#  wiredTiger:

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0

# how the process runs
processManagement:
  timeZoneInfo: /usr/share/zoneinfo

security:
  authorization: enabled

#operationProfiling:

#replication:

#sharding:

## Enterprise-Only Options:

#auditLog:
EOF

# Restart MongoDB
sudo systemctl restart mongod

# Ensure that MongoDB will start following a system reboot
sudo systemctl enable mongod

# Set timezone to EST
sudo timedatectl set-timezone America/New_York

# Create and add content to the demo-db database
# mongosh demo-db --eval 'db.posts.insertOne({ title: "Post Title 1", body: "Body of post.", category: "News", likes: 1, tags: ["news", "events"], date: Date() })'
# mongosh demo-db --eval 'db.posts.insertOne({ title: "Post Title 2", body: "Body of post.", category: "News", likes: 2, tags: ["news", "events"], date: Date() })'

# Create backup folder for MongoDB
#sudo mkdir backup

# Schedule the cron job to dump and backup the MongoDB to S3
sudo echo '*/5 * * * * mongodump --uri="mongodb://mongo-root:HpLjQn1omcsvvp3d6fa1@localhost:27017" --out /home/ubuntu/backup' > mycron
sudo echo '*/6 * * * * aws s3 cp /home/ubuntu/backup s3://'"${s3_bucket}"'/$(date +\%F-\%T) --recursive' >> mycron
sudo crontab mycron
sudo rm mycron
