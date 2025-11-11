{ lib, config, ... }:

lib.mkIf config.me.wm.enable {
  hj.xdg.config.files."ideavim/ideavimrc".text = # vim
    ''
      set scrolloff=8
      set incsearch
      set hlsearch
      set noshowmode
      set number
      set relativenumber
      set iskeyword-=_
      set notimeout
      set nottimeout

      let mapleader = " "
      let g:highlightedyank_highlight_duration = "150"

      " Don't use Ex mode, use Q for formatting.
      map Q gq

      map <c-w>q <Action>(CloseContent)
      map <c-y> :NERDTreeToggle<CR>

      imap <c-y> <Action>(EditorChooseLookupItem)
      imap <c-e> <Action>(EditorEscape)

      map <leader>a <Action>(AddToHarpoon)
      map <c-e> <Action>(ShowHarpoon)

      map gl <Action>(ShowHoverInfo)
      map [d <Action>(GotoPreviousError)
      map ]d <Action>(GotoNextError)
      map gi <Action>(GotoImplementation)
      map gD <Action>(GotoSuperMethod)

      map gn <Action>(FindUsages)
      map <leader>cr <Action>(RenameElement)
      map <leader>ca <Action>(ShowIntentionActions)

      map <leader>pf <Action>(GotoFile)
      map <leader>ps <Action>(GotoSymbol)
      map <leader>pg <Action>(TextSearchAction)
      map <leader>pp <Action>(SearchEverywhere)

      map <leader>t <Action>(ActivateProblemsViewToolWindow)
      map <leader>rp <Action>(Run)
      map <leader>rt <Action>(RunClass)
      map <leader>dr <Action>(Debug)
      map <leader>db <Action>(ToggleLineBreakpoint)
      map <leader>s <Action>(Stop)

      map <leader>ff <Action>(ReformatCode)
      map <leader>fi <Action>(Generate)
      map <leader>fa <Action>(CodeFormatGroup)

      xmap s V
      map s V

      map gp `[v`]
      map + "+

      map U <c-r>
      xmap > >gv
      xmap < <gv
      xmap gb <Action>(CommentByBlockComment)

      xmap H ^
      map H ^
      xmap L $
      map L $

      vmap <space> <nop>
      map <space> <nop>

      map <S-Tab> <C-^>

      map ! :!

      xmap J :m '>+1<CR>gv=gv
      xmap K :m '<-2<CR>gv=gv

      map <ESC> :nohlsearch<CR>

      cnoremap <silent><expr> <enter> index(['/', '?'], getcmdtype()) >= 0 ? '<enter>zz' : '<enter>'

      map n nzz
      map N Nzz
      map * *zz
      map # #zz
      map <C-o> <Action>(Back)zz
      map <C-i> <Action>(Forward)zz
      map <C-d> <C-d>zz
      map <C-u> <C-u>zz
      map <C-f> <C-f>zz
      map <C-b> <C-b>zz
      map { {zz
      map } }zz
      map G Gzz

      " --- Enable IdeaVim plugins https://jb.gg/ideavim-plugins

      Plug '<plugin-github-reference>'

      Plug 'machakann/vim-highlightedyank'
      Plug 'tpope/vim-commentary'
      Plug 'tpope/vim-surround'
      Plug 'vim-scripts/ReplaceWithRegister'
      Plug 'preservim/nerdtree'
      Plug 'michaeljsmith/vim-indent-object'

      Plug 'chaoren/vim-wordmotion'
    '';
}
