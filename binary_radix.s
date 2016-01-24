#            -------------------RADIXSORT--------------------
#
# Vorgabe von Daniel Stelzer, TU Berlin
#
# Ihre Aufgabe: 
# Radixsort implementieren, die Matr. Nummern sind im Array einzutragen.
# radix bekommt als Eingabe das Array und die feste Länge (nicht ändern) des Arrays.
# Das sortierte Array ist auf dem Stack zu speichern (Auf die richtige Reihenfolge achten).
# Der Rücksprung aus radix in die main ist bereits in dieser Vorgabe enthalten.

	.data
bucket0: .space 16
bucket1: .space 16
array: .word 372326, 373174, 371731, 374530 #Matrikelnummer hier durch Komma getrennt
#----------NICHT aendern-------------
n:     .word 4
text1: .asciiz "Willkommen zur Programmierhausaufgabe RORG WS15/16.\nIhr Radixsort hat folgende Reihenfolge sortiert.\n"
newline: .asciiz "\n"

#
# main
#
	.text
.globl main

main:

# Title 
	la 		$a0, text1
	li 		$v0, 4
	syscall
#end title

	addi	$sp, $sp, -4		# save return adress
	sw		$ra, 0($sp)

	la		$a0, array		# array adress
	lw		$a1, n	

	jal	radix

# print 1
	lw 		$a0, 0($sp)
	addi 	$sp,$sp,4
	li		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0,4
	syscall

# print 2
	lw 		$a0, 0($sp)
	addi 	$sp,$sp,4
	li		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0,4
	syscall
# print 3
	lw 		$a0, 0($sp)
	addi 	$sp,$sp,4
	li		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0,4
	syscall
# print 4
	lw 		$a0, 0($sp)
	addi 	$sp,$sp,4
	li		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0,4
	syscall

	lw		$ra, 0($sp)
	addi	$sp, $sp, 4
	#jr		$ra
	li $v0, 10					#exit the program
	syscall
#
# end main
#

radix:
											#a0 = adress of array
											#a1 = n
	
	addi $s0, $0, 1							# s0 = bit-position		
	la $s1, bucket0							# load adress bucket 0 to s1
	la $s2, bucket1							# load adress bucket 1 to s2
	addi $s5, $0, 0							# iterator for outer loop

word_bit_loop:								# outer loop iterates through every bit of a word
	bge $s5, 32, end_word_schleife			# stopps at the 32nd bit

	addi $t0, $0, 0							# t0 = checkvariable for write to bucket
	addi $s3, $0, 0									
	addi $s4, $0, 0						

array_compare_loop:							# compares the checks current bit of every word in array					
	sll $t1, $t0, 2								
	bge $t0, $a1, end_of_compare_loop		# if t0 = n then end comparison of array
	add $t2, $a0, $t1							
	lw $t2, 0($t2)								

	and $t3, $t2, $s0							
	beq $t3, $s0, store_to_bucket1			# if its 1 jump to store_to_bucket1

store_to_bucket0:							# else store to bucket 0
	add $t4, $s1, $s3							
	sw $t2, 0($t4)								
	addi $t0, $t0, 1			
	addi $s3, $s3, 4							
	j array_compare_loop					

store_to_bucket1:							# stores to bucket 1
	add $t4, $s2, $s4							
	sw $t2, 0($t4)								
	addi $t0, $t0, 1							
	addi $s4, $s4, 4							
	j array_compare_loop						

end_of_compare_loop:						# sets t0, s3, s4 back to 0
	addi $t0, $0, 0									
	addi $s3, $0, 0									
	addi $s4, $0, 0									
												
read_bucket0:								# reads words from bucket0
	sll $t1, $t0, 2								
	bge $t0, $a1, end_read_bucket0						
	add $t2, $s1, $s3						
	add $t3, $a0, $t1							
	lw $t2, 0($t2)								
	
	bne $t2, $0, store_to_array_from_bucket0	
	addi $t0, $t0, 1					
	j read_bucket0								

store_to_array_from_bucket0:				# stores whatever is in bucket0 to the original array
	sw $t2, 0($t3)								
	add $t2, $s1, $s3							
	sw $0, 0($t2) 							
	addi $t0, $t0, 1							
	addi $s3, $s3, 4							
	j read_bucket0				

end_read_bucket0:
	srl $t0, $s3, 2								
											
read_bucket1:								# reads words from bucket 1
	sll $t1, $t0, 2								
	bge $t0, $a1, end_read_bucket1				
	add $t2, $s2, $s4							
	add $t3, $a0, $t1							
	lw $t2, 0($t2)								
	
	bne $t2, $0, store_to_array_from_bucket1	
	addi $t0, $t0, 1							
	j read_bucket1									

store_to_array_from_bucket1:				# stores whatever is in bucket1 to the original array
	sw $t2, 0($t3)								
	add $t2, $s2, $s4							
	sw $0, 0($t2)							
	addi $t0, $t0, 1							
	addi $s4, $s4, 4							
	j read_bucket1									

end_read_bucket1:
	addi $t0, $0, 0									
	
continue_bit_loop:							# do everything again, checking the next bit of the word
	sll $s0, $s0, 1
	addi $s5, $s5, 1								
	j word_bit_loop 						
	
end_word_schleife:
	addi $t0, $0, 3								
push_array:										# push array to stack ;)		
	sll $t1, $t0, 2								
	bltz $t0, end_radix 
	add $t2, $a0, $t1							
	lw $t2, 0($t2)								
	
	addi $sp, $sp, -4							
	sw $t2, 0($sp)
	
	addi $t0, $t0, -1							
	j push_array								

end_radix:
	jr 		$ra 								 # jump back to main			

