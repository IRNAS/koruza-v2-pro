# SPDX-License-Identifier: GPL-2.0+
#
# Copyright (C) 2010 - 2011 Red Hat, Inc.
#

import os
import dbus
import time
import subprocess

# This example asks settings service for all configured connections.
# It also asks for secrets, demonstrating the mechanism the secrets can
# be handled with.

# Create a SystemBus object to communicate with the NetworkManager service

CONNECTION_NAME = os.getenv("CONNECTION_NAME", "koruza-d2d")  # read from balena device variables

bus = dbus.SystemBus()
# https://dbus.freedesktop.org/doc/dbus-python/tutorial.html

# NetworkManager DBus API reference: https://developer.gnome.org/NetworkManager/stable/spec.html

def restart_connection():
    nmcli_command = "sudo nmcli connection up {}".format(CONNECTION_NAME)
    process = subprocess.Popen(nmcli_command.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()

def get_d2d_connected():
    # Get a proxy for the base NetworkManager object
    m_proxy = bus.get_object("org.freedesktop.NetworkManager", "/org/freedesktop/NetworkManager")
    mgr_props = dbus.Interface(m_proxy, "org.freedesktop.DBus.Properties")

    # Find all active connections
    active = mgr_props.Get("org.freedesktop.NetworkManager", "ActiveConnections")
    
    d2d_connected = False

    for a in active:
        a_proxy = bus.get_object("org.freedesktop.NetworkManager", a)

        a_props = dbus.Interface(a_proxy, "org.freedesktop.DBus.Properties")
        #print(a_props)

        # Grab the connection object path so we can get all the connection's settings
        
        connection_id = a_props.Get("org.freedesktop.NetworkManager.Connection.Active", "Id")
        #print(connection_id)

        if connection_id == "koruza-d2d":
            connection_path = a_props.Get("org.freedesktop.NetworkManager.Connection.Active", "Connection")
            #print(connection_path)
            connection_state = a_props.Get("org.freedesktop.NetworkManager.Connection.Active", "State")  # NMActiveConnectionState flags - https://developer.gnome.org/NetworkManager/stable/nm-dbus-types.html#NMActiveConnectionState
            #print(connection_state)
            if connection_state == 2:
                print("successfully reconnected to koruza-d2d")
                d2d_connected = True

    return d2d_connected

if __name__ == '__main__':
    while True:
        d2d_connected = get_d2d_connected()

        if not d2d_connected:
            print("koruza-d2d not connected. Attempting reconnect")
            restart_connection()
        elif d2d_connected:
            print("koruza-d2d is active and connected. sleeping for 60 seconds")

        time.sleep(60)  # retry each minute