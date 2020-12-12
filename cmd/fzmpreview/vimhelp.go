package main

import (
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"os/user"
	"path/filepath"
	"regexp"
	"strings"
)

type VimHelpCmd struct {
	options     *Options
	Piper       string `long:"piper" description:"pipe output through an external command" default:""`
	RuntimePath string `short:"r" long:"vimruntime" description:"path of runtime" default:"/usr/share/vim/vim82"`
	PluginBase  string `long:"pluginbase" description:"path where plugins are installed"`
	MaxLines    int    `short:"l" long:"max-lines" description:"most lines to display" default:"20"`
	Format      int    `short:"f" long:"format" description:"format of incoming data. 0=key-only,1=fuzzymenu-style"`
	Key         string `short:"k" long:"key" description:"Key of help item" required:"yes"`
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
