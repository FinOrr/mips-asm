 .data
#Matrices	(size= nrows1*ncols1*4+  8 bytes to store the value of nrow and nolumns)
Mat1:			.space	512  
Mat2:			.space	512  
Res:			.space	512	# Result matrix
print.InputRows:	.asciiz "Number of rows in matrix:\t"
print.InputCols:	.asciiz "Number of columns in matrix:\t"
#Print (no user feedback)
print.Mat1Header:	.asciiz "\nThe values of Mat1->data, displayed in row-major order are:\n"
print.Mat2Header:	.asciiz "\nThe values of Mat2->data, displayed in row-major order are:\n"
print.ResHeader:	.asciiz "\nThe values of Res->data, displayed in row-major order are:\n"
print.Error:		.asciiz "\nERROR: The number of rows in matrix 1 is not equal to the number of columns in matrix 2! \nPlease try again.\n"
print.Return:		.asciiz "\n"
print.Tab:		.asciiz "\t"
.text
main:
# Get the size of our input matrices 
la  	$a2, Mat1		# Use Mat1 address as function argument (a0/a1 already used in syscalls)
jal	inputMatrixSize		# Get Mat1 dimenisons
la	$a2, Mat2		# Passing Mat2 address as function argument 
jal	inputMatrixSize		# Get Mat2 dimensions 
# Check Mat1 and Mat2 are compatible
lw	$t1, 4($a2)		# Load mat2.cols -> $t1
la	$a2, Mat1		# Access mat1 for number of rows
lw	$t0, 0($a2)		# Load mat1.rows -> $t0
bne 	$t0, $t1, error		# If mat1.rows != mat2.cols, print error message
# Populate Mat1 and Mat2
la	$a2, Mat1		# Using Mat1 as argument for function again
jal	generateMatrix		# Fill Mat1 with values
la	$a2, Mat2		# Use Mat2 as the argument matrix
jal	generateMatrix		# Fill Mat2 with values
# Dot product Mat1 and Mat2, store result in Res array
la	$a1, Mat1		# Load Mat1 address to a1
la	$a2, Mat2		# Load Mat2 address to a2
la	$a3, Res		# Load Res address to a3
jal	matProd			# Call matProd function with Mat1, Mat2 and Res as arguments
# Print out our arrays
la	$a0, print.Mat1Header	# Load mat1 header into syscall arg
la	$a1, Mat1		# Load mat1 array to be printed
jal	printArray		# Print out mat1 array in row-major order
la	$a0, print.Mat2Header	# Load mat2 header to be displayed 
la	$a1, Mat2		# Load mat2 array as an argument for print function
jal 	printArray		# Print out mat2 array in row-major order
la	$a0, print.ResHeader	# Load res header into syscall arg
la	$a1, Res		# Load res array to be printed
jal	printArray		# Print out res array in row-major order
j	exit			# Exit program execution

error:	
# Displays error message in array dimensions
li 	$v0, 4			# Syscall: print string
la	$a0, print.Error	# Alert user to error in matrices dimensions
syscall
j	main			# Loop to the beginnning of the main function

exit: 
# Quit the program execution
li	$v0, 10			# Syscall: exit
syscall

inputMatrixSize: 
# INPUT ROWS
li 	$v0, 4			# Syscall: print string
la 	$a0, print.InputRows	# Asks user to input number of rows
syscall				
li 	$v0, 5			# Syscall: read integer
syscall
sw 	$v0, 0($a2)		# Store input rows in mat
# INPUT COLS
li 	$v0, 4			# Syscall: print string
la 	$a0, print.InputCols	# Asks user to input number of cols
syscall				
li 	$v0, 5			# Syscall: read integer
syscall				# User input will be returned in $v0
sw 	$v0, 4($a2)		# Store input cols in mat
jr 	$ra   			# Return

generateMatrix:		
lw	$s0, 0($a2)		# Save argument matrix rows to $s0
lw	$s1, 4($a2)		# Save argument matrix cols to $s1
move 	$t0, $s0		# Load the row pointer
move	$t1, $s1		# Load the column pointer
addi	$a2, $a2, 8		# Move the memory pointer to an empty data segment
li 	$v0, 30			# Syscall to get the system time
syscall
andi	$a0, $v0, 0x000F	# use the last 4 bits as a random number from 0 to 15
populateRow:
li 	$a0, 0			# Clear the random number 
syscall				# Generate random value into $a0
sw 	$a0, 0($a2)		# Store random value into array
addi	$a2, $a2, 4		# Increment memory pointer
subi	$t1, $t1, 1		# Decrement the column pointer
beqz	$t1, endOfRow		# Move to next row if end of column ($t2=0)
j	populateRow		# If column pointer >0, continue to fill the row
endOfRow:
move	$t1, $s1		# Reload col pointer to $t0
subi	$t0, $t0, 1		# Decrement row pointer
bnez	$t0, populateRow	# If pointer is not at the end of the matrix, repeat
jr	$ra			# Else return to main with a full matrix

matProd:			
lw	$t0, 0($a1)		# t0	<- mat1.rows
lw	$t1, 4($a2)		# t1	<- mat2.cols
sw	$t0, 0($a3)		# Res 	<- mat1.rows
sw	$t1, 4($a3)		# Res 	<- mat2.cols
li      $t2, 0  # Initialise $t2 to 0
li      $t3, 0  # Initialise $t3 to 0
addi	$a3, $a3, 8		# Move Res memory pointer past row/cols
sw	$ra, -4($sp)		# Store return address on stack
nextElement:
li 	$v0, 0			# Reset the sum variable
jal 	sumProdLine2Col		# Call sumProdLine2Col function to 
addi 	$t3, $t3, 1		# Incremement column pointer
bne 	$t3, $t1, nextElement	# If end of column, move to the next row. 
addi 	$t2, $t2, 1		# Move to next row
li 	$t3, 0			# set column to 0
bne 	$t2, $t0, nextElement	# Check if end of array
lw 	$ra, -4($sp)		# Load return address from stack
jr 	$ra			# Return to main
sumProdLine2Col:	
la 	$t7, 8($a1)		# t7 	<- Address of first mat1.val in array
la 	$t8, 8($a2)		# t8	<- Address of first mat2.val in array
mul 	$t6, $t0, 4		# t6	<- Array width (row size in bytes)
mul 	$s2, $t6, $t2		# s2	<- Row Start Index (=counter * width in bytes) 
mul 	$s3, $t3, 4		# s3	<- Column start index (=counter * size of col in bytes)
add 	$t7, $s2, $t7		# t7	<- First mat1.val address in the desired row
add 	$t8, $s3, $t8		# t8	<- First mat2.val address in the desired column
li      $t4, 0  # Initialise $t4 to 0
li	$s2, 0			# Reset row start index
mul 	$s2, $t0, 4		# s2	<- Set rsi to mat1 width
dotProduct:
lw 	$s4, 0($t7)		# Load Mat1 argument to s4
lw 	$s5, 0($t8)		# Load Mat2 argument to s5
mul 	$t9, $s5, $s4		# t9	<- Product of array elements
add 	$v0, $t9, $v0		# v0	<- Running sum of dotProduct 
addi 	$t4, $t4, 1		# Incremement element counter
addi 	$t7, $t7, 4		# Move pointer1 to next row
add 	$t8, $t8, $s2		# Move pointer2 to next column
bne 	$t4, $t0, dotProduct	# If not end of row, dot product elements	
sw	$v0, 0($a3)		# Else; save Res element to array
addi 	$a3, $a3, 4		# Incremement Res memory pointer
li 	$t4, 0			# Reset counter
jr 	$ra 			# Return to nextElement

printArray:
li 	$v0, 4			# Syscall: Print string
syscall
lw 	$t0, 0($a1) 		# t0	<- nrows
lw 	$t1, 4($a1) 		# t1	<- ncols
mul	$t2, $t1, $t0		# t2	<- num of elements in res
addi 	$a1, $a1, 8		# Skip nrows and ncols space in array
li 	$t3, 0			# t3 = element counter 
li 	$t4, 0			# t4 = column counter
j 	printLoopC		# Jump to check if end of matrix
printLoop:
bne 	$t4, $t1, inTheRow	# Check if end of row (col count = ncols)
addi 	$v0, $zero, 4		# Syscall: print string
la 	$a0, print.Return	# Load return to the syscall args
syscall			
addi 	$t4, $zero, 0		# Move to next column
inTheRow: 		
addi 	$v0, $zero, 1		# Syscall: print integer
lw 	$a0, 0($a1)		# Load next element from Res to syscall args
syscall
addi 	$v0, $zero, 4		# Syscall: print string
la 	$a0, print.Tab		# Load tab to the syscall args
syscall    
addi 	$t4, $t4, 1		# Increment column counter
addi 	$t3, $t3, 1		# Increment element counter
addi 	$a1, $a1, 4		# Move memory pointer to next element in array
printLoopC: 
blt 	$t4, $t1, inTheRow	# Check if end of row
blt 	$t3, $t2, printLoop	# Check if end of array
jr 	$ra   			# A function ends with jr instruction
