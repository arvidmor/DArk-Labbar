##############################################################################
#
#  KURS: 1DT038 2018.  Computer Architecture
#	
# DATUM:
#
#  NAMN: Arvid Morelid			
#
#  NAMN: Ida Hellqvist
#
#  NAMN: Simon Pislar
#
##############################################################################

	.data
	
ARRAY_SIZE:
	.word	10	# Change here to try other values (less than 10)
FIBONACCI_ARRAY:
	.word	1, 1, 2, 3, 5, 8, 13, 21, 34, 55
STR_str:
	.asciiz "Hunden, Katten, Glassen"
STR_str_camelcase:
	.asciiz "KURS: 1DT038 2018.  Computer Architecture
DATUM:
NAMN: Arvid Morelid			
NAMN: Ida Hellqvist
NAMN: Simon Pislar"

	.globl DBGf
	.text

##############################################################################
#
# DESCRIPTION:  For an array of integers, returns the total sum of all
#				elements in the array.
#
# 		INPUT:	$a0 - address to first integer in array.
#				$a1 - size of array, i.e., numbers of integers in the array.
#
# 	   OUTPUT:	$v0 - the total sum of all integers in the array.
#
##############################################################################
integer_array_sum:  

DBG:	##### DEBUGG BREAKPOINT ######

    addi $v0, $zero, 0   	# Initialize Sum to zero.
	add	 $t0, $zero, $zero	# Initialize array index i to zero.
	
for_all_in_array:

	#### Append a MIPS-instruktion before each of these comments
	
	beq $t0, $a1, end_for_all   # Done if i == N
	sll $t1, $t0, 2 			# 4*i
	add $t2, $a0, $t1			# address = ARRAY + 4*i
	lw  $t3, 0($t2)				# n = A[i]
       	add  $v0, $v0, $t3		# Sum = Sum + n
        addi $t0, $t0, 1		# i++ 
  	j for_all_in_array			# next element
	
end_for_all:
	
	jr	$ra			# Return to caller.
	
##############################################################################
#
# DESCRIPTION: Gives the length of a string.
#
#       INPUT: $a0 - address to a NUL terminated string.
#
#      OUTPUT: $v0 - length of the string (NUL excluded).
#
#     EXAMPLE: string_length("abcdef") == 6.
#
##############################################################################		

string_length:

    addi $v0, $zero, 0   	# Initialize length to 0

count_characters:
	lb   $t1, 0($a0)				# char = A[i]

	beq  $t1, $zero, end_for_all 	# Done if A[i] == NUL
		addi $v0, $v0, 1 			# length++
		addi $a0, $a0, 1			# Increment char address
	j count_characters				# Next char

  	j 	 end_for_all				# Return to caller
	
##############################################################################
#
#  DESCRIPTION: For each of the characters in a string (from left to right),
#				call a callback subroutine.
#
#				The callback suboutine will be called with the address of
#	        	the character as the input parameter ($a0).
#	
#        INPUT: $a0 - address to a NUL terminated string.
#
#				$a1 - address to a callback subroutine.
#
##############################################################################	
string_for_each:

	addi $sp, $sp, -8		# PUSH return address to caller
	sw   $ra, 4($sp)

	sw   $a0, 0($sp)		# PUSH string address

	jal  string_length

	lw  $a0, 0($sp)				# POP string address
	
	addi $sp, $sp, 4			# Restore stack pointer

	addi $t0, $v0, 0			# Save number of characters in the string
	addi $t1, $zero, 0			# Initialize index to 0
	la   $ra, return_to_loop 	# Save return adress to after subroutine

	transform_char_loop: 
		beq  $t1, $t0, end_loop 	# Done if index == string length

			addi $sp, $sp, -12		# Make room on stack
			sw $t0, 8($sp)			# Save string length
			sw $t1, 4($sp)			# Save index to stack
			sw $a0, 0($sp)			# Save character adress to stack

			jr  $a1					# Call subroutine on char
			return_to_loop:

			lw $t0, 8($sp)			# Load string length from stack
			lw $t1, 4($sp)			# Load index from stack
			lw $a0, 0($sp)			# Load char adress from stack
			addi $sp, $sp, 12		# Restore stack pointer

			addi $a0, $a0, 1		# Increment character adress
			addi $t1, $t1, 1		# index++

	j transform_char_loop			# Next element

	end_loop: 
	
	lw	$ra, 0($sp)					# Pop return address to caller
	addi	$sp, $sp, 4				# Restore stack pointer

	jr	$ra							# Return to caller

##############################################################################
#
#  DESCRIPTION: Transforms a lower case character [a-z] to upper case [A-Z].
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################		
to_upper:

	lb   $t0, 0($a0)					# Load character

	addi $t1, $zero, 0x60				# Load lower lower-case-char range
	addi $t2, $zero, 0x7B				# Load upper lower-case-char range

	sgt  $t3, $t0, $t1					# Check if char is above lower lower-case-range
		beq  $t3, $zero, end_for_all		# If char is in lower-case-char range do next line, else do_nothing

			slt  $t3, $t0, $t2			# Check if char is below upper lower-case-range
			beq  $t3, $zero, end_for_all # If char is in lower-case-char range do next line, else do_nothing

				addi $t0, $t0, -0x20	# Make char uppercase
				sb 	 $t0, 0($a0)		# Store uppercase char

	j end_for_all						# Return to caller

##############################################################################
#
#  DESCRIPTION: Transforms an upper case character [A-Z] to lower case [a-z].
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################		
to_lower:

	lb   $t0, 0($a0)					# Load character

	addi $t1, $zero, 0x40				# Load lower lower-case-char range
	addi $t2, $zero, 0x5B				# Load upper lower-case-char range

	sgt  $t3, $t0, $t1					# Check if char is above lower upper-case-range
		beq  $t3, $zero, end_for_all		# If char is in lower-case-char range do next line, else do_nothing

			slt  $t3, $t0, $t2			# Check if char is below upper upper-case-range
			beq  $t3, $zero, end_for_all # If char is in lower-case-char range do next line, else do_nothing

				addi $t0, $t0, 0x20		# Make char lowercase
				sb 	 $t0, 0($a0)		# Store lowercase char

	j end_for_all					# Return to caller

##############################################################################
#
# DESCRIPTION: Reverses a string
#
#	   INPUT: $a0 - address to a NUL terminated string.
#
##############################################################################

reverse_string:
	
	addi $sp, $sp, -8		# Move stack pointer
	sw   $ra, 4($sp)		# PUSH return address to caller
	sw 	 $a0, 0($sp)		# PUSH string address

	jal  string_length

	lw   $a0, 0($sp)		# POP string address
	lw   $ra, 4($sp)		# POP return address to caller
	addi $sp, $sp, 8		# Restore stack pointer

	beq  $v0, $zero, end_for_all # If string == NUL, return to caller

	addi $t0, $zero, 0		# Initialize index to 0 (first character)
	addi $t1, $v0, -1		# Save number of characters in the string (index to last character, account for NUL)

	reverse_loop:
	add  $t2, $a0, $t0		# Update address to "first" character
	add  $t3, $a0, $t1		# Update address to "last" character

		lb  $t4, 0($t2)		# Load first character
		lb  $t5, 0($t3)		# Load last character

		sb  $t4, 0($t3)		# Store first character at adress of last character
		sb  $t5, 0($t2)		# Vice versa
		
		addi $t0, $t0, 1	# Increment low index
		addi $t1, $t1, -1	# Decrement high index

		sgt	 $t6, $t0, $t1 				# Check if low index > high index
		beq  $t6, $zero, reverse_loop 	# If above is false, loop again

	jr $ra

##############################################################################
#
# DESCRIPTION: Capitalizes every other letter in a string
# 			   , setting the rest to be lower case
# 		INPUT: $a0 - address to a NUL terminated string.
#
##############################################################################

camelcase:
	addi $sp, $sp, -8		# Move stack pointer
	sw   $ra, 4($sp)		# PUSH return address to caller
	sw 	 $a0, 0($sp)		# PUSH string address

	addi $t1, $zero, 0		# Initialize index to 0


	camelcase_loop:
		lb 	 $t0, 0($a0)				# Load character
		beq  $t0, $zero, exit_loop 		# If char == NUL, return to caller
		
			andi $t2, $t1, 1				# Check if index is odd


			addi $sp, $sp, -4  				# Make room on stack
			sw 	 $t1, 0($sp)				# PUSH index

			beq  $t2, $zero, do_upper 		# If index is even then to_lower, else do_upper
				jal to_lower				#
				j check_if_char				# Next char

			do_upper:
				jal to_upper
				j check_if_char				# Next char
			


			check_if_char:
				lw   $t1, 0($sp)			# POP index
				addi $sp, $sp, 4			# Restore stack pointer

				lb   $t0, 0($a0)			# Load char

				## Check whether char is a letter. If so, increment index, else just increment adress ## 
				addi $t4, $zero, 0x41				# Load lower upper-case-char range
				slt  $t3, $t0, $t4					# Check if char is negative
				bne  $t3, $zero, increment_adress	# If char is below upper-case-char range, increment_adress

				addi $t4, $zero, 0x7A		  		# Load upper lower-case-char range
				sgt  $t3, $t0, $t4					# Check if char is above lower-case-range
				bne  $t3, $zero, increment_adress	# If char is above lower-case-char range increment_adress

				addi $t4, $zero, 0x60
				sgt  $t3, $t0, $t4					# Check if char is above lower lower-case-range
				bne  $t3, $zero, increment_index	# If char is in lower-case-char range, increment_index

				addi $t4, $zero, 0x5B
				slt  $t3, $t0, $t4					# Check if char is below upper upper-case-range
				bne  $t3, $zero, increment_index	# If char is in upper-case-char range, increment_index

				j increment_adress

				increment_index:
					addi $t1, $t1, 1				# Increment index

				increment_adress:
					addi $a0, $a0, 1			# Increment char address
					j camelcase_loop			# Return to loop


	exit_loop:
		lw   $a0, 0($sp)		# POP string address
		lw   $ra, 4($sp)		# POP return address to caller
		addi $sp, $sp, 8		# Restore stack pointer
	jr $ra

##############################################################################
#
# Strings used by main:
#
##############################################################################

	.data

NLNL:	.asciiz "\n\n"
	
STR_sum_of_fibonacci_a:	
	.asciiz "The sum of the " 
STR_sum_of_fibonacci_b:
	.asciiz " first Fibonacci numbers is " 

STR_string_length:
	.asciiz	"\n\nstring_length(str) = "

STR_for_each_ascii:	
	.asciiz "\n\nstring_for_each(str, ascii)\n"

STR_for_each_to_upper:
	.asciiz "\n\nstring_for_each(str, to_upper)\n\n"	

STR_reverse_string:
	.asciiz "\n\nreverse_string(str)\n\n"

STR_camelcase_string:
	.asciiz "\n\ncamelcase(str)\n\n"
	
	.text
	.globl main


##############################################################################
#
# MAIN: Main calls various subroutines and print out results.
#
##############################################################################	
main:
	addi	$sp, $sp, -4	# PUSH return address
	sw	$ra, 0($sp)

	##
	### integer_array_sum
	##
	
	li	$v0, 4
	la	$a0, STR_sum_of_fibonacci_a
	syscall

	lw 	$a0, ARRAY_SIZE
	li	$v0, 1
	syscall

	li	$v0, 4
	la	$a0, STR_sum_of_fibonacci_b
	syscall
	
	la	$a0, FIBONACCI_ARRAY
	lw	$a1, ARRAY_SIZE
	jal 	integer_array_sum

	# Print sum
	add	$a0, $v0, $zero
	li	$v0, 1
	syscall

	li	$v0, 4
	la	$a0, NLNL
	syscall
	
	la	$a0, STR_str
	jal	print_test_string

	##
	### string_length 
	##
	
	li	$v0, 4
	la	$a0, STR_string_length
	syscall

	la	$a0, STR_str
	jal 	string_length

	add	$a0, $v0, $zero
	li	$v0, 1
	syscall

	##
	### string_for_each(string, ascii)
	##
	
	li	$v0, 4
	la	$a0, STR_for_each_ascii
	syscall
	
	la	$a0, STR_str
	la	$a1, ascii
	jal	string_for_each

	##
	### string_for_each(string, to_upper)
	##
	
	li	$v0, 4
	la	$a0, STR_for_each_to_upper
	syscall

	la	$a0, STR_str
	la	$a1, to_upper
	jal	string_for_each
	
	la	$a0, STR_str
	jal	print_test_string
	
	
	lw	$ra, 0($sp)	# POP return address
	addi	$sp, $sp, 4	
	
	##
	### reverse_string(STR_str)
	##

	la $a0, STR_reverse_string
	syscall

	la	$a0, STR_str
	jal reverse_string

	jal	print_test_string

	##
	### camelcase(STR_str)
	##

	la $a0, STR_camelcase_string
	syscall

	la	$a0, STR_str_camelcase
	jal camelcase

	la	$a0, STR_str_camelcase
	jal	print_test_string

	# comment this line for mars
	jr	$ra

	# uncomment the next two lines for mars
	# li $v0, 10
    # syscall

##############################################################################
#
#  DESCRIPTION : Prints out 'str = ' followed by the input string surronded
#		 by double quotes to the console. 
#
#        INPUT: $a0 - address to a NUL terminated string.
#
##############################################################################
print_test_string:	

	.data
STR_str_is:
	.asciiz "str = \""
STR_quote:
	.asciiz "\""	

	.text

	add	$t0, $a0, $zero
	
	li	$v0, 4
	la	$a0, STR_str_is
	syscall

	add	$a0, $t0, $zero
	syscall

	li	$v0, 4	
	la	$a0, STR_quote
	syscall
	
	jr	$ra
	

##############################################################################
#
#  DESCRIPTION: Prints out the Ascii value of a character.
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################
ascii:	
	.data
STR_the_ascii_value_is:
	.asciiz "\nAscii('X') = "

	.text

	la	$t0, STR_the_ascii_value_is

	# Replace X with the input character
	
	add	$t1, $t0, 8	# Position of X
	lb	$t2, 0($a0)	# Get the Ascii value
	sb	$t2, 0($t1)

	# Print "The Ascii value of..."
	
	add	$a0, $t0, $zero 
	li	$v0, 4
	syscall

	# Append the Ascii value
	
	add	$a0, $t2, $zero
	li	$v0, 1
	syscall


	jr	$ra
	
