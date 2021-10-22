################################
#           utils.s             #
#                               #
# printNum:                     #
#   Prints %rdi                 #
#				#
# printString: 			#
#    Prints string from %rdi    #
#				#
# allocate:                     #
#   Takes %rdi number of bytes  #
#   and puts to memory in %rax  #
#                               #
# getFileSize:                  #
#   get file size in bytes      #
#                               #
# getLineCount:                 #
#   gets number of lines        #
#                               #
# parseData:                    #
#   convert ascii to numbers    #
#                               #
#################################

#################################
#          printNum             #
#################################
.globl printNum			# void printNum(int n, int fileSize)
# Pre: n >= 0
.type printNum, @function
printNum:
	movq %rsi, %rdx # put file size into count
	#movq %rdi, %rsi # put argument in buffer
	movq $1, %rax	# write
	movq $1, %rdi	# no error
	syscall
	ret

#################################
#          printString          #
#################################
.globl printString
.type printString, @function
printString:		# Start 
	movq $-1, %rdx  # int rdx = -1 
	movq $0, %rcx	# int rcx = 0 

loop1:	# Find length of string; how many bytes to print. 
	addq $1, %rdx		# rdx += 1
	movq %rdi, %rsi		# string rsi = hello
	movb (%rsi, %rcx), %bl	# put byte rsi[rcx] into bl
	addq $1, %rcx		# rcx += 1
	cmpq $0, %rbx		# if rbx != 0 (last, null-byte, end of string)
	jne loop1		# 	jmp loop1

	movq $1, %rax		# rax = 1; write system call
	movq $1, %rdi		# rdi = 1; non-error write 
	syscall			# write %rsi


#################################
#          allocate             #
#################################

# void *allocate(int n)
#
# 	A naive memory allocator that simply retrieves some new space from the OS.
# 	It is not possible to deallocate the memory again.
.globl allocate
.type allocate, @function
allocate:
	push %rdi
	# 1. Find the current end of the data segment.
	movq $12, %rax # brk
	xorq %rdi, %rdi # 0 means we retrieve the current end.
	syscall
	# 2. Add the amount of memory we want to allocate.
	pop %rdi # the argument
	push %rax # current end, which is where the allocated memory will start
	addq %rax, %rdi # compute the new end
	movq $12, %rax # brk
	syscall
	pop %rax # the old end, which is the address of our allocated memory
	ret


#################################
#          getFileSize          #
#################################
# int getFileSize(int fd)
#
# 	Returns the size (in bytes) of the file indicated by the file descriptor.
.section .data
.Lstat: .space 144 # size of the fstat struct
.section .text
.globl getFileSize
.type getFileSize, @function
getFileSize:
	movq $5, %rax # fstat
	# rdi already contains the fd
	movq $.Lstat, %rsi # buffer to write fstat data into
	syscall
	movq $.Lstat, %rax
	movq 48(%rax), %rax # position of size in the struct
	ret


#################################
#          getLineCount         #
#################################
# int getLineCount(const char *data, int size)
#
#	Returns the number of '\n' characters in the memory pointed to.
#	'data': the address of the first character to look at.
#	'size': the length of the memory area to scan through.
.globl getLineCount
.type getLinecount, @function
getLineCount:
	# rdi: 'data'
	# rsi: 'size'
	addq %rdi, %rsi         # make rsi the past-the-end pointer
	xorq %rax, %rax         # count = 0
.LgetLineCount_loop:
	cmpq %rdi, %rsi
	je .LgetLineCount_end   # if rdi == rsi: we are done
	movb (%rdi), %dl        # load the next byte
	addq $1, %rdi
	cmpb $0xA, %dl          # is it a newline char?
	jne .LgetLineCount_loop # if not, continue in the buffer
	addq $1, %rax           # completed a number
	jmp .LgetLineCount_loop
.LgetLineCount_end:
	ret


#################################
#          parseData            #
#################################

# void parseData(const char *data, int size, int *result)
#
#	Converts the ASCII representation of the coordinates into pairs of numbers.
#	'data': the address of the first character in the ASCII representation.
#	'size': the length of the ASCII representation.
#	'result': the address of a piece of memory big enough to hold the
#		coordinates. If there are n coordinates in the input, the 'result'
#		memory will be an array of 2n 8-byte integers, with alternating x and y
#		coordinates.
#
#	Note, this functions only expects unsigned ints in the input and does not
#	perform any validity checks at all.
.globl parseData
.type parseData, @function
parseData:
	addq %rdi, %rsi # make rsi the past-the-end pointer
	push %rsi       # and store it as the top element on the stack
.LparseData_coordinateLoop:
	cmpq (%rsp), %rdi
	je .LparseData_coordinateLoop_end
	movq $9, %rsi      # '\t'
	call parseNumber   # increases rdi to point past-the-end of the number
	movq %rax, (%rdx)  # store the number
	addq $8, %rdx      # point to the next place for a number
	movq $10, %rsi     # '\n'
	call parseNumber   # increases rdi to point past-the-end of the number
	movq %rax, (%rdx)  # store the number
	addq $8, %rdx      # point to the next place for a number
	jmp .LparseData_coordinateLoop
.LparseData_coordinateLoop_end:
	addq $8, %rsp
	ret
 
# int parseNumber(const char *&data, const char *end)
parseNumber:
	xorq %rax, %rax    # result
.LparseNumber_loop:
	xorq %r10, %r10    # the next digit
	movb (%rdi), %r10b # read character
	addq $1, %rdi      # ++data
	cmpq %rsi, %r10    # done with this number?
	je .LparseNumber_loop_end
	# here we assume that the character is actually a digit
	# add this digit to the current number
	subq $48, %r10     # convert the ASCII code to the digit it represents
	imul $10, %rax     # 'make room' for the new digit
	addq %r10, %rax    # and add the new digit
	jmp .LparseNumber_loop
.LparseNumber_loop_end:
	# we now have a number in rax
	ret

.globl intFromString    # int intFromString(char *str)
# Pre: str != 0
# Pre: all characters in the string are one of 0123456789.
.type intFromString, @function
intFromString:
    xorq %rax, %rax
.LintFromString_loop:
    movzx (%rdi), %rsi # Move a single character/byte %rbx and zero-extend it.
    cmpq $0, %rsi # A string ends with a 0-byte.
    je .LintFromString_done
    movq $10, %rcx # Shift the number 1 decimal place to the left.
    mulq %rcx
    subq $48, %rsi # Convert from ASCII character to number. ASCII '0' has value 48. '1' is 49, etc.
    addq %rsi, %rax # Add the number.
    addq $1, %rdi
    jmp .LintFromString_loop
.LintFromString_done:
    ret
