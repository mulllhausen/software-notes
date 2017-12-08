" place this file at ~/ and vim will read it automatically

" All system-wide defaults are set in $VIMRUNTIME/debian.vim (usually just
" /usr/share/vim/vimcurrent/debian.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vim/vimrc), since debian.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing debian.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the
" following enables syntax highlighting by default.
if has("syntax")
	syntax on
	autocmd BufEnter * :syntax sync fromstart
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
"if has("autocmd")
"  filetype plugin indent on
"endif

" solid cursor
let &t_EI .= "\<Esc>[2 q"

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
"set showcmd " Show (partial) command in status line.
"set showmatch " Show matching brackets.
set ignorecase " Do case insensitive matching
"set smartcase " Do smart case matching
"set incsearch " Incremental search
"set autowrite " Automatically save before commands like :next and :make
"set hidden " Hide buffers when they are abandoned
"set mouse=a " Enable mouse usage (all modes)
set nostartofline " leave my cursor position alone!
set nobackup
set noswapfile
set nowritebackup
set sw=4
set tabstop=4
set expandtab

" put a white line down column 79 (first column is 1)
set colorcolumn=80
highlight colorcolumn ctermbg=7

let php_htmlInStrings=1
set guicursor=a:blinkon0 " disable cursor blinking (this may be handled by the terminal already)
"if &term =~ "linux\\|screen.linux" " disable cursor blinking in linux terminal (tty)
  set t_ve+=[?16;13;32c " see ~./pretty_bash_prompt for a translation of these numbers
"endif

" use 256 colors
set t_Co=256

" map control-a to mu
set encoding=utf-8
imap <C-a> <C-k>m*

" when in diff mode expand all lines out
if &diff
  set diffopt=filler,context:100000000
endif

" copy to clipboard. run $(apt-get install vim-gui-common) for this to work and
" run $(vim --version | grep +xterm_clipboard) to see if its installed
set clipboard=unnamedplus

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
	source /etc/vim/vimrc.local
endif
