SRC = web.asm
run:
	@fasm $(SRC) && strace ./web