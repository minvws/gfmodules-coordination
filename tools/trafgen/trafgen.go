package main

import (
<<<<<<< Updated upstream
=======
	"flag"
	"math"
>>>>>>> Stashed changes
	"math/rand"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/antchfx/htmlquery"
)

const (
	URL         = "https://pgodemo.test.zm.irealisatie.nl/"
	ThreadCount = 15
	MinDelay    = 5
	MaxDelay    = 30
)

func main() {
<<<<<<< Updated upstream
	for i := 0; i < ThreadCount; i++ {
		var threadId = i
		go func() {
			trafgen(threadId)
=======
	threads := flag.Int("threads", 0, "Number of go routines to use")
	minDelay := flag.Int("min-delay", 10, "Minimum delay in seconds")
	maxDelay := flag.Int("max-delay", 30, "Maximum delay in seconds")
	endpoint := flag.String("endpoint", URL, "URL endpoint to send requests to")
	minBsn := flag.Int("min-bsn", 950000000, "Minimum BSN number")
	maxBsn := flag.Int("max-bsn", 950001000, "Maximum BSN number")

	// Parse command-line arguments
	flag.Parse()

	if *threads <= 0 {
		println("Usage: trafgen -threads <number of threads> -min-delay <min delay> -max-delay <max delay> -endpoint <url> -min-bsn <min bsn> -max-bsn <max bsn>")
		return
	}

	for i := 0; i < *threads; i++ {
		var threadId = i
		go func() {
			trafgen(threadId, *endpoint, *minDelay, *maxDelay, *minBsn, *maxBsn)
>>>>>>> Stashed changes
		}()
	}

	for {
	}
}

<<<<<<< Updated upstream
func trafgen(threadNr int) {
	// Delay first request
	delay := time.Duration(rand.Intn(MaxDelay-MinDelay)+MinDelay) / 2
	println("Thread", threadNr, "Delay:", delay)
	time.Sleep(delay * time.Second)
=======
func trafgen(threadNr int, endpoint string, minDelay, maxDelay, minBsn, maxBsn int) {
	if maxDelay-minDelay > 0 {
		// Delay first request
		delay := time.Duration(rand.Intn(maxDelay-minDelay)+minDelay) / 2
		println("Thread", threadNr, "Delay:", delay)
		time.Sleep(delay * time.Second)
	}
>>>>>>> Stashed changes

	for {
		token, cookie := fetchCsrfTokenAndCookie()
		time.Sleep(1 * time.Second)

<<<<<<< Updated upstream
		status := submitForm("950000012", "beeldbank", token, cookie)
		delay := time.Duration(rand.Intn(MaxDelay-MinDelay) + MinDelay)
=======
		// Generate random BSN number
		bsn := generate_bsn(minBsn, maxBsn)
		status := submitForm(endpoint, bsn, "beeldbank", token, cookie)

		delay := 0 * time.Second
		if maxDelay-minDelay > 0 {
			delay = time.Duration(rand.Intn(maxDelay-minDelay) + minDelay)
		}
>>>>>>> Stashed changes

		println("Thread", threadNr, "Status:", status, "Delay:", delay)

		time.Sleep(delay * time.Second)
	}
}

<<<<<<< Updated upstream
func submitForm(bsn, dataDomain, token string, cookie http.Cookie) string {
	println("Submitting form with BSN:", bsn, "Data domain:", dataDomain, "Token:", token, "Cookie:", cookie.Raw)
=======
func intPow(base, exp int) int {
	return int(math.Pow(float64(base), float64(exp)))
}

func valid_bsn(bsn int) bool {
	if bsn < 100000000 || bsn > 999999999 {
		return false
	}

	// Calculate BSN check digit
	weights := []int{9, 8, 7, 6, 5, 4, 3, 2, -1}
	sum := 0
	for i, w := range weights {
		sum += w * (bsn / intPow(10, 8-i))
	}

	return sum%11 == 0
}

func generate_bsn(min int, max int) string {
	bsn := rand.Intn(max-min) + min
	for !valid_bsn(bsn) {
		bsn += 1
	}

	return strconv.Itoa(bsn)
}

func submitForm(endpoint, bsn, dataDomain, token string, cookie http.Cookie) string {
	println("Submitting form with BSN:", bsn, "Data domain:", dataDomain, "Token:", token[0:20], "Cookie:", cookie.Raw)
>>>>>>> Stashed changes

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
