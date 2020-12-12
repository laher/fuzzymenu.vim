package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"

	"github.com/jessevdk/go-flags"
)

type Options struct {
	// Example of verbosity with level
	Verbose []bool `short:"v" long:"verbose" description:"Verbose output"`
	Piper   string `long:"piper" description:"pipe output through an external command" default:"bat"`
}

func Piper(piper string, args []string) (func() error, io.WriteCloser, error) {
	if piper != "" {
		cmd := exec.Command(piper, args...)
		p, err := cmd.StdinPipe()
		if err != nil {
			return nil, nil, err
		}
		cmd.Stdout = os.Stdout
		err = cmd.Start()
		return cmd.Wait, p, err
	}
	return func() error { return nil }, os.Stdout, nil
	// return nil, errors.New("not implemented")
}

var (
	bold      = termEsc("\u001b[1m%s\u001b[0m")
	underline = termEsc("\u001b[4m%s\u001b[0m")
	reverse   = termEsc("\u001b[7m%s\u001b[0m")
	black     = termEsc("\033[1;30m%s\033[0m")
	red       = termEsc("\033[1;31m%s\033[0m")
	green     = termEsc("\033[1;32m%s\033[0m")
	yellow    = termEsc("\033[1;33m%s\033[0m")
	purple    = termEsc("\033[1;34m%s\033[0m")
	magenta   = termEsc("\033[1;35m%s\033[0m")
	teal      = termEsc("\033[1;36m%s\033[0m")
	white     = termEsc("\033[1;37m%s\033[0m")
)

func termEsc(colorString string) func(string, ...interface{}) string {
	sprint := func(t string, args ...interface{}) string {
		return fmt.Sprintf(colorString,
			fmt.Sprintf(t, args...))
	}
	return sprint
}

type CfgCmd struct {
	options *Options
}

func (c *CfgCmd) Execute(args []string) error {
	fmt.Printf("Options: %+v\n", c.options)
	return nil
}

func main() {
	var (
		options    = &Options{}
		parser     = flags.NewParser(options, flags.Default)
		vimHelpCmd = &VimHelpCmd{options: options}
		cliHelp    = &CliHelpCmd{options: options}
		cfgCmd     = &CfgCmd{options: options}
	)
	parser.AddCommand("vim:help", "preview a vim help entry", "show vim:help", vimHelpCmd)
	parser.AddCommand("cli:help", "show manpage/help for a CLI command", "preview help for a command", cliHelp)
	parser.AddCommand("config", "show config", "show config", cfgCmd)

	if _, err := parser.Parse(); err != nil {
		switch flagsErr := err.(type) {
		case *flags.Error:
			if flagsErr.Type == flags.ErrHelp {
				os.Exit(0)
			}
			os.Exit(1)
		default:
			os.Exit(1)
		}
	}
}
