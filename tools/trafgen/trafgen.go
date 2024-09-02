package main

import (
	"flag"
	"math/rand"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/antchfx/htmlquery"
)

const (
	URL = "https://pgodemo.test.zm.irealisatie.nl/"
)

func main() {
	threads := flag.Int("threads", 0, "Number of go routines to use")
	minDelay := flag.Int("min-delay", 10, "Minimum delay in seconds")
	maxDelay := flag.Int("max-delay", 30, "Maximum delay in seconds")
	endpoint := flag.String("endpoint", URL, "URL endpoint to send requests to")

	// Parse command-line arguments
	flag.Parse()

	if *threads <= 0 {
		println("Usage: trafgen -threads <number of threads> -min-delay <min delay> -max-delay <max delay> -endpoint <url>")
		return
	}

	for i := 0; i < *threads; i++ {
		var threadId = i
		go func() {
			trafgen(threadId, *endpoint, *minDelay, *maxDelay)
		}()
	}

	for {
		time.Sleep(1 * time.Second)
	}
}

func trafgen(threadNr int, endpoint string, minDelay int, maxDelay int) {
	if maxDelay-minDelay > 0 {
		// Delay first request
		delay := time.Duration(rand.Intn(maxDelay-minDelay)+minDelay) / 2
		println("Thread", threadNr, "Delay:", delay)
		time.Sleep(delay * time.Second)
	}

	for {
		token, cookie := fetchCsrfTokenAndCookie(endpoint)
		time.Sleep(500 * time.Millisecond)
		if token == "" {
			println("Thread", threadNr, "Error fetching token")
			continue
		}

		status := submitForm(endpoint, "950000012", "beeldbank", token, cookie)

		delay := 0 * time.Second
		if maxDelay-minDelay > 0 {
			delay = time.Duration(rand.Intn(maxDelay-minDelay) + minDelay)
		}

		println("Thread", threadNr, "Status:", status, "Delay:", delay)

		time.Sleep(delay * time.Second)
	}
}

func submitForm(endpoint, bsn, dataDomain, token string, cookie http.Cookie) string {
	println("Submitting form with BSN:", bsn, "Data domain:", dataDomain, "Token:", token, "Cookie:", cookie.Raw)

	data := url.Values{}
	data.Set("form[bsn]", bsn)
	data.Set("form[data_domain]", dataDomain)
	data.Set("form[_token]", token)

	r, _ := http.NewRequest(http.MethodPost, endpoint, strings.NewReader(data.Encode()))
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

func fetchCsrfTokenAndCookie(endpoint string) (string, http.Cookie) {
	var cookie = http.Cookie{}
	var token = ""

	r, _ := http.NewRequest(http.MethodGet, endpoint, nil)
	client := &http.Client{}
	resp, err := client.Do(r)
	if err != nil {
		return "", http.Cookie{}
	}

	doc, err := htmlquery.Parse(resp.Body)
	if err != nil {
		return "", http.Cookie{}
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
