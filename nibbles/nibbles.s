# Constants
.set WIDTH, 50
.set HEIGHT, 20
# WIDTH * HEIGHT	
.set WH, 1000 
.set CENTER_X, 25
.set CENTER_Y, 10
.set DOWN, 258
.set UP, 259
.set LEFT, 260
.set RIGHT, 261
	
.section .bss
snake_x:	.fill 100, 4, 0 
snake_y:	.fill 100, 4, 0
apples:		.fill 100, 4, 0	# Apples are stored in a singe long: point = y * width + x
direction:	.word 0

.section .text
.globl start_game
start_game:
	pushl %ebp
	movl %esp, %ebp

	# Im using 3 local variables, head location x,y and a value indicating if the head hit an apple.
	subl $12, %esp

	call nib_init

	# Initialize apples.
	leal apples, %esi
	movl 12(%ebp), %ecx
init_apples:
	push %ecx
	call spawnapple # spawnapple only return a point.
	pop %ecx
	movl %eax, (%esi)
	addl $4, %esi
	loop init_apples

	# Initialize the snake.
	lea snake_x, %esi
	lea snake_y, %edi
	
	movb $CENTER_X, %al 		# pos_x = CENTER_X
	movb $CENTER_Y, %bh		# pos_y = CENTER_Y
	movl 8(%ebp), %ecx		# for(int i = length ; i > 0; i--)
init_snake:
	decb %al			# pos_x--
	movb %al, (%esi)		# snake_x[mem_x] = pos_x
	movb %bh, (%edi)		# snake_y[mem_y] = pos_y
	addl $4, %esi 			# mem_x++
	addl $4, %edi			# mem_y++
	loop init_snake

	# Store head location.
	movl snake_x, %esi
	movl snake_y, %edi
	movl %esi, (%ebp)
	movl %edi, -4(%ebp)
	
	# Start of the gameloop.
gameloop:

	# Polling keyboard.
	call nib_poll_kbd
	cmpl $0, %eax
	js no_input
	movl %eax, direction
	jmp input
no_input:
	# No input, use previous input.
	movl direction, %eax

	# Use the input and move the head.
input:

	# Read headlocation.
	movl (%ebp), %ebx
	movl -4(%ebp), %edx
	
	cmpl $DOWN, %eax
	je down
	cmpl $UP, %eax
	je up
	cmpl $LEFT, %eax
	je left
	cmpl $RIGHT, %eax
	je right
up: 	dec %edx
	jmp move
down: 	inc %edx
	jmp move
right: 	inc %ebx
	jmp move
left: 	dec %ebx
	jmp move
move:
	# Store new location.
	movl %ebx, (%ebp)
	movl %edx, -4(%ebp)

	# Check the apples.
	leal apples, %esi
	movl 12(%ebp), %ecx
apples_check:
	movl (%esi), %eax
	movl $WIDTH, %ebx
	xorl %edx, %edx
	divl %ebx

	# Check if hit.
	cmpl %edx, (%ebp)
	jne apple_draw
	cmpl %eax, -4(%ebp)
	jne apple_draw

	# Get new apple location.
	push %ecx
	call spawnapple
	movl %eax, (%esi)
	pop %ecx

	# Set local variable to hit.
	movl $1, %ebx
	movl %ebx, -8(%ebp)

	# Increase length.
	movl $1, %ebx
	addl %ebx, 8(%ebp)

	# Skip drawing this apple, since it's gone!
	jmp apple_inc

apple_draw:	
	push %ecx
	push $66
	push %eax
	push %edx
	call nib_put_scr
	addl $12, %esp
	pop %ecx
	
apple_inc:
	addl $4, %esi
	loop apples_check

	# Ok, time to update the snake.
	leal snake_x, %esi	
	leal snake_y, %edi

	# Get the adress of the last snake block.
	# Multiply with 4 * length for x/y.
	movl 8(%ebp), %eax
	imul $4, %eax
	addl %eax, %esi
	addl %eax, %edi

	# Move the blocks, ie. block[i] = block[i-1], i = length, i--.
	movl 8(%ebp), %ecx
moveblocks:
	subl $4, %esi
	subl $4, %edi
	movl (%esi), %eax
	movl (%edi), %ebx
	addl $4, %esi
	addl $4, %edi
	movl %eax, (%esi)
	movl %ebx, (%edi)
	subl $4, %esi
	subl $4, %edi
	loop moveblocks
	movl (%ebp), %ebx
	movl -4(%ebp), %edx
	movl %edx, (%edi)
	movl %ebx, (%esi)

	# Do col. detection against the map.
	
1:	# snake[0].x > WIDTH
	movl $WIDTH, %eax
	cmpl %ebx, %eax
	jne 1f
	movl $0, (%ebp) 
	
1:	# snake[0].x < 0
	movl $-1, %eax
	cmpl %ebx, %eax
	jne 1f
	movl $WIDTH, (%ebp)

1:	# snake[0].y < 0
	cmp %edx, %eax
	jne 1f
	movl $HEIGHT, -4(%ebp)
	
1:	# snake[0].y > HEIGHT
	movl $HEIGHT, %eax
	incl %eax
	cmp %edx, %eax
	jne 1f
	movl $0, -4(%ebp)
1:	

	# Draw the snake.
	movl 8(%ebp), %ecx
render:
	push %ecx
	push %edx
	push %ebx
	push $88
	push (%edi)
	push (%esi)
	call nib_put_scr
	addl $12, %esp
	pop %ebx
	pop %edx
	pop %ecx
	addl $4, %esi
	addl $4, %edi

	# Check collision with itself.
	cmpl %ebx, (%esi)
	jne nocol
	cmpl %edx, (%edi)
	jne nocol
	jmp exit
nocol:	
	loop render

	# Check if we hit an apple.
	# the finnish the frame.
	cmpl $1, -8(%ebp) 
	je sleep

	# else we need to remove the the last snakeblock part.
remove_tail:
	push $32
	push (%edi)
	push (%esi)
	call nib_put_scr
	addl $12, %esp

sleep:
	# Set collision with apple back to zero.
	movl $0, %ebx
	movl %ebx, -8(%ebp)

	push $100000
	call usleep
	addl $4, %esp	
	
	jmp gameloop
exit:
	call nib_end
	addl $8, %esp
	leave
	ret

	# Return a location on the map.
spawnapple:
	push %ebp
	movl %esp, %ebp
	call rand
	xorl %edx, %edx
	movl $WH, %ebx
	divl %ebx
	movl %edx, %eax
	leave
	ret	
	