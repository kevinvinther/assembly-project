#########################
#	 Sorter		#
#			#
#	Authors:	#
#     Kevin Vinther	#
#    Mikkel Asmussen  	#
#########################



.section .data
	errorMessage: 
		.string "Failed to open file. Did you put in a correct format?\n"
	fileName:
		.space 8
	fileSize:
		.space 8
	fileDescriptor:
		.space 8
	buffer:
		.space 8
.section .text
.globl _start

_start:
	# Get filename and open file
	movq %rsp, %rbp		# Move stack pointer to rbp
	movq 16(%rbp), %rdi 	# Get filename and put it in rdi 

	# Read the file
	movq $2, %rax		# Open syscall
	movq $0, %rsi 		# no flags
	movq $0666, %rdx 	# set mode to 0666 so file is opened for reading and writing for all users
	syscall			# syscall

	# check if the file exists 
	cmpq $0, %rax		# if it returns error
	jl print_error		# jump to error

	# move file descriptor to rdi (for file size) and var fileDescriptor	
	movq %rax, %rdi
	movq %rax, fileDescriptor

	# get file size
	call getFileSize	# get filesize
	movq %rax, fileSize 	# put filesize in fileSize

	# allocate fileSize to buffer
	movq fileSize, %rdi
	call allocate		
	movq %rax, buffer	# save pointer to buffer

	# Read
	movq fileDescriptor, %rdi 	# what should we read
	movq $0, %rax			# read
	movq buffer, %rsi 		# buffer
	movq fileSize, %rdx 		# how much to read
	syscall 			# call! 

	# print
	movq $1, %rdi 		
	movq buffer, %rsi
	movq fileSize, %rdx
	movq $1, %rax
	syscall

	# close file
	movq $3, %rax			# close the file
	movq fileDescriptor, %rdi	# close filedescriptor
	syscall


exit:
	movq $60, %rax
	movq $0, %rdi
	syscall

print_error:
	movq $errorMessage, %rdi
	call printString
	jmp exit
