#########################
#		 Sorter			#
#						#
#		Authors:		#
#     Kevin Vinther		#
#    Mikkel Asmussen  	#
#########################



.section .data
	errorMessage: 
		.string "Failed to open file. Did you put in a correct format?\n"
	fileSize:
		.space 8
	fileDescriptor:
		.space 8
	buffer:
		.space 8
	parsedBuffer: 
		.space 8
	lineCount: 
		.space 8
.section .text
.globl _start

_start:
	# Get filename and open file
	movq %rsp, %rbp
	
	# Move stack pointer to rbp
	movq 16(%rbp), %rdi 	# Get filename and put it in rdi 

	# Read the file
	movq $2, %rax			# Open syscall
	movq $0, %rsi 			# no flags
	movq $0666, %rdx 		# set mode to 0666 so file is opened for reading and writing for all users
	syscall					# syscall

	# check if the file exists 
	cmpq $0, %rax			# if it returns error
	jl print_error			# jump to error

	# move file descriptor to rdi (for file size) and var fileDescriptor	
	movq %rax, %rdi
	movq %rax, fileDescriptor

	# get file size
	call getFileSize		# get filesize
	movq %rax, fileSize 	# put filesize in fileSize

	# allocate fileSize to buffer
	movq fileSize, %rdi
	call allocate		
	movq %rax, buffer		# save address to buffer


	# Read
	movq fileDescriptor, %rdi 	# what should we read
	movq $0, %rax				# read
	movq buffer, %rsi 			# buffer
	movq fileSize, %rdx 		# how much to read
	syscall 					# call! 


	# close file
	movq $3, %rax				# close the file
	movq fileDescriptor, %rdi	# close filedescriptor
	syscall

	# give us a reference 
	#addq $fileSize, fileSize
	movq fileSize, %rdi
	call allocate		
	movq %rax, parsedBuffer

	# get number of lines
	movq buffer, %rdi	
	movq fileSize, %rsi		
	call getLineCount


	# Allocate space for parsedBuffer
	movq %rax, lineCount		# get number of lines into lineCount
	imul $16, lineCount, %rdi 	# 2 numbers, each 8 byte
	call allocate				# allocate
	movq %rax, parsedBuffer		# put into parsed buffer


	# parse data to number
	movq buffer, %rdi
	movq fileSize, %rsi
	movq parsedBuffer, %rdx
	call parseData


# TODO: Remove when donem
# TODO: take shower
insertSort: 
	########################
	# Begin Insertion Sort #
	########################

	movq lineCount, %rax	# put linecount in rax register
	cmpq $1, %rax			# if the linecount is <1
	jle printLoop			# exit, the list is already sorted


	movq $2, %r13					# r13 = 2, skip first line
	imul $2, lineCount, %rax		# rax = 2 * lineCount

	movq parsedBuffer, %r12		# r12 = parsedBuffer 
	
outerLoop:
	cmpq %rax, %r13		# If the current line == number of lines
	je printLoopBegin	# Then print

	movq %r13, %rdi		# rdi = r13, temporary counter
	
innerLoop:
	cmpq %rdi, %rax
	je outerLoop

	movq %rdi, %rbp		# rbp = rdi, temporary counter 2  
	subq $2, %rbp		# rbp -= 2 

	movq 8(%r12, %rbp, 8), %r14	# r14 = the rbp y-value, y[rbp]
	cmpq 8(%r12, %rdi, 8), %r14	# if y[rdi] < y[rbp]
	jl outerLoopEnd				# 	then jump to outerLoopEnd
	
	movq 8(%r12, %rdi, 8), %r15	# r15 = the rdi 
	movq (%r12, %rdi, 8), %r8
	movq (%r12, %rbp, 8), %r9

	# swap the x values
	movq %r9, (%r12, %rdi, 8)
	movq %r8, (%r12, %rbp, 8)
	# swap the y values
	movq %r15, 8(%r12, %rbp, 8)
	movq %r14, 8(%r12, %rdi, 8)

	subq $2, %rdi
	jmp innerLoop

outerLoopEnd:
	addq $2, %r13
	jmp outerLoop
printLoopBegin:
	xor %r13, %r13				# r13 = 0
	imul $2, lineCount, %rax
	movq parsedBuffer, %r12		# r12 = parsedBuffer
printLoop:
	movq (%r12, %r13, 8), %r10	# r10 = r12[r13*8] 
	movq %r10, %rdi				# rdi = r10
	call printNumTab

	movq 8(%r12, %r13, 8), %r10	# r10 = r12[r13*8] 
	movq %r10, %rdi				# rdi = r10

	addq $2, %r13				# r13 += 2
	call printNum				# print(rdi) 
	cmpq %rax, %r13				# rdi == 0
	je exit						# if rdi == 0 { exit }
	jmp printLoop
exit:
	movq $60, %rax
	movq $0, %rdi
	syscall
print_error:
	movq $errorMessage, %rdi
	call printError
	jmp exit
	