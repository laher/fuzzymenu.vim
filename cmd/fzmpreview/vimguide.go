package main

import (
	"fmt"
	"strings"
)

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
