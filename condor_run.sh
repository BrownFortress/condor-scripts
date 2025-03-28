#!/bin/bash


# SSH stuff
export HOME=$PWD
SSH_DIR="$PWD/.ssh"         # SSH directory
KEY_PATH="$SSH_DIR/htcondor_key"
KNOWN_HOSTS="$SSH_DIR/known_hosts"
AUT_PATH="$SSH_DIR/authorized_keys"

# Variables
# REMOTE MEANS THE MACHINE WHERE YOU SUBMIT THE JOB WITH condor_submit 

REMOTE_USER=""           # Add your beautiful remote username 
REMOTE_HOST="X.X.X.X"         # IP of your awesome remote machine 
REMOTE_PATH="/home/$REMOTE_USER" # Path to remote folder
REMOTE_ASSETS_PATH="" # Path to the folder that stores the weights (if any)  


# Don't need to change these lines. But you can delete assets if you don't need it
LOCAL_MOUNT="$PWD/mnt" # Name folder to mount
ASSETS="$PWD/assets" # Assets folder

CONDA_ENV="" # Name of the conda environment to activate 
WORKING_FOLDER="" # Folder containing your project
PYTHON_SCRIPT="main.py" # Python script to run

if [ -f "$KNOWN_HOSTS" ]; then
    rm $KNOWN_HOSTS
fi
if [ -f "$AUT_PATH" ]; then
    rm $AUT_PATH
fi

cat <<EOF > culomb
Host $REMOTE_HOST
    IdentityFile $KEY_PATH
    UserKnownHostsFile $KNOWN_HOSTS
EOF
# Add remote host key to known_hosts (avoids interactive prompt)
ssh-keyscan -t rsa -H "$REMOTE_HOST" >> "$KNOWN_HOSTS" 2>/dev/null
chmod 644 "$KNOWN_HOSTS"
# cat $KNOWN_HOSTS

# cat culomb
ssh -F "$PWD/culomb" $REMOTE_USER@$REMOTE_HOST "echo 'BANANA BREAD!'"
# Ensure the mount point exists
mkdir -p $LOCAL_MOUNT
chmod 777 $LOCAL_MOUNT
echo "I'm mounting"

# echo $KNOWN_HOSTS
 
sshfs -F $PWD/culomb  $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH $LOCAL_MOUNT
#echo "$(ls $LOCAL_MOUNT/anaconda3)"

if [ -d "$LOCAL_MOUNT/anaconda3" ]; then
    CONDA="anaconda3"
else
    CONDA="miniconda3"
fi

mkdir -p $ASSETS
chmod 777 $ASSETS
echo "I'm mounting ASSETS"

# echo $KNOWN_HOSTS
 
sshfs -F $PWD/culomb  $REMOTE_USER@$REMOTE_HOST:$REMOTE_ASSETS_PATH $ASSETS

pushd $LOCAL_MOUNT/$WORKING_FOLDER
# Run the actual job
echo "Running job..."
# RUN PYTHON 
export CUDA_VISIBLE_DEVICES=0 # You can add more devices if you have/need them.
export HF_HOME=$ASSETS
export PYTHON=$LOCAL_MOUNT/$CONDA/envs/$CONDA_ENV/bin/python
$PYTHON -u $PYTHON_SCRIPT > stdout.txt 2> stderr.txt 
popd

# Unmount after job completion
fusermount3 -u $LOCAL_MOUNT
fusermount3 -u $ASSETS
