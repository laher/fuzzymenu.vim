package main

import (
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/jessevdk/go-flags"
)

type Options struct {
	// Example of verbosity with level
	Verbose []bool `short:"v" long:"verbose" description:"Verbose output"`
	Piper   string `long:"piper" description:"pipe output through an external command" default:"bat"`
}

type VimHelpCmd struct {
	options     *Options
	Piper       string `long:"piper" description:"pipe output through an external command" default:""`
	RuntimePath string `short:"r" long:"vimruntime" description:"path of runtime" default:"/usr/share/vim/vim82"`
	PluginBase  string `long:"pluginbase" description:"path where plugins are installed"`
	MaxLines    int    `short:"l" long:"max-lines" description:"most lines to display" default:"20"`
	Format      int    `short:"f" long:"format" description:"format of incoming data. 0=key-only,1=fuzzymenu-style"`
	Key         string `short:"k" long:"key" description:"Key of help item" required:"yes"`
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

func (c *VimHelpCmd) Execute(args []string) error {
	piper := c.Piper
	pargs := []string{}
	if piper == "vimless" {
		piper = "vim"
		conf := filepath.Join(c.RuntimePath, "macros", "less.vim")
		pargs = []string{"-u", conf}
	} else if piper == "bat" {
		pargs = []string{"--style", "plain"}
	}
	waiter, out, err := Piper(piper, pargs)
	if err != nil {
		return err
	}
	k := c.Key
	switch c.Format {
	case 1:
		// from fuzzymenu (or similar)
		// format is:
		// `description-plus-tags`
		// `tab-plus-space`
		// `command`
		re := regexp.MustCompile(`\t\s*`)
		parts := re.Split(k, 2)
		if len(parts) > 1 {
			k = parts[1]
		}
		// todo: format tags?
		fmt.Fprintln(out, reverse(parts[0]))
		prefs := map[string]string{"normal: ": "Normal Mode command", "visual: ": "Visual mode command", ":set ": "Set a variable", ":call ": "Call a function", ":": "Ex mode command"}
		for pref, desc := range prefs {
			if strings.HasPrefix(k, pref) {
				k = k[len(pref):]
				fmt.Fprintf(out, "%s:\n", desc)
				break
			}
		}
		fmt.Fprintln(out, green("%s\n", parts[1]))
	default:
		fmt.Fprintln(out, green("%s\n", k))
	}
	// bang isn't usually part of the key
	if strings.HasSuffix(k, "!") {
		k = k[:len(k)-1]
	}
	u, err := user.Current()
	homeDir := "~"
	if err == nil {
		homeDir = u.HomeDir
	}
	docDirs := []string{
		filepath.Join(c.RuntimePath, "doc"),
		// ~todo (see below)~ load from runtimepath. Some test ones for now
		// filepath.Join(homeDir, ".vim", "plugged", "fzf", "doc"),
		// filepath.Join(homeDir, ".vim", "plugged", "fzf.vim", "doc"),
		// filepath.Join(homeDir, ".vim", "plugged", "vim-go", "doc"),
		// filepath.Join(homeDir, ".vim", "plugged", "coc.nvim", "doc"),
	}
	if c.PluginBase != "" {
		gl := c.PluginBase + "/*/doc"
		if strings.HasPrefix(gl, "~") {
			gl = homeDir + gl[1:]
		}
		matches, err := filepath.Glob(gl)
		if err != nil {
			// fmt.Println("glob error ", err)
			// skip plugins
		} else {
			docDirs = append(docDirs, matches...)
		}
	}
	for _, docDir := range docDirs {
		tagsFile := filepath.Join(docDir, "tags")
		if _, err := os.Stat(tagsFile); err != nil {
			continue // ignore missing help files
		}
		// use the tags file...
		b, err := ioutil.ReadFile(tagsFile)
		if err != nil {
			return err
		}
		lines := strings.Split(string(b), "\n")
		type match struct {
			key    string
			file   string
			lookup string
		}
		matches := [][]match{{}, {}, {}}
		for _, l := range lines {
			parts := strings.Split(l, "\t")
			if len(parts) == 3 {
				m := match{key: parts[0], file: parts[1], lookup: parts[2]}
				if m.key == k || m.key == "<"+k+">" {
					matches[0] = append(matches[0], m)
				} else if strings.HasPrefix(m.key, k) || strings.HasPrefix(m.key, "<"+k) {
					matches[1] = append(matches[1], m)
				} else if strings.Contains(m.key, k) {
					matches[2] = append(matches[2], m)
				}
			}
		}
		for i, s := range matches {
			for _, m := range s {
				b, err := ioutil.ReadFile(filepath.Join(docDir, m.file))
				if err != nil {
					return err
				}
				text := string(b)
				index := strings.Index(text, m.lookup[1:])
				if index < 0 {
					return errors.New(m.lookup + " not found")
				}
				lines = strings.Split(text[index:], "\n")
				if len(lines) > c.MaxLines {
					lines = lines[:c.MaxLines]
				}
				br := ""
				if i > 0 {
					br = " (inexact match)"
				}
				fmt.Fprintf(out, "Vim help%s:\n", br)
				fmt.Fprintln(out, bold(lines[0]))
				fmt.Fprintln(out, strings.Join(lines[1:], "\n"))
				return waiter()
			}
		}
	}
	// TODO: check runtimepath segments for 'doc' files
	fmt.Fprintln(out, "no 'help' found")
	return nil
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

type VimToplevel struct {
	options *Options
	Key     string `short:"k" long:"key" description:"Key of item" required:"yes"`
}

func (c *VimToplevel) Execute(args []string) error {
	if info, ok := topLevel[c.Key]; ok {
		lines := strings.Split(info.preview, "\n")
		fmt.Printf("\u001b[1m\u001b[7m%s\u001b[0m\n", c.Key)
		fmt.Printf("\u001b[1m%s\u001b[0m\n", lines[0])
		fmt.Println(strings.Join(lines[1:], "\n"))
	}
	/*
			for k, _ := range topLevel {
				fmt.Println(k)
			}
		default:
		}
		return nil
	*/
	return nil
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

type cmdInfo struct {
	preview string
}

var topLevel = map[string]cmdInfo{"text objects": cmdInfo{
	preview: `Do the stuffs with the text objects

 * The Operators
 * The Motions and Text Objects
 * The Niceness`,
}, "configuration": cmdInfo{
	preview: `Learning about configuration

 * The doing the config
 * The writing the config`,
}, "All-the-Things": cmdInfo{
	preview: `A big old fuzzy menu of goodness

 * FZF functionality
 * Lots of helpers
 * IDE-like stuffs`,
}}
