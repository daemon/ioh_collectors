package main

import (
  "net"
  "fmt"
)

func main() {
  serverAddr, err := net.ResolveUDPAddr("udp6", "[::1]:28000")
  con, err := net.DialUDP("udp", nil, serverAddr)

  if err != nil { panic(err) }

  fmt.Fprintf(con, "temp1:100:74e6f7298a9c2d168935f58c001bad88")
}
