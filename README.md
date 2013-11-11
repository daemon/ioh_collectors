ioh_collectors
==============

An attempt to write async udp collectors in different languages purely for fun.
All collectors should write parsed message in mongodb.

Message is a plain string with ":" usead as field separator. For example:

    probe_name:probe_value:checksum

So it is really simple and straightforward.

Clients are talking to collector via (IPv6) UDP on port 28000.


ruby-emle
---------

Collector implemented in Ruby (2.0) using EventMachine-LE (for IPv6 support).
