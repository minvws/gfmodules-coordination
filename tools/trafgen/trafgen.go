package main

import (
	"math/rand"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/antchfx/htmlquery"
)

const (
	URL         = "https://pgodemo.test.zm.irealisatie.nl/"
	ThreadCount = 10
	MinDelay    = 5
	MaxDelay    = 30
)

func main() {
	for i := 0; i < ThreadCount; i++ {
		var threadId = i
		go func() {
			trafgen(threadId)
		}()
	}

	for {
		time.Sleep(1 * time.Second)
	}
}

func trafgen(threadNr int) {
	// Delay first request
	delay := time.Duration(rand.Intn(MaxDelay-MinDelay)+MinDelay) / 2
	println("Thread", threadNr, "Delay:", delay)
	time.Sleep(delay * time.Second)

	for {
		token, cookie := fetchCsrfTokenAndCookie()
		time.Sleep(1 * time.Second)

		status := submitForm("950000012", "beeldbank", token, cookie)
		delay := time.Duration(rand.Intn(MaxDelay-MinDelay) + MinDelay)

		println("Thread", threadNr, "Status:", status, "Delay:", delay)

		time.Sleep(delay * time.Second)
	}
}

func submitForm(bsn, dataDomain, token string, cookie http.Cookie) string {
	println("Submitting form with BSN:", bsn, "Data domain:", dataDomain, "Token:", token, "Cookie:", cookie.Raw)

	data := url.Values{}
	data.Set("form[bsn]", bsn)
	data.Set("form[data_domain]", dataDomain)
	data.Set("form[_token]", token)

	r, _ := http.NewRequest(http.MethodPost, URL, strings.NewReader(data.Encode()))
	r.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	r.AddCookie(&cookie)

	client := &http.Client{}
	resp, err := client.Do(r)
	if err != nil {
		return "Error"
	}

	// s, err := io.ReadAll(resp.Body)
	// if err != nil {
	// 	return "Error READ"
	// }

	return resp.Status
}

func fetchCsrfTokenAndCookie() (string, http.Cookie) {
	var cookie = http.Cookie{}
	var token = ""

	r, _ := http.NewRequest(http.MethodGet, URL, nil)
	client := &http.Client{}
	resp, err := client.Do(r)
	if err != nil {
		panic(err)
	}

	doc, err := htmlquery.Parse(resp.Body)
	if err != nil {
		panic(err)
	}

	err = resp.Body.Close()
	if err != nil {
		return "", http.Cookie{}
	}

	for _, c := range resp.Cookies() {
		if c.Name == "PHPSESSID" {
			cookie = *c
		}
	}

	node := htmlquery.FindOne(doc, "//input[@id=\"form__token\"]")
	for _, attr := range node.Attr {
		if attr.Key == "value" {
			token = attr.Val
		}
	}

	return token, cookie
}
