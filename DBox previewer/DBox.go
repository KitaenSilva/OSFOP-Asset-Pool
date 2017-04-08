package main

import (
	"fmt"
	"github.com/skratchdot/open-golang/open"
	"log"
	"net/http"
	"strings"
)

func main() {
	open.Start("http://localhost:9001")
	server()
}

func server() {
	http.HandleFunc("/p/", process)
	http.HandleFunc("/", http.FileServer(http.Dir("data")).ServeHTTP)
	log.Fatal(http.ListenAndServe(":9001", nil))
}

func process(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	fmt.Println(r.Form)
	act := r.Form.Get("action")
	data := r.Form.Get("text")
	if act == "compile" {
		w.Write([]byte(parse(data)))
	}
}

var replacewith = map[string]string{
	"***": "\\fb\\fi",
	"**":  "\\fb",
	"*":   "\\fi",
	"___": "\\fb\\fi",
	"__":  "\\fb",
	"_":   "\\fi",
}

func parse(s string) string {
	rw := []string{"***", "**","*","___","__","_"}
	var TEMP = s

	for _, replace := range rw {
		with := replacewith[replace]
		tmp := strings.Split(s, replace)
		fmt.Println(replace, with, tmp)
		if len(tmp) > 2 {
			var n = 1
			for {
				TEMP = strings.Replace(TEMP, replace+tmp[n]+replace, with+tmp[n]+with, -1)
				n += 1
				if len(tmp) < n+1 {
					break
				}
			}
		}
	}

	return TEMP
}
