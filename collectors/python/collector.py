#! /usr/bin/env python

import socket
import SocketServer
import argparse

from pymongo import MongoClient
import datetime

UDP_IP = '::1'
UDP_PORT = 28000
SECRET_KEY = '74e6f7298a9c2d168935f58c001bad88'
MONGO = 'mongodb://localhost:27017/'

parser = argparse.ArgumentParser(description='Receives probes values via UDP.')
parser.add_argument('-v', '--verbose', help='Be verbose', action="store_true", default=False)

cmdargs = parser.parse_args()

db_connection = MongoClient(MONGO)
db = db_connection.py_collector

class UDP6Server(SocketServer.ThreadingMixIn, SocketServer.UDPServer):

    address_family = socket.AF_INET6


class ProbeHandler(SocketServer.BaseRequestHandler):
    def handle(self):
        data = self.request[0].strip()
        socket = self.request[1]

        if cmdargs.verbose:
            print data

        self.store_data(data)

    def store_data(self, data):
        name, value, hmac = data.split(":", 3)

        probe = {
            "name"          : name,
            "value"         : float(value),
            "hmac"          : hmac,
            "created_at"    : datetime.datetime.utcnow()
        }

        db.metrics.insert(probe)

server = UDP6Server((UDP_IP, UDP_PORT), ProbeHandler)

server.serve_forever()
