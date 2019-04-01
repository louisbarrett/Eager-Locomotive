// Receive S3 put event  containing the location of a cloudtrail log
// Retrieves and parses the log shipping data to a kinesis stream

package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"os"
	"time"

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

// JSONToKinesisBatch - Optimized version of JSONtoKinesis
func JSONToKinesisBatch(Records []*kinesis.PutRecordsRequestEntry, KinesisDataStreamName string) {

	var kin = kinesis.New(sess)
	_, err := kin.PutRecords(
		&kinesis.PutRecordsInput{
			Records:    Records,
			StreamName: aws.String(KinesisDataStreamName),
		})
	if err != nil {
		fmt.Println("An error has occured:", err)
	} else {
		fmt.Println("Record delivery complete")
	}

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
			fmt.Println("An error occured when attempting to retrieve", BucketName, LogFileName)
			fmt.Println(err)
			os.Exit(1)
		}
		LogContents, err := ioutil.ReadAll(LogObject.Body)
		if err != nil {
			fmt.Println("An error occured when attempting to read", BucketName, LogFileName)
			fmt.Println(err)
			os.Exit(1)
		}
		LogContentsParsed, _ := gabs.ParseJSON(LogContents)
		LogRecords, err := LogContentsParsed.Search("Records").Children()
		if err == nil {
			counter := 0
			TotalCounter := 0
			SubCounter := 0
			PartitionKeying := 0
			var Records []*kinesis.PutRecordsRequestEntry
			var PartitionKey string
			TotalRecords := len(LogRecords)
			for J := range LogRecords {
				PureJSON := LogRecords[J].Bytes()
				counter++
				if PartitionKeying == 1 {
					PartitionKey = "000000000001"
					PartitionKeying = 0
				} else {
					PartitionKey = "000000000000"
					PartitionKeying++
				}

				DataEntry := kinesis.PutRecordsRequestEntry{
					Data:         []byte(PureJSON),
					PartitionKey: aws.String(PartitionKey),
				}
				Records = append(Records, &DataEntry)
				if SubCounter == 5 {
					// fmt.Println("Throttling")
					//wait n seconds before sending the next batch of requests
					// ThrottleSeconds := 3
					Throttle := time.Duration(time.Second * ThrottleSeconds)
					time.Sleep(Throttle)
					SubCounter = 0
				}
				if counter == 500 {
					TotalCounter += counter
					counter = 0
					fmt.Println("Processing", TotalCounter, "of", TotalRecords, "messages")
					JSONToKinesisBatch(Records, KinesisDataStreamName)
					SubCounter++
					Records = nil
				}

			}
			if counter < 500 {
				TotalCounter += counter
				fmt.Println("Processing", TotalCounter, "of", TotalRecords, "messages")
				JSONToKinesisBatch(Records, KinesisDataStreamName)
			}

		} else {
			fmt.Println("Something Really shitty happened")
			fmt.Println(err)
			os.Exit(1)
		}
	}
	fmt.Println("Finished retrieving logs from ", BucketName, "/", LogFileName)
}
func main() {
	lambda.Start(Handler)
}
