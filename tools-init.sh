#!/bin/bash

# doing this at ~
cwd=$(pwd)
cd ~/environment

echo "-------------------------------------------------------------------------"
echo "Preparing your environment ..."


echo "Installing dependencies ..."
# installing pre-req for serverless
sudo yum install jq zsh -y -q -e 0 >/dev/null 2>&1

# remove old nvm
rm -rf ~/.nvm

# unset the NVM path
export NVM_DIR=

# install NVM
echo "Installing nvm ..."
curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash 
source ~/.nvm/nvm.sh 

# use LTS release
nvm install --lts 
nvm alias default stable
# nvm use default 

# installing libs
echo "Installing framework and libs ..."
npm install -g serverless pnpm hygen yarn docusaurus serverless pnpm hygen >/dev/null 2>&1

# setting min version to stable
echo "stable" > ~./nvmrc 

# for the packer img builder
echo "Installing packer ..."
wget https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_linux_amd64.zip unzip packer_1.7.2_linux_amd64.zip >/dev/null 2>&1
unzip packer_1.7.2_linux_amd64.zip >/dev/null 2>&1
sudo mv packer /usr/local/bin/ >/dev/null 2>&1
rm -f packer_1.7.2_linux_amd64.zip >/dev/null 2>&1

echo "Cloning SWB Repo ..."
# clone the workbench
git clone --depth 1 --branch v3.1.0 https://github.com/awslabs/service-workbench-on-aws.git >/dev/null 2>&1

# cloud9 utils utils
echo "Cloning SWB Tools ..."
mkdir ~/environment/cloud9-tools >/dev/null 2>&1
cd ~/environment/cloud9-tools

echo "Resizing AWS Cloud9 instance volume ..."
# download the resize script
wget -q https://gist.githubusercontent.com/dgomesbr/0f31d90260b7f33e6edde66703325398/raw/cloud9-resize.sh -O cloud9-resize.sh
chmod +x cloud9-resize.sh

# execute the resize script and bump the disk to 50GB by default
# ./cloud9-resize.sh


wget -q https://gist.githubusercontent.com/dgomesbr/0f31d90260b7f33e6edde66703325398/raw/example-hosting-account-params.json -O example-hosting-account-params.jso
wget -q https://gist.githubusercontent.com/dgomesbr/0f31d90260b7f33e6edde66703325398/raw/create-host-account.sh -O create-host-account.sh
chmod +x create-host-account.sh
cd -

# getting back to the working dir
cd $cwd

echo "Finishing up ..."
# creating an alias for searching the AMIs for a given STAGE_NAME
echo -e "alias swb-ami-list='aws ec2 describe-images --owners self --query \"reverse(sort_by(Images[*].{Id:ImageId,Name:Name, Created:CreationDate}, &Created))\" --filters \"Name=name,Values=${STAGE_NAME}*\" --output table'" >> ~/.bashrc 

# This has to be the last item that goes into bashrc, otherwise NVM 
# will keep forgetting the current version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 
source ~/.bashrc 

echo ""
echo "Your AWS Cloud9 Environment is ready to use. "
echo "-------------------------------------------------------------------------"