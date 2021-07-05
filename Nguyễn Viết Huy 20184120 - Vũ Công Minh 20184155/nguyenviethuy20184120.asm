.data
	nhap: .ascii "input : \0"
	error_ms: .ascii "opcode: "
	current_char: .byte '\0'
	s:.space 200
	command: .space 200
	opcode: .space 30
	token: .space 30
	string: .space 30
	number: .space 30
	label: .space 30
	registers: .asciiz "$zero $at   $v0   $v1   $a0   $a1   $a2   $a3   $t0   $t1   $t2   $t3   $t4   $t5   $t6   $s7   $s0   $s1   $s2   $s3   $s4   $s5   $s6   $s7   $s7   $t9   $k0   $k1   $gp   $sp   $fp   $ra   $0    $1    $2    $3    $4    $5    $7    $8    $9    $10   $11   $12   $13   $14   $15   $16   $17   $18   $19   $20   $21   $22   $21   $22   $23   $24   $25   $26   $27   $28   $29   $30   $31   \0"
	#  1 la thanh ghi , 2 la so , 3 la dinh danh , 4 la ( , 5 la ) 6 la chi so, x la ket thuc
	list_oc: .asciiz "sb    16415x* or    111x    xor   111x*** lui   ******* jr    ******* jal   3x***** addi  112x*** add   111x*** sub   111x*** ori   ******* and   ******* beq   113x*** bne   113x*** j     3x***** nop   x****** \0"

	syntax: .space 8
	flag: .word 1
	continueMessage: .asciiz "Ban muon tiep tuc chuong trinh?(0.Yes/1.No)"
	error1: .ascii " thanh ghi khong ton tai\n\0"
	error: .ascii " opcode khong ton tai\n\0"
	error2:.ascii " thua toan hang\n\0"
	error3:.ascii " sai '(' hoac  ')'\n\0"
	error4:.ascii " label khong hop le\n\0"
	error5:.ascii " number khong hop le\n\0"
	message1: .ascii " hop le\n\0"
	message2: .ascii " dung cu phap\n\0"
	
.text


begin:
#doc dau vao va xu ly ( ) vidu abc()) -> abc ( ) )
	input:
		addi $v0 , $zero ,4
		la $a0 , nhap
		syscall
		add $v0 , $zero , 8
		la $a0 ,  s
		addi $a1 , $zero , 200
		syscall 
	
	la $t1, s
	la $t2 command

	forc:
		lb $t3, ($t1)
		beq $t3,'\0',done
		sb $t3 , ($t2)
		bne $t3,'(',el
		addi $t4,$zero,' '
		sb $t4,($t2)
		addi $t2,$t2,1
		sb $t3,($t2)
		addi $t2,$t2,1
		sb $t4,($t2)
		addi $t1,$t1,1 
		addi $t2,$t2,1		
		j forc
		el:
		bne $t3,')',el1
		addi $t4,$zero,' '
		sb $t4,($t2)
		addi $t2,$t2,1
		sb $t3,($t2)
		addi $t2,$t2,1
		sb $t4,($t2)
		addi $t1,$t1,1 
		addi $t2,$t2,1		
		j forc
		el1:
		sb $t3,($t2)
		addi $t1,$t1,1 
		addi $t2,$t2,1
		j forc
	done:
	
# doc lan luot cac token phan cach nhau boi ' ' , ','
	
	la $s7, command
	la $s1, syntax
	addi $s1,$s1,-1
#doc op code va xac dinh cu phap vi du neu opcode la sb thi cu phap la {16415} tuong ung voi {thanh ghi, imm ,(,thanh ghi,)}   
	read_opcode:
		jal read_token
		jal make_opcode
	compile:
		lb $s6,($s1)
		jal read_token
		j eat
		
	
	eat:
		
		 beq $s6, '1',make_register
		 beq $s6, '2',make_number
		 beq $s6, '3',make_label
		 beq $s6, '4',make_lpar
		 beq $s6, '5',make_rpar
		 beq $s6, '6',make_index			
		 beq $s6, 'x',successful_messsage
	

	make_opcode:
		la $t1,list_oc # di den danh sach op code
		add $t2,$zero,$t1 # t2 tro den t1
		la $t4, string
		copy1:
			lb $t5, 0($t2)
			beq $t5 , ' ' , end_copy1
			sb $t5, ($t4)
			addi $t4,$t4,1
			addi $t2,$t2,1
			j copy1
		end_copy1:
			addi $t5,$zero,'\0'
			sb $t5,($t4)
		
		
		
		addi $t3,$zero,1
		sw $t3, flag 
		
		la $t3 , token	
		la $t4, string
			
	
		jal compare_string
		lw $s5 , flag
		
		beq $s5,1,default3
		else3:
			addi $t1,$t1,14
			add $t2,$t1,$zero
			la $t4, string
			lb $s3 , ($t2)
			beq $s3,'\0',error_message_opcode
			j copy1
		default3:
		   addi $t2, $t2 ,1
		   lb $t5, 0($t2)
		   beq $t5,' ',default3
		   la ,$t3 ,syntax
		   for:
		   	lb $t5, 0($t2)
		   	sb $t5, 0($t3)
		   	addi $t2,$t2,1
		   	addi $t3,$t3,1
		   	lb $t5, 0($t2)
		   	bne $t5,' ',for
		
		   j successful1
	
	
	
	make_register:
		la $t1,registers # di den danh sach thanh ghi
		add $t2,$zero,$t1 # t2 tro den t1
		la $t4, string
		copy:
			lb $t5, 0($t2)
			beq $t5 , ' ' , end_copy
			sb $t5, ($t4)
			addi $t4,$t4,1
			addi $t2,$t2,1
			j copy
		end_copy:
			addi $t5,$zero,'\0'
			sb $t5,($t4)
		
		
		
		addi $t3,$zero,1
		sw $t3, flag 
		
		la $t3 , token	
		la $t4, string
			
	
		jal compare_string
		lw $s5 , flag
		
		beq $s5,1,default2
		else2:
			addi $t1,$t1,6
			add $t2,$t1,$zero
			la $t4, string
			lb $s3 , ($t2)
			beq $s3,'\0',error_message_register
			j copy
		default2:
			j successful1
		

	
	make_index:
		addi $t3,$zero,1
		sw $t3, flag 		
		la $t1, token
		lb $t2,($t1)
		beq $t2 ,'\0', error_message_number
		beq $t2 ,'-', make_number
		jal is_nb
		lw $t2, flag
		beq $t2,1,make_number
		addi $s1,$s1,1
		j make_lpar
		

	make_number:
	 
		la $t1, token
		lb $t2,($t1)
		beq $t2 ,'\0', error_message_number
		bne $t2 ,'-', fornb
		addi $t1,$t1,1
		lb $t2,($t1)
		beq $t2 ,'\0', error_message_number
		fornb:
			lb $t2,($t1)
			beq $t2,'\0', successful1
			
			addi $t3,$zero,1
			sw $t3, flag 
			jal is_nb
			lw $t3,flag
			
			beq $t3 , 0, error_message_number
			addi $t1,$t1,1
			j fornb
	
	
	make_label:
		addi $t3,$zero,1
		sw $t3, flag 
		la $t1, token
		lb $t2,($t1)
		beq $t2 ,'\0', error_message_label
		jal is_nb
		lw $t2, flag
		beq $t2,1,error_message_label
		add $t4,$zero,0
		forid:
			
			lb $t2,($t1)
			beq $t2,'\0', successful1
			
			addi $t3,$zero,1
			sw $t3, flag 
			jal is_nb
			lw $t3,flag
			add $t4,$t4,$t3
			
			addi $t3,$zero,1
			sw $t3, flag 
			jal is_leter_lower
			lw $t3,flag
			add $t4,$t4,$t3
			
			addi $t3,$zero,1
			sw $t3, flag 
			jal is_leter_upper
			lw $t3,flag
			add $t4,$t4,$t3
			
			beq $t4 , 0, error_message_label
			addi $t1,$t1,1
			j forid
	
	is_nb:
		addi $t3,$t2,-48
		bltz $t3 , elsenb
		
		addi $t3,$zero,57
		sub $t3,$t3,$t2
		bltz $t3 , elsenb
		jr $ra		
		elsenb:
			sb $zero, flag
		        jr $ra
        
        is_leter_upper:
        	
        	addi $t3,$t2,-65
		bltz $t3 , elsenb
		addi $t3,$zero,90
		sub $t3,$t3,$t2
		bltz $t3 , elseup
		jr $ra		
		elseup:
			sb $zero, flag
		        jr $ra
	
	is_leter_lower:
		addi $t3,$t2,-97
		bltz $t3 , elsenb
		addi $t3,$zero,122
		sub $t3,$t3,$t2
		bltz $t3 , elsenl
		jr $ra
				
		elsenl:
			sb $zero, flag
		        jr $ra
		
	make_lpar:
		la $t1, token
		lb $t2, ($t1)
		bne  $t2 ,'(',error_message_par
		j successful1
	
	make_rpar:
		la $t1, token
		lb $t2, ($t1)
		bne  $t2 ,')',error_message_par
		j successful1
	
	
	#doc cac token 
	
	read_token:		
		lb $t1 , 0($s7)

		addi $t2 , $zero, ' '
		beq $t1 , $t2 , skip
	        
		addi $t2 , $zero, ','
		beq $t1 , $t2 , skip
		
		la $t3, token
		j read_char
		end_read_char:	
		#addi $t3,$t3,1
		addi $t1,$zero,'\0'
		sb $t1,($t3)
		jr $ra



	#bo qua dau ' ' va ','										
	skip:
		addi $s7, $s7,1
		
		lb $t1 , 0($s7)
		addi $t2 , $zero, ' '
		beq $t1 , $t2 , skip
	        
	        lb $t1 , 0($s7)
		addi $t2 , $zero, ','
		beq $t1 , $t2 , skip
		j read_token
	
	#doc lan luot cac ki tu
	read_char:
		
		lb $t1 , 0($s7)
		addi $t2 , $zero, '\n'
		beq $t1 , $t2 , end_read_char
		
		addi $t2 , $zero, ' '
		beq $t1 , $t2 , end_read_char
	        
		addi $t2 , $zero, ','
		beq $t1 , $t2 , end_read_char
		
		addi $s7, $s7 , 1
		sb $t1 , ($t3)
		addi $t3,$t3,1
		j read_char
	
	#so sanh 2 xau voi nhau			
	compare_string:
		lb $t5,($t3) 
		lb $t6,($t4)
		beq $t5,$t6 ,else1
		sw $zero,flag
		j default1
		else1:
			beq $t5,'\0',default1
			addi $t3,$t3,1
			addi $t4,$t4,1
			j	compare_string	
		default1:	
		jr $ra
			
								
	error_message_register:
		addi $v0 , $zero ,4
		la $a0 , token 
		syscall
		la $a0 , error1 
		syscall
		j end
		
	error_message_opcode:
		addi $v0 , $zero ,4
		la $a0 , token 
		syscall
		la $a0 , error 
		syscall
		j end		
	successful1:
		addi $v0 , $zero ,4
		la $a0 , token 
		syscall
		la $a0 , message1 
		syscall
		addi $s1,$s1,1
		j compile
		
	
	error_message_number:
		addi $v0 , $zero ,4
		la $a0 , token 
		syscall
		la $a0 , error5
		syscall
		j end
	
	error_message_label:
		addi $v0 , $zero ,4
		la $a0 , token 
		syscall
		la $a0 , error4
		syscall
		j end
	error_message_par:
		syscall
		la $a0 , error3 
		syscall
		j end			
	
	error_end:
		addi $v0 , $zero ,4
		la $a0 , token 
		syscall
		la $a0 , error2 
		syscall
		j end	
	
       successful_messsage:
		la $s1,token
		lb $s1,($s1)
		bne $s1,'\0',error_end
		addi $v0 , $zero ,4
		la $a0 , message2
		syscall
		
end:
	j continue

continue: # lap lai chuong trinh.
	li $v0, 4
	la $a0, continueMessage
	syscall
	li $v0, 5
	syscall
	add $t0, $v0, $zero
	beq $t0, $zero, resetAll
	j TheEnd
resetAll:
	li $v0, 0 
	li $v1, 0
	li $a0, 0 
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	li $k0, 0
	li $k1, 0
	j input


TheEnd:
