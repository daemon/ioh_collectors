package main

import (
	"flag"
	"fmt"
	"labix.org/v2/mgo"
	// "labix.org/v2/mgo/bson"
	"net"
	"strconv"
	"strings"
	"time"
)

type Probe struct {
	Name      string
	Value     float64
	HMAC      string
	CreatedAt time.Time `bson:"created_at"`
}

var flag_verbose = flag.Bool("verbose", false, "be verbose")

var db *mgo.Collection

func main() {
	flag.Parse()

	session, err := mgo.Dial("localhost:27017")
	if err != nil {
		panic(err)
	}
	defer session.Close()

	// Strong, Monotonic, Eventual
	session.SetMode(mgo.Eventual, true)

	db = session.DB("go_collector").C("metrics")

	serverAddr, err := net.ResolveUDPAddr("udp6", "[::1]:28000")
	if err != nil {
		panic(err)
	}

	conn, err := net.ListenUDP("udp6", serverAddr)
	if err != nil {
		panic(err)
	}

	for {
		message := make([]byte, 512)
		length, _, err := conn.ReadFromUDP(message)

		if err != nil {
			panic(err)
		}

		storeData(string(message[0:length]))
	}
}

func storeData(data string) {
	if *flag_verbose {
		fmt.Printf("%s\n", data)
	}

	fields := strings.Split(data, ":")

	// Example of using arbitrary structure
	// probe := bson.M{}
	// probe["name"] = fields[0]
	// probe["value"] = fields[1]
	// probe["hmac"] = fields[2]
	// probe["created_at"] = time.Now()
	// db.Insert(probe)

	var value float64
	var err error

	value, err = strconv.ParseFloat(fields[1], 64)
	if err != nil {
		return
	}

	reading := Probe{
		Name:      fields[0],
		Value:     value,
		HMAC:      fields[2],
		CreatedAt: time.Now(),
	}

	err = db.Insert(reading)
	if err != nil {
		panic(err)
	}

}
