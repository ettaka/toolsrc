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

let filecontents=readfile("SOLVER.KEYWORDS")
let sif_lists=[]
let sif_keys=[]
let sif_types=[]
for line in filecontents
	if line=~'^[A-Za-z].*' 
		let llist=split(line,':')	
		if len(llist)==3
			call AddToSet(sif_lists, llist[0])
			call AddToSet(sif_types, llist[1])
			let tmp_key=split(llist[2],"\'")
			call AddToSet(sif_keys, tmp_key[1])
		endif
	endif 
endfor

echom 'SIF Lists:'
echom '----------'
echom ListToString(sif_lists)
echom '----------'
echom 'SIF Types:'
echom '----------'
echom ListToString(sif_types)
echom '----------'
echom 'SIF Keys:'
echom '----------'
echom ListToString(sif_keys)
