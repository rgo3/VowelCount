.data

# input_file
input_file_name:	.asciiz "LoremIpsum.txt"
input_file_size:	.word 0
input_file_buffer:	.space 1024
input_file_buffer_size:	.word 1024
vowels:		.byte 'A', 'a', 'E', 'e', 'I', 'i', 'O', 'o', 'U', 'u'
vowels_count:	.word 10
count_vowels: .word 0, 0, 0 ,0, 0
newline: .asciiz "\n"
a_count: .asciiz "Anzahl des Vokals A: "
e_count: .asciiz "Anzahl des Vokals E: "
i_count: .asciiz "Anzahl des Vokals I: "
o_count: .asciiz "Anzahl des Vokals O: "
u_count: .asciiz "Anzahl des Vokals U: "

# output_file
output_file_name:	.asciiz "output.txt"

##
## int main(void)
## Funktioniert nur mit MARS, SPIM SPIMmt.
## Auch die Ausgabe in ein File zu schreiben haben wir nicht geschafft
## Aber in Mars bekommen wir ein Ergebnis!!
## Ausommentierter code war der Versuch in ein FIle zu schreiben
.text
.globl main
main:
	# Read input_file
	la	$a0, input_file_name
	la	$a1, input_file_buffer
	lw	$a2, input_file_buffer_size
	jal	f_read_input_file
	bgez	$v0, main_input_file_read

	li	$a0, -1			# Set return code of program
	j	main_return

main_input_file_read:
	la	$s0, input_file_size	# Store number of bytes read 
	sw	$v0, 0($s0)		

	# Count vowels in input_file_buffer
	la	$a0, input_file_buffer
	lw	$a1, input_file_size
	jal	f_count_vowels

	la $, count_vowels
	# print 1
	la 		$a0, a_count
	li 		$v0,4
	syscall
	lw 		$a0, 0($t1)
	addi 	$sp,$sp,4
	li		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0,4
	syscall

	# print 2
	la 		$a0, e_count
	li 		$v0,4
	syscall
	lw 		$a0, 4($t1)
	addi 	$sp,$sp,4
	li		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0,4
	syscall

	# print 3
	la 		$a0, i_count
	li 		$v0,4
	syscall
	lw 		$a0, 8($t1)
	addi 	$sp,$sp,4
	li		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0,4
	syscall

	# print 4
	la 		$a0, o_count
	li 		$v0,4
	syscall
	lw 		$a0, 12($t1)
	addi 	$sp,$sp,4
	li		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0,4
	syscall

	# print 5
	la 		$a0, u_count
	li 		$v0,4
	syscall
	lw 		$a0, 16($t1)
	addi 	$sp,$sp,4
	li		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0,4
	syscall
	#la	$a0, vowel_count	# Store result in memory
	#sw	$v0, 0($a0)

	# Write output_file
	#la	$a0, output_file_name
	#la	$a1, vowel_count
	#la	$a2, 4
	#jal	f_write_output_file
	#bgez	$v0, main_output_file_written

	#li	$a0, -2			# Set return code of program
	#j	main_return

#main_output_file_written:
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
##

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

f_count_vowels_vowel_found:	 	# if a vowel is found check which vowel it is
	add $t0, $s2, $0
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_a
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_a
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_e
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_e
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_i
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_i
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_o
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_o
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_u
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $s1, $t1, found_an_u


## The functions below will add a one to the right place in our count_vowel
## array; They all do practically the same! No further comments needed.
found_an_a:
	la $t1, count_vowels
	lw $t2, 0($t1)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	j f_count_vowels_check_if_buffer_exceeded

found_an_e:
	la $t1, count_vowels
	lw $t2, 4($t1)
	addi $t2, $t2, 1
	sw $t2, 4($t1)
	j f_count_vowels_check_if_buffer_exceeded

found_an_i:
	la $t1, count_vowels
	lw $t2, 8($t1)
	addi $t2, $t2, 1
	sw $t2, 8($t1)
	j f_count_vowels_check_if_buffer_exceeded

found_an_o:
	la $t1, count_vowels
	lw $t2, 12($t1)
	addi $t2, $t2, 1
	sw $t2, 12($t1)
	j f_count_vowels_check_if_buffer_exceeded

found_an_u:
	la $t1, count_vowels
	lw $t2, 16($t1)
	addi $t2, $t2, 1
	sw $t2, 16($t1)
	j f_count_vowels_check_if_buffer_exceeded

f_count_vowels_return:
	jr	$ra

##
## int write_output_file(char *output_file_name, char *buffer, unsigned buffer_size)
## Leafnode function - https://en.wikipedia.org/wiki/Calling_convention#MIPS
## TODO: Add verbose description - MAYBE
##
#f_write_output_file:
#
#	move	$s0, $a1		# Save buffer
#	move	$s1, $a2		# Save buffer_size
#
#	li	$v0, 13			# Create output_file (syscall 13)
#	li	$a1, 1			# Set flag=1: write, no append
#	li	$a2, 0			# Set mode=0: ignored
#	syscall
#	bltz	$v0, f_write_output_file_return	# Check if open succeeded
#	move	$s2, $v0		# Save file descriptor
#	li	$v0, 15			# Write output_buffer (syscall 15)
#	move	$a0, $s2		# Restore file descriptor
#	move	$a1, $s0		# Restore buffer
#	move	$a2, $s1		# Restore buffer_size
#	syscall
#	bltz	$v0, f_write_output_file_return
#	la	$v0, 16			# Close output_file (syscall 16)
#	syscall
#f_write_output_file_return:
#	jr	$ra
