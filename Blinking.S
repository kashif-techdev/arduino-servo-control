;===============================================================
; Assembly via Arduino Mega 2560: SG90 Servo Motor with LEDs
; Description:
; - Moves a servo motor through 8 positions using PWM
; - Lights up specific LEDs (Red, Green, Blue) at selected angles
; - Repeats this cycle indefinitely
;===============================================================

#define __SFR_OFFSET 0x00
#include "avr/io.h"       ; Include I/O definitions for AVR

.global servo_motor       ; Declare entry label as global

;===============================================================
servo_motor:
;------------------ Initialize I/O Pins ------------------------
    SBI   DDRB, 6         ; Set PB6 (Digital Pin 10) as output for servo control
    SBI   DDRC, 7         ; Set PC7 (D30) as output for Red LED
    SBI   DDRC, 6         ; Set PC6 (D31) as output for Green LED
    SBI   DDRC, 5         ; Set PC5 (D32) as output for Blue LED

;------------------ Main Loop Starts ---------------------------
again:     
    LDI   R25, 1          ; Initialize LED control index (position counter)
    LDI   R26, 8          ; Loop through 8 servo positions
    LDI   ZL, lo8(rotate_pos) ; Load address of servo position table (low byte)
    LDI   ZH, hi8(rotate_pos) ; Load address of servo position table (high byte)

l1:
    LPM   R24, Z+         ; Load next PWM value from lookup table into R24
    RCALL rotate_servo    ; Call subroutine to rotate servo and control LED
    DEC   R26             ; Decrement loop counter
    BRNE  l1              ; Repeat loop if more positions left
    RJMP  again           ; Restart the entire sequence

;------------------ Servo Position Lookup Table ----------------
rotate_pos:
.byte 0,180,90  ; PWM durations for servo angles


;===============================================================
rotate_servo:
;------------------ Generate 10 PWM Pulses ---------------------
    LDI   R20, 10         ; Set loop counter for 10 servo pulses

l2:
    SBI   PORTB, 6        ; Set PB6 HIGH to start PWM pulse
    RCALL delay_timer0    ; Delay based on value in R24 (pulse width)
    CBI   PORTB, 6        ; Set PB6 LOW to end pulse
    RCALL delay_20ms      ; Wait 20ms between pulses (standard servo timing)
    DEC   R20             ; Decrement pulse counter
    BRNE  l2              ; Repeat until 10 pulses are sent

;------------------ LED Control Based on Position Index --------
    CPI   R25, 1
    BREQ  red_LED         ; Turn ON Red LED at first position (0°)

    CPI   R25, 3
    BREQ  green_LED       ; Turn ON Green LED at middle position (90°)

    CPI   R25, 5
    BREQ  blue_LED        ; Turn ON Blue LED at far right (180°)

    CPI   R25, 7
    BREQ  green_LED       ; Again Green LED at mirrored 90°

;------------------ Default: Turn OFF LEDs ---------------------
bak:
    RCALL delay_ms        ; Wait ~0.5 seconds to keep LED visible
    CBI   PORTC, 7        ; Turn OFF Red LED
    CBI   PORTC, 6        ; Turn OFF Green LED
    CBI   PORTC, 5        ; Turn OFF Blue LED
    INC   R25             ; Increment position index
    RET                   ; Return to main loop

;------------------ LED Subroutines ----------------------------
red_LED:
    SBI   PORTC, 7        ; Turn ON Red LED
    CBI   PORTC, 6        ; Turn OFF Green LED
    CBI   PORTC, 5        ; Turn OFF Blue LED
    RJMP  bak             ; Jump to LED-off and delay routine

green_LED:
    CBI   PORTC, 7        ; Turn OFF Red LED
    SBI   PORTC, 6        ; Turn ON Green LED
    CBI   PORTC, 5        ; Turn OFF Blue LED
    RJMP  bak

blue_LED:
    CBI   PORTC, 7        ; Turn OFF Red LED
    CBI   PORTC, 6        ; Turn OFF Green LED
    SBI   PORTC, 5        ; Turn ON Blue LED
    RJMP  bak

;===============================================================
delay_timer0:             ; Delay to match PWM width for servo
; Uses Timer0 in CTC (Clear Timer on Compare Match) mode
; Delay duration is based on R24 value (from rotate_pos table)

    CLR   R21             ; Clear R21 for counter
    OUT   TCNT0, R21      ; Reset Timer0 counter
    MOV   R21, R24        ; Load delay value into R21
    OUT   OCR0A, R21      ; Set compare match value
    LDI   R21, 0b00001100 ; Timer0: CTC mode, prescaler 256
    OUT   TCCR0B, R21     ; Start Timer0

l3:
    IN    R21, TIFR0      ; Read Timer Interrupt Flags
    SBRS  R21, OCF0A      ; Skip next if Output Compare Flag A is set
    RJMP  l3              ; Wait until compare match

    CLR   R21
    OUT   TCCR0B, R21     ; Stop Timer0
    LDI   R21, (1<<OCF0A)
    OUT   TIFR0, R21      ; Clear compare match flag
    RET

;===============================================================
delay_20ms:
; Generates a delay of approximately 20 milliseconds
; Triple nested loop to consume time

    LDI   R21, 255        ; Outer loop counter
l4:
    LDI   R22, 210        ; Middle loop counter
l5:
    LDI   R23, 2          ; Inner loop counter
l6:
    DEC   R23             ; Decrement inner loop
    BRNE  l6
    DEC   R22             ; Decrement middle loop
    BRNE  l5
    DEC   R21             ; Decrement outer loop
    BRNE  l4
    RET

;===============================================================
delay_ms:
; Approximate delay of 0.5 seconds for LED visibility
; Triple nested loop for longer delay

    LDI   R21, 255
l7:
    LDI   R22, 255
l8:
    LDI   R23, 41
l9:
    DEC   R23             ; Inner loop
    BRNE  l9
    DEC   R22             ; Middle loop
    BRNE  l8
    DEC   R21             ; Outer loop
    BRNE  l7
    RET
