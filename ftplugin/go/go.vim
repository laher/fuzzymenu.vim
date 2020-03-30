
if &rtp =~ 'gothx.vim'
  call fzm#add_item('Go: Run', 'call gothx#run#Run()')
  call fzm#add_item('Go: Test', 'call gothx#test#Test()')
  call fzm#add_item('Go: Keyify', 'call gothx#keyify#Keyify()')
endif

