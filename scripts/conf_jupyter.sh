#!/bin/bash
# script name:     conf_jupyter.sh
# last modified:   2018/09/23
# sudo:            no

script_name=$(basename -- "$0")
env="/home/pi/.venv/jns"

if [ $(id -u) = 0 ]
then
   echo "usage: ./$script_name"
   exit 1
fi

# activate virtual environment
source $env/bin/activate

# generate config and create notebook directory
# if notebook directory exists, we keep it (-p)
# if configuration file exeists, we overwrite it (-y)

jupyter notebook -y --generate-config
cd $home

target=~/.jupyter/jupyter_notebook_config.py

# set up dictionary of changes for jupyter_config.py
declare -A arr
app='c.ServerApp'
arr+=(["$app.open_browser"]="$app.open_browser = False")
arr+=(["$app.ip"]="$app.ip ='*'")
arr+=(["$app.port"]="$app.port = 8888")
arr+=(["c.NotebookApp.enable_mathjax"]="c.NotebookApp.enable_mathjax = True")
arr+=(["$app.root_dir"]="$app.root_dir = '/home/pi/iot49'")
arr+=(["$app.password"]="$app.password = 'sha1:5815fb7ca805:f09ed218dfcc908acb3e29c3b697079fea37486a'")
arr+=(["$app.allow_remote_access"]="$app.allow_remote_access = True")

# apply changes to jupyter_notebook_config.py

for key in ${!arr[@]};do
    if grep -qF $key ${target}; then
        # key found -> replace line
        sed -i "/${key}/c ${arr[${key}]}" $target
    else
        # key not found -> append line
        echo "${arr[${key}]}" >> $target
    fi
done

# install iot kernel
python3 -m iot_kernel.install

# install nodejs and node version manager n
# if node is not yet installed
if which node > /dev/null
    then
        echo "node is installed, skipping..."
    else
        # install nodejs and node version manager n
        cd ~/jns
        # fix for issue #22
        # install nodejs and node version manager n
        # see: https://github.com/mklement0/n-install
        curl -L https://git.io/n-install | bash -s -- -y lts
fi

# install jupyter lab extensions
# bash -i ./inst_lab_ext.sh
