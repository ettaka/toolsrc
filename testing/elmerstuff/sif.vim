
function! AddToSet(set_list, element)
	if index(a:set_list,a:element)==-1
		call add(a:set_list, a:element)
	endif
endfunction

function! ListToString(set_list)
	let string=''
	for word in a:set_list
		let string=string . ' "' . word . '"'
	endfor
	return string
endfunction

if exists("b:current_syntax")
	finish
end

let filecontents=readfile("SOLVER.KEYWORDS")
let sif_lists=[]
let sif_keys=[]
let sif_types=[]
for line in filecontents
	if line=~'^[A-Za-z].*' 
		let llist=split(line,':')	
		if len(llist)==3
			call AddToSet(sif_lists, tolower(llist[0]))
			call AddToSet(sif_types, tolower(llist[1]))
			let tmp_key=split(llist[2],"\'")
			call AddToSet(sif_keys, tolower(tmp_key[1]))
		endif
	endif 
endfor

for sif_key in sif_keys
	execute ('syntax match sifKeyword "\c' . sif_key . '.*="')
endfor

for sif_list in sif_lists
	execute ('syntax match sifList "\c' . sif_list . '"')
endfor

for sif_type in sif_types
	execute ('syntax match sifType "\c' . sif_type . '"')
endfor

syntax match sifInteger "[0-9]*\s\+"
syntax region sifString start=/\v"/ skip=/\v\\./ end=/\v"/
syntax match sifComment "\v!.*$"

highlight link sifString String
highlight link sifKeyword Keyword
highlight link sifList Structure
highlight link sifComment Comment
highlight link sifType Type 
" highlight link sifInteger Number

let b:current_syntax = "sif"


