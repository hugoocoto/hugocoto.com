all:
	typst c --features html --format html ./index.typ 2>/dev/null || \
	typst c --features html --format html ./index.typ 
