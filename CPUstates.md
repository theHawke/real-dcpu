CPU state documentation
-----------------------

-	halt: This is an error state in which the CPU will do nothing until reset

-	fetch: gets the next instruction from memory
	- _modifies_: PC incremented, stores loaded instruction in IB
	- _nextstate_: usually fetch_a, others for fome special instructions (IAG, RFI, HWN)

-	fetch_a: fetches the value for the _a_ argument
	- _modifies_: internal _a_ argument register, NW (NextWord, internal) or SP for some instructions
	- _nextstate_: fetch_b for most, nextword_a if NW is required, others for special instructions

-	nextword_a: takes care of the extra memory access using the nextword argument
	- _modifies_:internal _a_ argument register
	- _nextstate_: whatever state fetch_a would have gon to instead of nextword_a

-	fetch_b:pretty much the same as fetch_a

-	nextword_b: pretty much the same as nextword_a

