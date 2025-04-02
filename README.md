# Useful scripts for using HT Condor when using conda and training ML models

In this repo, you can find some scripts for HT Condor to avoid the copying of files on the execution node by mounting a target folder via ssh. 

## Getting started

First, you need to install HT Condor on your machines. Here is the official guide [LINK](https://htcondor.readthedocs.io/en/latest/getting-htcondor/install-linux-as-root.html#).

Once you've done this, you to place the content of this folder in your home folder. (This is the simplest way, if you are familiar with bash you can easily customize the script. )

Before starting, we declare two variables just to make the guidelines clearer. We have a master node called `beatrix` and an execution node called virgil`. (Dante et al.)

Then, you can run `create_ssh_keys.sh` as 
```bash
chmod u+x create_ssh_keys.sh
./create_ssh_keys.sh
```
This script creates the SSH keys needed for mounting a target folder.

After that, you can open the file `condor_run.sh` with your preferred editor. This script mounts your home folder in the condor work environment and executes the script you would like to execute. The parameters that you have to modify are the following.
```bash
REMOTE_USER="beatrix" # This is the username of the machine where you are gonna launch the job usually the master node
REMOTE_HOST="23.42.42.111"    # The IP of the machine where you are gonna launch the job. Which is equivalent to beatrix@23.42.42.111
```
We designed this script to launch machine learning models, so we have specific paths for model weights and conda environment (anaconda or miniconda). If you have other needs you have to modify a bit this script.  So the next step is to specify the folder of model weights if you need them. 
```bash
REMOTE_ASSETS_PATH="" # Path to the folder that stores the weights (if any)
```
Then, you have to specify the conda environment to activate and the script to run.
```bash
CONDA_ENV="may4" # Name of the conda environment to activate
WORKING_FOLDER="example" # Folder containing your project (that contains the main)
PYTHON_SCRIPT="main.py" # Python script to run (main for instance)
...
# If you have more than one GPU you can list them here. If you don't have any GPU you can comment out this part.
export CUDA_VISIBLE_DEVICES=0 # You can add more devices if you have/need them.
```
After this, you can save the file and move to the next script `job_example.sub`. 
This file is the default file to launch jobs in Codor, thus if you need some other configurations please follow the condor guidelines. Otherwise, you can modify the script in this way.
```bash
request_GPUs = 1 # The number of gpus you need (if any)

# Ensure job runs on a specific machine (our execution node)
requirements = (Machine == "virgil")
```

Alright! Now, you can launch your condor job by running this:
```bash
condor_submit job_example.sub
```
And enjoy! 
