package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"flag"
	"fmt"
	"io"
	"math/rand"
	"net"
	"time"
)

var flag_loop = flag.Bool("loop", false, "run in endless loop")
var flag_verbose = flag.Bool("verbose", false, "be verbose")

var secret_key = "74e6f7298a9c2d168935f58c001bad88"

func main() {
	flag.Parse()

	serverAddr, err := net.ResolveUDPAddr("udp6", "[::1]:28000")
	if err != nil {
		panic(err)
	}

	rand.Seed(time.Now().UnixNano())

	if *flag_loop {
		for {
			SendData(serverAddr)
		}
	} else {
		SendData(serverAddr)
	}

}

func SendData(server *net.UDPAddr) {
	con, err := net.DialUDP("udp", nil, server)
	if err != nil {
		panic(err)
	}
	rand_value := rand.Intn(100)
	data := fmt.Sprintf("%s:%d", "temp1", rand_value)
	hmac := GenHmac(data)

	fmt.Fprintf(con, "%s:%s", data, hmac)
	if *flag_verbose {
		fmt.Printf("%s:%s\n", data, hmac)
	}
}

func GenHmac(message string) string {
	mac := hmac.New(sha256.New, []byte(secret_key))
	io.WriteString(mac, message)

	return fmt.Sprintf("%x", mac.Sum(nil))
}
