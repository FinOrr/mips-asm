 .data
#Matrices	(size= nrows1*ncols1*4+  8 bytes to store the value of nrow and nolumns)
Mat:			.space	512	# Temporary matrix 
Mat1:			.space	512  
Mat2:			.space	512  
Res:			.space	512	# Result matrix
#Prompts (output that expects a response)
prompt.Row:		.asciiz "Number of rows in matrix:\t"
prompt.Col:		.asciiz "Number of columns in matrix:\t"
prompt.RandomInput:	.asciiz	"[0]: Fill matrix with random values\n[1]: Enter your own matrix values\nPlease enter an option:\t\t"
#Print (no user feedback)
print.Mat1Header:	.asciiz "\n--  MATRIX 1  --\n"
print.Mat2Header:	.asciiz "\n--  MATRIX 2  --\n"
print.Error:		.asciiz "ERROR: The number of rows in matrix 1 is not equal to the number of columns in matrix 2! \nPlease try again.\n"
print.Return:		.asciiz "\n"
print.Space:		.asciiz " "

# Main
.text
main:
jal inputMatrixSize
jal generateMatrix



# print the values
# print for instance Mat1
la $a1, Mat1
jal printArray  #  a function  is called using jal instruction



# quit the program execution
exit: li $v0,10
syscall


inputMatrixSize:
# Prompts user to input the number of rows and columns,
# then stores them in the memory space allocated to Mat
#	--	MATRIX 1	--	#
li 	$v0, 4			# Syscall: print string
la 	$a0, print.Mat1Header	# Matrix 1
syscall	
la 	$a0, prompt.Row		# Asks for number of rows
syscall				
li 	$v0, 5			# syscall: read integer
syscall
move 	$s0, $v0		# Store $s0 <- Mat1.NumRows
li 	$v0, 4			# Syscall: print string
la 	$a0, prompt.Col		# Asks for number of columns
syscall
li 	$v0, 5			# Syscall: read integer
syscall 
move 	$s1, $v0		# Store $s1 <- Mat1.NumCols
#	--	MATRIX 2	--	#
li 	$v0, 4			# Syscall: print string
la	$a0, print.Return	# New line
syscall
la 	$a0, print.Mat2Header	# Matrix 2
syscall	
la 	$a0, prompt.Row		# Asks for number of rows
syscall				
li 	$v0, 5			# syscall: read integer
syscall
move 	$s2, $v0		# Store $s2 <- Mat2.NumRows
li 	$v0, 4			# Syscall: print string
la 	$a0, prompt.Col		# Asks for number of columns
syscall
li 	$v0, 5			# Syscall: read integer
syscall 
move 	$s3, $v0		# Store $s3 <- Mat2.NumCols
bne	$s0, $s3, dimError	# Check matrices dimensions (Mat1.rows = Mat2.cols)
#PUSH STACK
jr 	$ra   			# Return
beqz $t1, $ra
# dimError is called when the dimensions of Mat1 and Mat2 are incompatible
li 	$v0, 4			# Syscall: print string
la	$a0, print.Return	# Make some space in console window
syscall
la	$a0, print.Error	# Alert user to error
syscall
j	inputMatrixSize		# Enter matrix dimensions again

generateMatrix:
# This function fills Mat1 and Mat2 with either [user input] or [randomly generated values]
li	$v0, 4			# Syscall: print string
la	$a0, print.Mat1Header	# Print header 'Matrix 1'
syscall
la	$a0, prompt.RandomInput	# Ask if user wants to randomly generate values
syscall
li	$v0, 5			# Syscall: read integer
syscall
move 	$t1, $v0		# $t1 <- user input
#bnez 	$t1, fillMatrixManual	# If input=1, then fill matrices manually; If input=0, fill randomly
#Random Matrix Generation
fillMatrixRandom:
li	$v0, 41			# Syscall: Generate random value
addi	$a1, $zero, 20		# Set upper bound of random number to 20 
syscall				# Generate random value to $a0
sw 	$a0, Mat1($t5)		# Save the random value to Mat1[] at the address in $t5
addi	$t1, $zero, 4		# Increment the memory pointer by 4
bnez 	$t5, fillMatrixRandom	
jr	$ra				# DOESNT RETURN TO MAIN, $RA HAS CHANGED-

printArray:
lw $t0,0($a1) # nrows
lw $t1,4($a1) # ncols
mul $t2,$t1,$t0 # size
 
addi $a1,$a1,8 # to skip nrows and ncols space
li $t3,0
li $t4,0
j printLoopC
printLoop:
bne $t4,$t1,inTheRow
addi $v0,$zero,4
la $a0,print.Return
syscall
addi $t4,$zero,0
inTheRow: addi $v0,$zero,1
          lw $a0,0($a1)
          syscall
          
addi $v0,$zero,4
la $a0,print.Space
syscall  
                  
addi $t4,$t4,1
addi $t3,$t3,1
addi $a1,$a1,4
printLoopC: blt $t3,$t2,printLoop
jr $ra   # a function ends with jr instruction
