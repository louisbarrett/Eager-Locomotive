// Receive S3 put event  containing the location of a cloudtrail log
// Retrieves and parses the log shipping data to a kinesis stream

package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/Jeffail/gabs"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kinesis"
	"github.com/aws/aws-sdk-go/service/s3"
)

var sess *session.Session

//ThrottleSeconds Controls how long the throttling function waits
const ThrottleSeconds = 3

//KinesisDataStreamName - The name of the kinesis data stream to send okta events - Check if stream exists
var KinesisDataStreamName = os.Getenv("KINESIS_STREAM")
var JSONContainer *gabs.Container
var KinesisStreamName string
var output []rune
var ByteSlice [][]byte

// KinesisRecords  --
var KinesisRecords []*kinesis.PutRecordsRequestEntry

// JSONToKinesisBatch - Optimized version of JSONtoKinesis
func JSONToKinesisBatch(Records [][]byte, KinesisDataStreamName string) {
	sess := session.Must(session.NewSession())
	if (len(Records)) == 0 || (len(Records)) > 500 {
		log.Fatal("Invalid record count")
	}
	for n := range Records {
		ParsedJSON, err := gabs.ParseJSON(Records[n])
		if err != nil {
			log.Fatal(err)
		}
		DataEntry := kinesis.PutRecordsRequestEntry{
			Data:         []byte(ParsedJSON.Bytes()),
			PartitionKey: aws.String("0"),
		}
		KinesisRecords = append(KinesisRecords, &DataEntry)
		// return
	}
	log.Println("Writing", len(Records), "records to", KinesisDataStreamName)

	var kin = kinesis.New(sess)
	_, err := kin.PutRecords(
		&kinesis.PutRecordsInput{
			Records:    KinesisRecords,
			StreamName: aws.String(KinesisDataStreamName),
		})
	if err != nil {
		log.Fatal("An error has occured", err)
	} else {
		log.Println("Record delivery complete")

	}
	KinesisRecords = nil
}

//Handler - the lambda function handler
func Handler(ctx context.Context, EventData events.S3Event) {
	fmt.Println(KinesisDataStreamName)

	Records := EventData.Records
	var BucketName string
	var LogFileName string
	sess = session.New()

	for i := range Records {

		BucketName = Records[i].S3.Bucket.Name
		LogFileName = Records[i].S3.Object.Key
		S3Client := s3.New(sess)
		S3InputObject := s3.GetObjectInput{
			Bucket: aws.String(BucketName),
			Key:    aws.String(LogFileName),
		}
		fmt.Println("Attempting to retrieve log file", BucketName, LogFileName)
		LogObject, err := S3Client.GetObject(&S3InputObject)
		if err != nil {
			log.Fatal("An error occured when attempting to retrieve", BucketName, LogFileName, err)
		}
		LogContents, err := ioutil.ReadAll(LogObject.Body)
		if err != nil {
			log.Fatal("An error occured when attempting to read", BucketName, LogFileName, err)
		}
		LogContentsParsed, _ := gabs.ParseJSON(LogContents)
		Children, err := LogContentsParsed.Search("Records").Children()
		if err != nil {
			fmt.Println(JSONContainer.String())
			log.Fatal("Cannot parse JSON ", err)
		}
		Counter := 1
		Position := 0
		Limit := len(Children)
		for x := range Children {
			ByteSlice = append(ByteSlice, Children[x].Bytes())
			if Counter == 500 {
				JSONToKinesisBatch(ByteSlice, KinesisStreamName)
				ByteSlice = [][]byte{}
				Counter = 0
			}
			if Limit == Position+1 {
				JSONToKinesisBatch(ByteSlice, KinesisStreamName)
			}
			Counter++
			Position++
		}
	}
	fmt.Println("Finished retrieving logs from ", BucketName, "/", LogFileName)
}
func main() {
	lambda.Start(Handler)
}
