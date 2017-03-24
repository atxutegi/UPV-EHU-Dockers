#!/usr/bin/python
# -*- coding: utf-8 -*-
# Author: Eneko Atxutegi (member of MARiL-in-MONROE)
# Date: September 2016
# License: GNU General Public License v3
# Developed for use by the EU H2020 MONROE project

"""
Simple experiment template to collect metadata.

The script will log the gps position for 30 seconds.
The output will be formated into a json object.
"""
import json
import zmq
import sys
import netifaces
import time
from subprocess import check_output
from multiprocessing import Process, Manager

# Configuration
DEBUG = False
CONFIGFILE = '/monroe/config'

# Default values (overwritable from the scheduler)
# Can only be updated from the main thread and ONLY before any
# other processes are started
EXPCONFIG = {
        # The following value are specific to the monore platform
        "guid": "no.guid.in.config.file",  # Overridden by scheduler
        "nodeid": "no.nodeid.in.config.file",  # Overridden by scheduler
        "storage": 104857600,  # Overridden by scheduler
        "traffic": 104857600,  # Overridden by scheduler
        "script": "upvehu2016/maril-in-monroe",  # Overridden by scheduler
        "zmqport": "tcp://172.17.0.1:5556",
        "modem_metadata_topic": "MONROE.META.DEVICE.MODEM",
        "gps_metadata_topic": "MONROE.META.DEVICE.GPS",
        "meta_grace": 3,  # Grace period to wait for interface metadata
        "exp_grace": 3,  # Grace period before killing experiment
        "meta_interval_check": 0.1,  # Interval to check if interface is up
        "verbosity": 2,  # 0 = "Mute", 1=error, 2=Information, 3=verbose
        "resultdir": "/monroe/results/",
        # These values are specic for this experiment
        "mccmnc": "24008", #NQAS EHU "Telenor SE"
        }


def run_exp(meta_info, expconfig):
    
    ifname = meta_info['modem']['InternalInterface']

    try:
        # If multiple GPS evenst have ben registered we take the last one
        start_gps_pos = len(meta_info['gps']) - 1
	print "Length of GPS positions  {}".format(start_gps_pos)
        if ifname != meta_info['modem']['InternalInterface']:
            print "Error: Interface has changed during the experiment, abort"
            return
        # We store all gps_positions during the experiment
        gps_positions = meta_info['gps'][start_gps_pos:]

        scriptname = expconfig['script'].replace('/', '.')
        dataid = expconfig.get('dataid', scriptname)
        dataversion = expconfig.get('dataversion', 1)

        # To use monroe_exporter the following fields must be present
        # "Guid"
        # "DataId"
        # "DataVersion"
        # "NodeId"
        # "SequenceNumber"
	
	output = ""
	msg = json.loads(output)

        msg.update({
            "Guid": expconfig['guid'],
            "DataId": dataid,
            "DataVersion": dataversion,
            "NodeId": expconfig['nodeid'],
            "Timestamp": time.clock(),
            "Iccid": meta_info['modem']["ICCID"],
            "InterfaceName": ifname,
            "Operator": meta_info['modem']["Operator"],
            "SequenceNumber": 1,
	    "CID": meta_info['modem']["CID"],
	    "MCCMNC": meta_info['modem']["NWMCCMNC"],
	    "Band": meta_info['modem']["Band"],
	    "RSSI": meta_info['modem']["RSSI"],
	    "IPAddress": meta_info['modem']["IPAddress"],
	    "IMEI": meta_info['modem']["IMEI"],
	    "RSRQ": meta_info['modem']["RSRQ"],
	    "RSRP": meta_info['modem']["RSRP"],
	    "LAC": meta_info['modem']["LAC"],
	    "Frequency": meta_info['modem']["Frequency"],
	    "Latitude": meta_info['gps']["Latitude"],
            "GPSPositions": gps_positions
        })
        if expconfig['verbosity'] > 2:
            print msg
        if not DEBUG:
            monroe_exporter.save_output(msg, expconfig['resultdir'])
    except Exception as e:
        if expconfig['verbosity'] > 0:
            print "Execution or parsing failed: {}".format(e)
    if expconfig['verbosity'] > 1:
        print "Finished Experiment"


def metadata(meta_info, expconfig):
    """Seperate process that attach to the ZeroMQ socket as a subscriber.

        Will listen forever to messages with topic defined in topic and update
        the meta_ifinfo dictionary (a Manager dict).
    """
    context = zmq.Context()
    socket = context.socket(zmq.SUB)
    socket.connect(expconfig['zmqport'])
    socket.setsockopt(zmq.SUBSCRIBE, bytes(expconfig['modem_metadata_topic']))
    socket.setsockopt(zmq.SUBSCRIBE, bytes(expconfig['gps_metadata_topic']))

    print ("METADATA trial"" for {}").format(expconfig['mccmnc'])

    while True:
        data = socket.recv()
        try:
            topic = data.split(" ", 1)[0]
            msg = json.loads(data.split(" ", 1)[1])
            if topic.startswith(expconfig['modem_metadata_topic']):
		print ("METADATA MODEM - required {} got {}").format(expconfig['mccmnc'], msg['NWMCCMNC'])
                if msg['NWMCCMNC'] == "24008":#if msg['NWMCCMNC'] == expconfig['mccmnc']:#if msg['Operator'] == expconfig['operator']:
		    print ("YES")
                    if expconfig['verbosity'] > 2:
                        print ("Got a modem message"
                               " for {}").format(msg['NWMCCMNC'])
                    # In place manipulation of the refrence variable
                    for key, value in msg.iteritems():
                        meta_info['modem'][key] = value
            if topic.startswith(expconfig['gps_metadata_topic']):
		print ("METADATA GPS - Latitude {}").format(msg['Latitude'])
                #if expconfig['verbosity'] > 2:
                #    print ("Got a gps message "
                #           "with seq nr {}").format(msg["SequenceNumber"])
                meta_info['gps'].append(msg)

            if expconfig['verbosity'] > 2:
                print "zmq message", topic, msg
        except Exception as e:
            if expconfig['verbosity'] > 0:
                print ("Cannot get metadata in template container {}"
                       ", {}").format(e, expconfig['guid'])
            pass


# Helper functions
def check_if(ifname):
    """Checks if "internal" interface is up and have got an IP address.

       This check is to ensure that we have an interface in the experiment
       container and that we have a internal IP address.
    """
    return (ifname in netifaces.interfaces() and
            netifaces.AF_INET in netifaces.ifaddresses(ifname))


def check_modem_meta(info):
    """Checks if "external" interface is up and have an IP adress."""
    return ("InternalInterface" in info and
            "Operator" in info and
            "ICCID" in info and
            "Timestamp" in info and
            "IPAddress" in info)


def create_and_run_meta_process(expconfig):
    """Creates the shared datastructures and the metaprocess."""
    m = Manager()
    meta_info = {}
    meta_info['modem'] = m.dict()
    meta_info['gps'] = m.list()
    process = Process(target=metadata,
                      args=(meta_info, expconfig, ))
    process.daemon = True
    process.start()
    return (meta_info, process)


def create_and_run_exp_process(meta_info, expconfig):
    """Creates the experiment process."""
    process = Process(target=run_exp, args=(meta_info, expconfig, ))
    process.daemon = True
    process.start()
    return process


if __name__ == '__main__':
    """The main thread control the processes (experiment/metadata))."""

    if not DEBUG:
        import monroe_exporter
        # Try to get the experiment config as provided by the scheduler
        try:
            with open(CONFIGFILE) as configfd:
                EXPCONFIG.update(json.load(configfd))
        except Exception as e:
            print "Cannot retrieve expconfig {}".format(e)
            sys.exit(1)
    else:
        # We are in debug state always put out all information
        EXPCONFIG['verbosity'] = 3

    # Short hand variables and check so we have all variables we need
    try:
        meta_grace = EXPCONFIG['meta_grace']
        exp_grace = EXPCONFIG['exp_grace']
        meta_interval_check = EXPCONFIG['meta_interval_check']
        EXPCONFIG['guid']
        EXPCONFIG['modem_metadata_topic']
        EXPCONFIG['gps_metadata_topic']
        EXPCONFIG['zmqport']
        EXPCONFIG['verbosity']
        EXPCONFIG['resultdir']
    except Exception as e:
        print "Missing expconfig variable {}".format(e)
        sys.exit(1)

    # Could have used a thread as well but this is true multiprocessing
    # Create a metdata processes for getting modem and gps metadata
    # Will return a dict ['gps'] and ['modem']
    meta_info, meta_process = create_and_run_meta_process(EXPCONFIG)

    # Try to get metadata
    # if the metadata process dies we retry until the meta_grace is up
    start_time = time.clock()
    print "Start looking for metadata matching MCCMNC {}".format(EXPCONFIG['mccmnc'])
    while (time.clock() - start_time < meta_grace and
           (not check_modem_meta(meta_info['modem']) or
           len(meta_info['gps']) < 1)):

        #if EXPCONFIG['verbosity'] > 1:
            #print "Trying to get metadata for MCCMNC {}".format(EXPCONFIG['mccmnc'])

        if not meta_process.is_alive():
            # This is serious as the metadata processes has died
            # should not happen
            if EXPCONFIG['verbosity'] > 1:
                print "Metadata process died, restarting"
            meta_info, meta_process = create_and_run_meta_process(EXPCONFIG)

        meta_process.join(meta_interval_check)

    # Ok we did not get any information within the grace period we give up
    if not (check_modem_meta(meta_info['modem']) or
            len(meta_info['gps']) < 1):
        print "No Metadata or no ip adress on interface: aborting {}".format(meta_info['modem']['InternalInterface'])
        sys.exit(1)

    ifname = meta_info['modem']['InternalInterface']

    if EXPCONFIG['verbosity'] > 1:
        print "Starting experiment"

    start_time_exp = time.clock()
    exp_process = create_and_run_exp_process(meta_info, EXPCONFIG)

    while (time.clock() - start_time_exp < exp_grace and
           exp_process.is_alive()):
        # Here we could add code to handle interfaces going up or down
        # However, for now we just abort if we loose the interface

        if not (check_if(ifname) and
                check_modem_meta(meta_info['modem'])):
            print "Interface went down during a experiment"
            if exp_process.is_alive():
                exp_process.terminate()
            if meta_process.is_alive():
                meta_process.terminate()
            sys.exit(1)

        elapsed_exp = time.clock() - start_time_exp
        if EXPCONFIG['verbosity'] > 1:
            print "Running Experiment for {} s".format(elapsed_exp)
        exp_process.join(meta_interval_check)

    # Cleanup the processes
    if meta_process.is_alive():
        meta_process.terminate()

    if exp_process.is_alive():
        exp_process.terminate()
        if EXPCONFIG['verbosity'] > 0:
            print "Experiment took too long time to finish, please check results"
        sys.exit(1)

    elapsed = time.clock() - start_time

    if EXPCONFIG['verbosity'] > 1:
        print "Finished {} after {}".format(ifname, elapsed)

