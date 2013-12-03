#! /usr/bin/env python

import socket
import random
import hmac
import hashlib
import argparse

UDP_IP = '::1'
UDP_PORT = 28000
SECRET_KEY = '74e6f7298a9c2d168935f58c001bad88'
PROBE_NAME = 'temp1'


parser = argparse.ArgumentParser(description='Sends random values via UDP.')
parser.add_argument('-v', '--verbose', help='Be verbose', action="store_true", default=False)
parser.add_argument('-l', '--loop', help='Run in endless loop', action="store_true", default=False)

cmdargs = parser.parse_args()

sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)

def send_data():
  value = random.random() * 100
  data  = '%(name)s:%(value)f' % {'name': PROBE_NAME, 'value': value}
  hmac  = gen_hmac(data)

  message = '%(data)s:%(hmac)s' % {'data':data, 'hmac':hmac}

  if cmdargs.verbose:
    print message

  sock.sendto(message, (UDP_IP, UDP_PORT))

def gen_hmac(data):
  hasher = hmac.new(SECRET_KEY, data, hashlib.sha256)
  return hasher.hexdigest()

if cmdargs.loop:
  while True:
    send_data()
else:
  send_data()
