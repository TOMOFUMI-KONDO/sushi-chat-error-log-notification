package main

import (
	"bytes"
	"compress/gzip"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/bwmarrin/discordgo"
)

type Request struct {
	AwsLogs struct {
		Data string `json:"data"`
	} `json:"awslogs"`
}

type LogData struct {
	LogEvents []struct {
		Message string `json:"message"`
	} `json:"logEvents"`
}

func handler(ctx context.Context, request Request) error {
	token := "Bot " + os.Getenv("TOKEN")
	channelID := os.Getenv("CHANNEL_ID")

	data, err := decode(request.AwsLogs.Data)
	if err != nil {
		return handleErr("decode", err)
	}
	var logData LogData
	if err := json.Unmarshal(data, &logData); err != nil {
		return handleErr("json.Unmarshal", err)
	}

	dg, err := discordgo.New(token)
	if err != nil {
		return handleErr("discordgo.New", err)
	}
	if err := dg.Open(); err != nil {
		return handleErr("dg.Open", err)
	}
	defer dg.Close()

	sendLog(dg, channelID, logData.LogEvents[0].Message)

	return nil
}

func decode(data string) ([]byte, error) {
	byteData, err := base64.StdEncoding.DecodeString(data)
	if err != nil {
		return nil, err
	}

	rdata := bytes.NewReader(byteData)
	reader, err := gzip.NewReader(rdata)
	if err != nil {
		return nil, err
	}
	b, err := ioutil.ReadAll(reader)
	if err != nil {
		return nil, err
	}

	return b, nil
}

func sendLog(s *discordgo.Session, channelID string, msg string) {
	_, err := s.ChannelMessageSend(channelID, msg)
	if err != nil {
		log.Println("Error sending message: ", err)
	}
}

func handleErr(msg string, err error) error {
	err = fmt.Errorf("%s: %w", msg, err)
	log.Printf("[ERROR] %s\n", err.Error())

	return err
}

func main() {
	lambda.Start(handler)
}
