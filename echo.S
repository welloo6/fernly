.text

.global _start
_start:
disable_interrupts:
	mrs	r0, cpsr
	mov	r1, #0xc0
	orr	r0, r0, r1
	msr	cpsr_cxsf, r0

relocate_stack:
        ldr     r0, =0x7000bffc // stack_start
	mov     sp, r0

print_welcome_banner:
	adr	r0, welcome_banner
	bl	uart_puts

echo:
        adr     r0, stdin
        mov     r1, #2          // 1 char
        mov     r2, #0          // no timeout
        ldr     r3, =0xfff03639 // usb_uart_read
        blx     r3

        ldrb    r1, stdin       // put the byte into stdin

        adr     r0, stdin
        bl      uart_puts
// TODO 1 char at a time in/out
        bl      echo


.align	4
welcome_banner: .ascii	"Hi, Dodge. I hope this has forth someday...\r\n"
		.asciz	"? "
stdin: .asciz "1234"
.align	4

uart_read:
#	void usb_uart_read(void *buffer, int bytes, int timeout)
	ldr	r3, =0xfff03639
	blx	r3

	pop	{pc}

uart_puts:
	push	{lr}
	mov	r3, r0
	mov	r1, #0

uart_puts_count_chars_loop:
	ldrb	r2, [r3], #1
	cmp	r2, #0
	beq	uart_puts_print
	add	r1, r1, #1
	b	uart_puts_count_chars_loop
uart_puts_print:
	mvn	r2, #0

# Call:
# void usb_uart_write(char *data, int bytes, int timeout)
	ldr	r3, =0xfff03653
	blx	r3

# Call:
# void usb_uart_flush(void)
	ldr	r3, =0xfff04845
	blx	r3

uart_puts_exit:
	pop	{pc}
