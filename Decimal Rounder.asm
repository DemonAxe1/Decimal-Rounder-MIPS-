#####################################################################
# Decimal places		Programmer: Tarek Hisham Ahmed Fouad
# Due Date: 4/8/2023			
# Last Modified: 4/8/2023
#####################################################################
# Functional Description:
#	This program asks the user for a float number 
#	Then we take that number and ask the user to say at what 
#	decimal place they want it rounded
#	After that we cut off the float at that position and print it
#
#####################################################################
# Pseudocode:
# 	Prompt user for input
#	Take user input that is a float as a string
#	Check if the string has anything other than numbers and 1 decimal
#	Once that is checked we turn that string into a float number
#	prompt the user to say at what decimal they want to cut off at
#	Take that user input and depending on 1-4 we jump to a part of
#		code that checks and cuts it off at that point
#		(we do this by multiplying by a multiple of 10 then 
#		Turn to int then turn it back to float)
#	Prompt the user with their answer
# 
######################################################################
# Register Usage:
# $v0: used for system calls
# $s3: Used to hold the 10^n (n being the number of decimal numbers
# $t3: Holds the part of the float right of the decimal 
# $t4: Holds the part of the float left of the decimal
# $t5: Used to hold a counter for the 10^n part
# $f0: Set to a 0.0 float
# $f2: Used to hold the result of the addition of both parts of the decimal
# $f5: Used to hold t3 and the multiplication of t3
# $f11:	used to hold the multiple of 10 we are mult and dividing by at the end
# $f12: Used for system calls 
# $f7: used to hold the 10^n in float form
######################################################################
.data

prompt_float_inp:	.asciiz "Enter a float (with at least 5 decimal places): "
prompt_user_inp:		.asciiz "What you entered is: "
newline:			.asciiz "\n"
prompt_answer:		.asciiz "Your number rounded is: "
prompt_persision_inp:	.asciiz "Enter a number between 1 and 4 to set precision: "
errormsg_not_in_range:	.asciiz "The integer you have entered does not fall within the 1-4 choices! !!PLEASE TRY AGAIN!!"
errormsg_letter:		.asciiz "You have entered a letter !! PLEASE TRY AGAIN !!"
final_prompt:		.asciiz "Your decimal cut off to the position you input is: "
zero_as_float:		.float 0.0
one_dec_float:		.float 10.0
two_dec_float:		.float 100.0
three_dec_float:		.float 1000.0
four_dec_float:		.float 10000.0
one_int:			.word 1
num_string:		.space 10
thenthousand: 		.float 10000.0
half_add: 		.float 0.5


.text
main:
	lwc1 $f0, zero_as_float	#Creat a register holding 0 for later use if needed.
	lwc1 $f8, half_add	#Creat a register holding 0 for later use if needed.
	#Creating some vars and resetting them
	#Zeroing out my code
	li $s3, 1		
	li $t3, 0
	li $t4, 0
	
			
	li $v0, 4			#systemcall for print string
	la $a0, prompt_float_inp		#address call to print user prompt for float inp
	syscall
	
	li	$v0, 8			#system call for reading string.
	la	$a0, num_string		#load the address of the compressed string.
	li	$a1, 10			#set a max of 100 characters to reading.
	syscall
	
	move $s1, $a0			#Save a0 into s1 just in case for later
	
	li $t0, 0			#set t0 to 0
loop:
	lb $t2, ($a0)			#Loads the current character from the num string
	#beq $t2, 0, backtoloop		#Test to see if the string has ended
	addi $a0, $a0, 1			#add 1 to a0 so when we loop around, we can grab the next character
	beq $t2, '.', adddec		#Check if the character is a '.'
	blt $t2, '0', errorlet		#check if the number is less than 0
	bgt $t2, '9', errorlet		#check if the number is more than 9
	
	sub $t2, $t2, '0'		#sub 48 from the number we have
	mul $t4, $t4, 10			#multiply by 10 so we can get the next number in
	add $t4, $t2, $t4		#add the number to our sum
	j loop				#loop back
adddec:
	
	lb $t2, ($a0)			#Loads the current character from the num string
	beq $t2, 0, t5loop		#test to see if the string is done
	addi $a0, $a0, 1			#add one to the position of the string array
	addi $t5, $t5, 1		
	blt $t2, '0', errorlet		#check if the number is less than 0
	bgt $t2, '9', errorlet		#check if the number is more than 9
	
	sub $t2, $t2, '0'		#sub 48 from the number we have
	mul $t3, $t3, 10			#multiply by 10 so we can get the next number in
	add $t3, $t2, $t3		#add the number to our sum
	j adddec				#loop back
	
t5loop:
	beqz $t5, backtoloop		# branch to back to loop once we reach the amount of spots after the decimal
	mul $s3, $s3, 10			#10^of the number of spots past the decimal
	subi $t5, $t5, 1			#decrease t5 each loop till its 0
	j t5loop				#jump back to t5loop
	
backtoloop:
	mtc1 $s3, $f7			#Turn the integer back into a float
	cvt.s.w $f7, $f7			
	mtc1 $t4, $f2			#Turn the integer back into a float
	cvt.s.w $f2, $f2
	mtc1 $t3, $f5			#Turn the integer back into a float
	cvt.s.w $f5, $f5
	div.s $f5, $f5, $f7		#divide t5 (everything after the decimal) by 10^of the amount of numbers after the loop
	add.s $f2, $f5, $f2		#add the left side of the decimal and the right side of the decimal
				
	jal newlinejump 			#jump to new line print and link to this instruction to jump back
		
	li $v0, 4			#systemcall for print string
	la $a0, prompt_user_inp		#address call for print user inp prompt (generic)
	syscall
	
	li $v0, 2			#systemcall to print float
	mov.s $f12, $f2			#placing the float into a register that can print it
	syscall
	
	jal newlinejump			#Jumpt to create a new line
decimalinp:	
	li $v0, 4			#system call for print string
	la $a0, prompt_persision_inp	#load address to prompt the user to see what decimal place they want to round to
	syscall
	
	li $v0, 5			#system call to read integer
	syscall
	move $t2, $v0			#moce that integer to the reg t2
	
	li $v0, 4			#system call to prompt the user with their answer
	la $a0, prompt_user_inp		#load address with the generic prompt to show what they put in
	syscall
	
	li $v0, 1			#system call to print integer
	move $a0, $t2			#load the register with the user integer
	syscall
	
	j testfordecimal			#this jumps to the code to check if the number falls between 1-4
	
	
testfordecimal:
	jal newlinejump
	li $v0, 4
	la $a0, final_prompt
	syscall
	#check for one decimal
	addi $t7, $zero, 1		#places 1 in the register t7 to see if that’s the user selection
	beq $t2, $t7, round_1		#if the user input is 1 then jump to round 1
	#check for 2 decimal		
	addi $t7, $zero, 2		#places 2 in the register t7 to see if that’s the user selection
	beq $t2, $t7, round_2		#if the user input is 2 then jump to round 2
	#check for 3 decimal
	addi $t7, $zero, 3		#places 3 in the register t7 to see if that’s the user selection
	beq $t2, $t7, round_3		#if the user input is 3 then jump to round 3
	#check for 4 decimal
	addi $t7, $zero, 4		#places 4 in the register t7 to see if that’s the user selection
	beq $t2, $t7, round_4		#if the user input is 4 then jump to round 4
	j errorint			#if not 1-4 then send an error msg
endcode:
	li $v0, 10			#systemcall to end program safely
	syscall
newlinejump:
	li $v0, 4			#system call to print string
	la $a0, newline			#load address to the new line string
	syscall
	jr $ra				#jump return ra where we jumped from
	
round_1:	
	
	lwc1 $f11, one_dec_float		# create a float register with 10 in it
	mul.s $f2, $f2, $f11		#multiply the float the user entered by 10
	add.s $f2, $f2, $f8		#Add half after we multiply by the base 10 to round up if its less then 5 we round down
	cvt.w.s $f2, $f2			#take the float and turn it to integer
	mfc1 $t1, $f2			#take the integer in the float register and put it in t1
	mtc1 $t1, $f2			#Turn the integer back into a float
	cvt.s.w $f2, $f2			#
	div.s $f2, $f2, $f11		#dvide the float to get it back to the decimal point
	
	li $v0, 2			#systemcall to print float
	mov.s $f12, $f2			#placing the float into a register that can print it
	syscall
	
	j endcode			#jump to end code to end code properly
	
round_2:
	lwc1 $f11, two_dec_float		#creat a float register with 100 in it
	mul.s $f2, $f2, $f11		#multiply the float the user entered by 100
	add.s $f2, $f2, $f8		#Add half after we multiply by the base 10 to round up if its less then 5 we round down
	cvt.w.s $f2, $f2			#take the float and turn it to integer
	mfc1 $t1, $f2			#taje the integer in the float register and put it in t1
	mtc1 $t1, $f2			#take the integer in the float register and put it in t1
	cvt.s.w $f2, $f2			#Turn the integer back into a float
	div.s $f2, $f2, $f11		#dvide the float to get it back to the decimal point
	
	li $v0, 2			#systemcall to print float
	mov.s $f12, $f2			#placing the float into a register that can print it
	syscall
	
	j endcode			#jump to end code to end code properly

round_3:
	lwc1 $f11, three_dec_float	#creat a float register with 100 in it
	mul.s $f2, $f2, $f11		#multiply the float the user entered by 1000
	add.s $f2, $f2, $f8		#Add half after we multiply by the base 10 to round up if its less then 5 we round down
	cvt.w.s $f2, $f2			#take the float and turn it to integer
	mfc1 $t1, $f2			#taje the integer in the float register and put it in t1
	mtc1 $t1, $f2			#take the integer in the float register and put it in t1
	cvt.s.w $f2, $f2			#Turn the integer back into a float
	div.s $f2, $f2, $f11		#dvide the float to get it back to the decimal point
	
	li $v0, 2			#systemcall to print float
	mov.s $f12, $f2			#placing the float into a register that can print it
	syscall
	
	j endcode			#jump to end code to end code properly

round_4:
	lwc1 $f11, four_dec_float	#creat a float register with 100 in it
	mul.s $f2, $f2, $f11		#multiply the float the user entered by 10000
	add.s $f2, $f2, $f8		#Add half after we multiply by the base 10 to round up if its less then 5 we round down
	cvt.w.s $f2, $f2			#take the float and turn it to integer
	mfc1 $t1, $f2			#taje the integer in the float register and put it in t1
	mtc1 $t1, $f2			#take the integer in the float register and put it in t1
	cvt.s.w $f2, $f2			#Turn the integer back into a float
	div.s $f2, $f2, $f11		#dvide the float to get it back to the decimal point
	
	li $v0, 2			#systemcall to print float
	mov.s $f12, $f2			#placing the float into a register that can print it
	syscall
	
	j endcode			#jump to end code to end code properly

errorint:
	jal newlinejump			#create a new line
	li $v0, 4			#system call to print string
	la $a0, errormsg_not_in_range	#load address to try a different integer
	syscall
	jal newlinejump			#create a new line
	j decimalinp			#jump back to decimal place selection
errorlet:
	jal newlinejump			#Add a new line
	li $v0, 4			#system call to print string
	la $a0, errormsg_letter		#adress call to print error msg
	syscall
	jal newlinejump			#add a new line
	j main				#jump back to main and start over
