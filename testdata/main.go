package main

import (
	"fmt"
	"io/ioutil"
)

type i interface {
	Do()
}

type helpThing struct {
	a string
	b string
}

func (_ helpThing) Do() {
	// nothing
}

func xfunc() error {
	var err error
	_ = err

	_ = helpThing{}
	return nil
}

func main() {

	type s struct {
		a string
	}
	_ = s{"b"}
	_ = s{}
	_, err := ioutil.ReadFile("x.txt")
	if err != nil {
		return
	}

	fmt.Println("oh-yeah")

}
