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
	countingBuffer:
		.space 8
	sortedBuffer:
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
	# addq $fileSize, fileSize
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
countingSort: 
	#########################
	# Begin Counting Sort 	#
	#########################

	movq lineCount, %rax	# put linecount in rax register
	cmpq $1, %rax			# if the linecount is <1
	jle printLoop			# exit, the list is already sorted


	movq parsedBuffer, %r12		# r12 = parsedBuffer 

	# We know that the maximum value of a coordinate (x or y) will be 32767, with 0 that is 32768
	# A number is 8 bytes, therefore we multiply it with 8
	movq $32768, %rdi
	imulq $8, %rdi, %rdi
	call allocate
	movq %rax, countingBuffer
	# put allocated space in countingBuffer

	movq $0, %rdi
	movq countingBuffer, %r10
# Set countingbuffer = 0
setZeroLoop:
	# use rdi as index
	movq $0, (%r10, %rdi)
	addq $1, %rdi	
	cmpq $32768, %rdi
	jl setZeroLoop


	# Start at 1, because we only want y-coordinates
	movq $1, %rdi
	movq parsedBuffer, %r11
	# parsedBuffer length = linecount*2	
	imulq $2, lineCount, %rax

storeNumCounter: # the counting array 
	# Put value of a number into r12
	movq (%r11, %rdi, 8), %r12 # Value of parsedBuffer[rdi]

	# Take r12 index of zero-array, i.e. zeroArray[r12*8] += 1
	addq $1, (%r10, %r12, 8)
	
	# add 2 because we only want y-coordinates
	addq $2, %rdi
	cmpq %rdi, %rax
	jg storeNumCounter

	# Start at index 1 
	movq $1, %rdi
getPositions: 
	movq -8(%r10, %rdi, 8), %r12	# counter[rdi-1]
	addq %r12, (%r10, %rdi, 8)

	addq $1, %rdi	
	cmpq $32768, %rdi
	jl getPositions

	movq %r10, countingBuffer

startSortBuffer:
	# Start at index 0
	# Allocate space for our sorted buffer
	movq lineCount, %rdi
	imulq $16, %rdi	# 2 numbers, each 8 bytes, 
	call allocate
	movq %rax, sortedBuffer
	
	

	movq $1, %rdi # Counter

	movq lineCount, %r8
	imulq $2, %r8
	movq parsedBuffer, %r11
	movq sortedBuffer, %r14

	movq countingBuffer, %r10
sortBuffer:
	movq (%r11, %rdi, 8), %r9

	movq (%r10, %r9, 8), %r13

	imulq $2, %r13 # r12 = r12*2

	movq %r9, 8(%r14, %r13, 8)		# y-coord in place

	

	subq $1, (%r10, %r9, 8)

	movq -8(%r11, %rdi, 8), %r9
	movq %r9, (%r14, %r13, 8)	# place x-val for y-coord

	addq $2, %rdi
	cmpq %rdi, %r8
	jg sortBuffer

	movq sortedBuffer, %r10

printLoopBegin:
	xor %r13, %r13				# r13 = 0
	imul $2, lineCount, %rax
	movq %r10, %r12		# r12 = parsedBuffer	
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
	
