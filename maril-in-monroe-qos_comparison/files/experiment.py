#!/usr/bin/python
# -*- coding: utf-8 -*-

# Author: Eneko Atxutegi
# Date: Jul 2016
# License: GNU General Public License v3
# Developed for use by MARiL in the framework of external experimenters in the EU H2020 MONROE project

"""
Simple experiment to gather the output of ls

The script will execute a experiment(curl) on a interface with a specified
operator and log the gps position during the experiment.
The output will be formated into a json object.
"""
import json
import zmq
import sys
import netifaces
import time
from subprocess import check_output
from multiprocessing import Process, Manager
import subprocess

# Configuration
DEBUG = True #False
CONFIGFILE = '/monroe/config' # EHU NQAS

# Default values (overwritable from the scheduler)
# Can only be updated from the main thread and ONLY before any
# other processes are started
EXPCONFIG = {
        # The following value are specific to the monore platform
        "guid": "no.guid.in.config.file",  # Overridden by scheduler
        "nodeid": "no.nodeid.in.config.file",  # Overridden by scheduler
        "storage": 104857600,  # Overridden by scheduler
        "traffic": 104857600,  # Overridden by scheduler
        "script": "jonakarl/experiment-template",  # Overridden by scheduler
        "zmqport": "tcp://172.17.0.1:5556",
        "modem_metadata_topic": "MONROE.META.DEVICE.MODEM",
        "gps_metadata_topic": "MONROE.META.DEVICE.GPS",
        # "dataversion": 1,  #  Version of experiment
        # "dataid": "MONROE.EXP.JONAKARL.TEMPLATE",  #  Name of experiement
        "meta_grace": 120,  # Grace period to wait for interface metadata
        "exp_grace": 120,  # Grace period before killing experiment
        "meta_interval_check": 5,  # Interval to check if interface is up
        "verbosity": 2,  # 0 = "Mute", 1=error, 2=Information, 3=verbose
        "resultdir": "/monroe/results/",
        # These values are specic for this experiment
        "operator": "Telenor SE",
        "url": "http://193.10.227.25/test/1000M.zip",
        "size": 3*1024,  # The maximum size in Kbytes to download
        "time": 3600  # The maximum time in seconds for a download
        }

# What to save from curl
CURL_METRICS = ('{ '
                '"Host": "%{remote_ip}", '
                '"Port": "%{remote_port}", '
                '"Speed": %{speed_download}, '
                '"Bytes": %{size_download}, '
                '"TotalTime": %{time_total}, '
                '"SetupTime": %{time_starttransfer} '
                '}')

#subprocess.call(['./myscript.sh'])
print "start"
#output = subprocess.call("bash myscript.sh", shell=True)  #Absolute path needed
#output = subprocess.call("bash /home/eneko/Documentos/MONROE/Docker_EHU/Experiments/experiments/maril-in-monroe/files/myscript.sh", shell=True)  #Absolute Local path
#output = subprocess.call("ls -lah > /monroe/results/listing.txt", shell=True)
output = subprocess.call("pwd > /monroe/results/listing.txt", shell=True)
print "end"

