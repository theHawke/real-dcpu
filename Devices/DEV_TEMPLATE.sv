module DEV_TEMPLATE (

	// CPU/Interrupt interactio ("Westbridge")
	
	
	// DMA ("Eastbridge")
	input DMA_CLOCK,
	input DMA_access, // whether this device has the access right this cycle
	output DMA_want, // whether this device needs DMA at the moment
	output [15:0] DMA_addr,
	output [15:0] DMA_out,
	output DMA_wren,
	input DMA_data

	// Device Specific I/O (clocks etc.)
	

);



endmodule
