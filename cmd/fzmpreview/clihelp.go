package main

import (
	"fmt"
	"os/exec"
)

type CliHelpCmd struct {
	options *Options
	Key     string `short:"k" long:"key" description:"Key of item" required:"yes"`
}

func (c *CliHelpCmd) Execute(args []string) error {
	cmd := exec.Command("man", c.Key)
	pargs := []string{}
	if c.options.Piper == "bat" {
		pargs = []string{"--language", "man", "--style", "plain"}
	}
	waiter, out, err := Piper(c.options.Piper, pargs)
	if err != nil {
		return err
	}
	fmt.Fprintf(out, "Show: key=%v\n", c.Key)
	fmt.Fprintf(out, "\u001b[1m\u001b[7m%s\u001b[0m\n", c.Key)
	cmd.Stdout = out
	//cmd.Stdout = os.Stdout
	if err := cmd.Run(); err != nil {
		//out.Close()

		pargs := []string{}
		if c.options.Piper == "bat" {
			pargs = []string{"--style", "plain"}
		}
		waiter, out, err := Piper(c.options.Piper, pargs) // not a man page
		if err != nil {
			return err
		}
		/*
			if cmd := exec.Command("which", os.Args[2]); true {
				cmd.Stdout = os.Stdout
				if err := cmd.Run(); err != nil {
					panic(err)
				}
			}
		*/

		cmd := exec.Command(c.Key, "--help")
		// reset
		cmd.Stdout = out
		cmd.Stderr = out
		//cmd.Stdout = os.Stdout
		if err := cmd.Run(); err != nil {
			/*
				fmt.Fprintf(out, "No help found for %s\n", c.Key)
				lines := strings.Split(b2.String(), "\n")
				fmt.Frintf(out, "\u001b[1m%s\u001b[0m\n", lines[0])
				fmt.Fprintln(out, strings.Join(lines[1:], "\n"))
			*/
			return err
		}
		return waiter()
	}
	//lines := strings.Split(b.String(), "\n")
	//fmt.Fprintf(out, "\u001b[1m%s\u001b[0m\n", lines[0])
	//fmt.Fprintln(out, strings.Join(lines[1:], "\n"))
	return waiter()
}
