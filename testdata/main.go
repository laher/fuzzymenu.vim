package main

import (
	"fmt"
	"io/ioutil"
)

type i interface {
	Do()
}

type anotherThing struct {
	a string
	b string
}

func (_ anotherThing) Do() {
	// nothing
}

func xfunc() error {
	var err error
	_ = err

	_ = anotherThing{}
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
