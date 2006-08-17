
Code SDIV
;input:
;  EAX = dividend
; [EBP] = divisor
;output:
;  EAX = quotient
; [EBP] = remainder
;clobbered registers:
;   cx, flags
  MOV EBX, [EBP]
  XOR EDX, EDX
  MOV ECX, 32
LCYCLE:
  SHL EAX, 1
  RCL EDX, 1
  CMP EDX, EBX
  JC L0
  SUB EDX, EBX
  INC EAX
L0:
  DEC ECX
  JNZ LCYCLE
  MOV [EBP], EDX
  RET
EndCode

