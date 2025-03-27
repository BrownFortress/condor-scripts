#!/bin/bash
SSH_DIR="$HOME/.ssh"
KEY_PATH="$HOME/.ssh/htcondor_key"
AUT_PATH="$HOME/.ssh/authorized_keys"
# Don't touch this, tururu tu tu, tu tu

# Generate SSH key if not exists

if  [ ! -d $SSH_DIR ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

if [ ! -f "$KEY_PATH" ]; then
    ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -q
    echo "SSH key generated at $KEY_PATH"
else
    echo "SSH key already exists."
fi
if  [ ! -f $AUT_PATH ]; then
    touch $AUT_PATH
fi

cat "$KEY_PATH.pub" >> $AUT_PATH
echo "$AUT_PATH"
cat $AUT_PATH
