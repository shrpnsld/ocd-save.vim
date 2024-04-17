if exists('g:loaded_ocd_save')
	finish
else
	let g:loaded_ocd_save = v:true
endif

"
" Utils

function! s:ABuf()
	let abuf = expand('<abuf>')
	if abuf ==# ''
		let buffer_number = 0
	else
		let buffer_number = str2nr(abuf)
	end
	return buffer_number != 0 ? buffer_number : bufnr()
endfunction

function! s:HasEmptyName(buffer_number)
	return bufname(a:buffer_number) ==# ''
endfunction

function! s:IsReadOnly(buffer_number)
	return getbufvar(a:buffer_number, '&readonly')
endfunction

function! s:NotNormalBuffer(buffer_number)
	return getbufvar(a:buffer_number, '&buftype') !=# ''
endfunction

function! s:FileTypeIsGit(buffer_number)
	let file_type = getbufvar(a:buffer_number, '&filetype')
	return file_type ==# 'git' || file_type ==# 'gitconfig' || file_type ==# 'gitcommit' || file_type ==# 'gitrebase' || file_type ==# 'gitsendemail'
endfunction

function! s:BufferMatchesExcludeList(buffer_number, predicates)
	for Predicate in a:predicates
		if Predicate(a:buffer_number)
			return v:true
		endif
	endfor

	return v:false
endfunction

"
" Configuration

if !exists('g:ocd_save_exclude')
	let g:ocd_save_exclude = []
endif

if !exists('g:ocd_save_message')
	let g:ocd_save_message = ''
endif

if !exists('g:ocd_save_exclude_git')
	let g:ocd_save_exclude_git = v:true
endif

let g:ocd_save_exclude += [function('s:HasEmptyName'), function('s:NotNormalBuffer'), function('s:IsReadOnly')]

if g:ocd_save_exclude_git
	let g:ocd_save_exclude += [function('s:FileTypeIsGit')]
endif

"
" Plugin

function! s:AddBufferAutoCmds(buffer_number)
	if g:ocd_save_message == v:null
		let silent = ' silent'
		let	echo_saved = ''
	else
		if g:ocd_save_message == ''
			let silent = ''
			let	echo_saved = ''
		else
			let silent = ' silent'
			let	echo_saved = '| echo "'..g:ocd_save_message..'"'
		endif
	endif

	augroup OcdSave
		execute 'autocmd! TextChanged <buffer='..a:buffer_number..'> '..silent..' update'..echo_saved
		execute 'autocmd! InsertLeave <buffer='..a:buffer_number..'> '..silent..' update'..echo_saved
	augroup END
endfunction

function! s:RemoveBufferAutoCmds(buffer_number)
	augroup OcdSave
		execute 'autocmd! TextChanged <buffer='..a:buffer_number..'>'
		execute 'autocmd! InsertLeave <buffer='..a:buffer_number..'>'
	augroup END
endfunction

function! s:OnHere(buffer_number)
	if s:BufferMatchesExcludeList(a:buffer_number, g:ocd_save_exclude)
		return v:false
	endif

	call s:AddBufferAutoCmds(a:buffer_number)
	return v:true
endfunction

function! s:OffHere(buffer_number)
	call s:RemoveBufferAutoCmds(a:buffer_number)
endfunction

function! s:CheckAndToggleHere(buffer_number)
	if !s:BufferMatchesExcludeList(a:buffer_number, g:ocd_save_exclude)
		call s:AddBufferAutoCmds(a:buffer_number)
	else
		call s:RemoveBufferAutoCmds(a:buffer_number)
	endif
endfunction

function! s:On()
	augroup OcdSaveGlobal
		autocmd!
		autocmd BufAdd * call s:OnHere(s:ABuf())
		autocmd BufDelete * call s:OffHere(s:ABuf())
		autocmd OptionSet readonly,buftype call s:CheckAndToggleHere(s:ABuf())
		autocmd BufWritePost * call s:OnHere(s:ABuf())
	augroup END

	for info in getbufinfo()
		if info.listed
			call s:OnHere(info.bufnr)
		endif
	endfor
endfunction

function! s:Off()
	augroup OcdSaveGlobal
		autocmd!
	augroup END

	for info in getbufinfo()
		if info.listed
			call s:OffHere(info.bufnr)
		endif
	endfor
endfunction

"
" Commands

command! -nargs=0 -bar OcdSaveOnHere if ! <SID>OnHere(bufnr()) | echoerr 'ocd-save: can''t turn autosave on for '''..bufname(bufnr())..'''' | endif
command! -nargs=0 -bar OcdSaveOffHere call <SID>OffHere(bufnr())
command! -nargs=0 -bar OcdSaveOn call <SID>On()
command! -nargs=0 -bar OcdSaveOff call <SID>Off()

"
" Main

call s:On()

