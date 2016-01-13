.data

# input_file
input_file_name:	.asciiz "input.txt"
input_file_size:	.word 0
input_file_buffer:	.space 1024
input_file_buffer_size:	.word 1024

# output_file
output_file_name:	.asciiz "output.txt"

# misc
vowel_count:		.word 0

##
## int main(void)
## TODO: Parse input_file_name from commandline
## TODO: Parse output_file_name form commandline
## TODO: Check for signed/unsigned consistency
## TODO: Check if output in ASCII is required 
##
.text
.globl main
main:
	# Read input_file
	la	$a0, input_file_name
	la	$a1, input_file_buffer
	lw	$a2, input_file_buffer_size
	jal	f_read_input_file
	bgez	$v0, main_input_file_read
	# TODO: print error message
	li	$a0, -1			# Set return code of program
	j	main_return

main_input_file_read:
	la	$s0, input_file_size	# Store number of bytes read 
	sw	$v0, 0($s0)		

	# Count vowels in input_file_buffer
	la	$a0, input_file_buffer
	lw	$a1, input_file_size
	jal	f_count_vowels
	la	$a0, vowel_count	# Store result in memory
	sw	$v0, 0($a0)

	# Write output_file
	la	$a0, output_file_name
	la	$a1, vowel_count
	la	$a2, 4
	jal	f_write_output_file
	bgez	$v0, main_output_file_written
	# TODO: print error message
	li	$a0, -2			# Set return code of program
	j	main_return

main_output_file_written:
	li	$a0, 0			# Exit gracefully with return code 0

main_return:
	li	$v0, 17
	syscall

##
## int read_input_file(char *input_file_name, char *buffer, unsigned buffer_size)
## Leafnode function - https://en.wikipedia.org/wiki/Calling_convention#MIPS
## TODO: Add verbose description - MAYBE
##
f_read_input_file:

	move	$s0, $a1		# Save buffer
	move	$s1, $a2		# Save buffer_size
	li	$v0, 13			# Open input_file (syscall 13)
	li	$a1, 0			# Set flags=0: read-only
	li	$a2, 0			# Set mode=0: ignored
	syscall
	bltz	$v0, f_read_input_file_return	# Check if open succeeded
	move	$s2, $v0		# Save file descriptor
	li	$v0, 14			# Read input_file (syscall 14)
	move	$a0, $s2		# Restore file descriptor
	move 	$a1, $s0		# Restore buffer
	move	$a2, $s1		# restore buffer_size
	syscall
	move	$s3, $v0		# Save number of bytes read
	li	$v0, 16			# Close input_file (syscall 16)
	move	$a0, $s2		# Restore file descriptor
	syscall
	move	$v0, $s3		# Return numer of bytes read
f_read_input_file_return:
	jr	$ra

##
## unsigned count_vowels(char *buffer, unsigned buffer_size)
## Leafnode function - https://en.wikipedia.org/wiki/Calling_convention#MIPS
## TODO: Add verbose description - MAYBE
##
.data
vowels:		.byte 'A', 'a', 'E', 'e', 'I', 'i', 'O', 'o', 'U', 'u'
vowels_count:	.word 10

.text
f_count_vowels:
	li	$v0, 0			# Initialize return value
	blez	$a1, f_count_vowels_return 	# Check for zero and negative buffer_size
	addu	$s0, $a1, $a0		# Point to last character in buffer
	addiu	$s0, $s0, -1		# Prevent off-by-one
	la	$s2, vowels 		# Load address of reference buffer
	lw	$s3, vowels_count	# Load number of reference buffer elements
	add	$s4, $s3, $s2		# Point to last character in reference buffer
	addi	$s4, $s4, -1		# Prevent off-by-one

f_count_vowels_check_if_buffer_exceeded:
	blt	$s0, $a0, f_count_vowels_return	# Check if buffer exceeded
	lb	$s1, 0($s0)		# Load character from buffer
	addi	$s0, $s0, -1		# Point to previous character in buffer
	move	$s5, $s4		# Restore pointer to last element of reference buffer
check_reference_character:
	lb	$s6, 0($s5)		# Load character from reference buffer
	beq	$s1, $s6, f_count_vowels_vowel_found
	addi	$s5, $s5, -1		# Point to previous character in reference buffer
	ble	$s2, $s5, check_reference_character # Check if reference buffer exceeded
	j	f_count_vowels_check_if_buffer_exceeded

f_count_vowels_vowel_found:
	addi	$v0, $v0, 1
	j	f_count_vowels_check_if_buffer_exceeded

f_count_vowels_return:
	jr	$ra

##
## int write_output_file(char *output_file_name, char *buffer, unsigned buffer_size)
## Leafnode function - https://en.wikipedia.org/wiki/Calling_convention#MIPS
## TODO: Add verbose description - MAYBE
##
f_write_output_file:

	move	$s0, $a1		# Save buffer
	move	$s1, $a2		# Save buffer_size

	li	$v0, 13			# Create output_file (syscall 13)
	li	$a1, 1			# Set flag=1: write, no append
	li	$a2, 0			# Set mode=0: ignored
	syscall
	bltz	$v0, f_write_output_file_return	# Check if open succeeded
	move	$s2, $v0		# Save file descriptor
	li	$v0, 15			# Write output_buffer (syscall 15)
	move	$a0, $s2		# Restore file descriptor
	move	$a1, $s0		# Restore buffer
	move	$a2, $s1		# Restore buffer_size
	syscall
	bltz	$v0, f_write_output_file_return
	la	$v0, 16			# Close output_file (syscall 16)
	syscall
f_write_output_file_return:
	jr	$ra

# vim: ts=8:isk+=$
