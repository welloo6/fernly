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

say_hello:
	adr	r0, hello_string
	bl	uart_puts

done:
	b	done

.align	4
hello_string: .asciz	"Hello, world.\r\n"

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
