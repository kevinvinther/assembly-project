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
	fileName:
		.space 8
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
	movq %rsp, %rbp			# Move stack pointer to rbp
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


# TODO: Remove when done
# TODO: take shower
insertSort: 
	########################
	# Begin Insertion Sort #
	########################

	movq lineCount, %rax	# put linecount in rax register
	cmpq $1, %rax			# if the linecount is <1
	jle printLoop			# exit, the list is already sorted


	movq $2, %r13					# r13 = 2, skip first line
	imul $2, lineCount, %rax		# rax = 2*lineCount
sortLoop1:					# first loop

	movq parsedBuffer, %r12	# r12 = parsedBuffer 
	movq (%r12, %r13, 8), %r10	# x-coord in r10
	movq 8(%r12, %r13, 8), %r11	# y-coord in r11
	jmp sortLoop2

	cmpq %rax, %r13			# if all line have been read
	je printLoop			# print results
	inc %r13				# ++r13
	jmp sortLoop1			# loop

	
sortLoop2:
	
	subq $2, %r13, %rdi		# counter to decrement

	

	cmpq $0, %rdi	# if counter rdi is 0
	jz sortLoop1	# loop is done return to loop 1
	subq $2, %rdi	# sub 2 from counter
	jmp sortLoop2	# loop

	xor %r13, %r13				# r13 = 0
printLoop:
	movq parsedBuffer, %r12		# r12 = parsedBuffer
	movq (%r12, %r13, 8), %r10	# r10 = r12[r13*8] 
	movq %r10, %rdi				# rdi = r10
	addq $1, %r13				# r13 += 2
	cmpq $0, %rdi				# rdi == 0
	jz exit						# if rdi == 0 { exit }
	call printNum				# print(rdi) 
	jmp printLoop

exit:
	movq $60, %rax
	movq $0, %rdi
	syscall

print_error:
	movq $errorMessage, %rdi
	call printError
	jmp exit
