#	Navn:	sprinter
#	C-signatur:	int sprinter(char *str, char *format,...); 
#	%eax = Teller antall bytes 
#	%ebx = Peker på resultat strengen
#	%ecx = Blir brukt som lager
#	%edx = Blir brukt som peker


	.globl	sprinter	

.data
counter:		.long	0
ten: 			.long 	10
byte_counter:	.long 	0
sixteen:		.long	16

sprinter:
	pushl	%ebp
	movl	%esp,%ebp

	movl	$0,counter
	movl	$0,byte_counter
	movl 	$0,%eax 		#%eax starter å telle bytes fra 0
	movl	8(%ebp),%ebx    #foorste parameteret blir flyttet til %ebx-registeret
	movl	12(%ebp),%edx   #andre parameteret blir flyttet til %edx-registeret
	addl	$16,%ebp 		#%ebp har tredje paramteret

while_loop:
	movb	(%edx),%cl    #while(true){
	cmpb	$37,%cl       #if(char == '%'){
	je		find_format   #find_format()}
	cmpb	$0, %cl 	  #else if(char == 0){
	je		exit		  #exit()}
	movb	%cl,(%ebx)	  #else{charen blir lagt til i resultatet
	jmp		progress  	  #alle pekere ooker}

find_format:			  #finner ut hvilken type format som skcl settes inn
	incl	%edx		  #flytter pekeren videre	
	movb	(%edx), %cl   #legger til byte i registeret 
	cmpb	$37,%cl       #if(char == '%'){
	je		add_percent	  #	add_percent()}
	cmpb	$99, %cl      #else if(char == 'c'){
	je		add_char      #	add_char()}
	cmpb	$115,%cl      #else if(char == 's'){
	je		add_string    #	add_string()}
	cmpb    $100, %cl     #else if(char == 'd'){
	je		add_digit 	  # add_digit()}
	cmpb    $120, %cl 	  #else if(char == 'x'){
	je		add_hex		  # add_hex()}
	cmpb    $117, %cl 	  #else if(char == 'u'){
	je		add_uint	  # add_uint()}
	cmpb    $35, %cl 	  #else if(char == '#'){
	je		check_newhx	  # check_newhx()}
	jmp		add_error     #else{ add_error()}

progress:
	incl 	byte_counter	# Byte telleren ooker
	incl	%ebx			# Resultat pekeren ooker
	incl	%edx			# %edx pekeren ooker
	jmp 	while_loop		

add_error:				  #legger til '@' for ukjent format input
	movb	$64, (%ebx)   # 64 = '@' i ASCII
	jmp 	progress

add_percent:				# Legger til '%' 
	movb	$37,(%ebx)		# 37 = '%' i ASCII
	jmp		progress		# gaar videre...

add_char:					# Legger til en char
	movb	(%ebp), %cl 	# Flytter argumentet som blir pekt paa til %cl
	movb	%cl, (%ebx) 	# charen blir videre flyttet til streng resultatet
	addl	$4, %ebp		# %ebp-pekeren blir ookt og naa peker den paa en ny argument
	jmp 	progress 		# gaar videre...

add_string:					# Legger til en streng 
	movl	(%ebp), %ecx 	# flytter streng-argumentet til %ecx regitseret
	movb	(%ecx), %cl 	# Flytter den forste charen fra %ecx til %al
	movb 	%cl, (%ebx) 	# Flytter charen til resultat strengen
	cmpb	$0, %cl 		# Sjekker om charen er en null byte
	je		string_exit 	# Strengen er ferdig, blir sent til string exit
	incl 	%ebx 			# Ooker %ebx pekeren
	incl 	byte_counter 			# Ooker byte telleren
	incl 	(%ebp) 			# Ooker %ebp pekeren
	jmp 	add_string 		

string_exit:				#Etter at strengen er lest inn
	addl 	$4, %ebp 		# Gaa over til neste argument
	incl	%edx 			# Ook %edx
	jmp 	while_loop 		

add_digit:					#Legger til int
	movl	$0,counter      
	movl	(%ebp),%eax
	pushl	%edx
	testl  	%eax,%eax 		#sjekker om tallet er positivt eller negativ
	js		negative
	jmp 	positive

negative:					#hvis tallet er negativ
	neg 	%eax            
	movb 	$45, (%ebx) 	#legger til ascii '-' for aa representere at tallet er negativ
	incl	%ebx            
	incl 	byte_counter

positive: 					#hvis tallet er positiv 
	movl	$0,%edx 		#flytter 0 til %edx
	divl 	ten             #del %edx på 10
	addl	$48, %edx 		#gir den ascii representasjon
	push	%edx 			
	incl 	counter
	cmp 	$0, %eax
	je 		finish_int
	jmp 	positive

finish_int: 				#legger til int tallene til resultatet
	popl 	%edx
	movb	%dl,(%ebx)
	incl 	%ebx
	incl 	byte_counter
	decl 	counter
	cmp 	$0, counter
	je  	int_exit
	jmp 	finish_int

int_exit: 					#avslutter int funksjonen og gaar tilbake til loopen
	popl 	%edx
	incl    %edx
	addl	$4,%ebp
	jmp 	while_loop

add_hex: 					#legger til hex tall
	movl	$0,counter
	movl	(%ebp),%eax
	addl	$4,%ebp
	pushl 	%edx

next_hex:                   #gaar over til neste hex tall
	movl 	$0,%edx 		#flytter 0 til %edx
	divl 	sixteen 		#deler %edx på 16
	cmpl 	$9, %edx 		#if(%edx > 9)
	jg		char_hex        #{char_hex()}
	jmp 	int_hex 		#else{int_hex()}

int_hex: 					#har int representasjon
	addl 	$48,%edx
	push 	%edx
	incl 	counter
	jmp 	zeros

char_hex: 					#har char representasjon
	addl 	$87, %edx    	
	push 	%edx
	incl 	counter
	jmp 	zeros

zeros: 						#sjekker om %eax kan deles mer
	cmpl    $0,%eax
	je 		finish_hex
	jmp 	next_hex

finish_hex:                 #legger til hex tallene til resultatet
	popl 	%edx
	movb	%dl,(%ebx)
	incl 	%ebx
	incl 	byte_counter
	decl 	counter
	cmp 	$0, counter
	je  	hex_exit
	jmp 	finish_hex

hex_exit:                   #avslutter hex funksjonen og gaar tilbake til loopen
	popl 	%edx
	incl    %edx
	jmp 	while_loop

add_uint:   				#legger til unsigned int
	movl	$0,counter
	movl	(%ebp),%eax
	pushl	%edx
	jmp 	positive

check_newhx: 				#sjekker om formatet til newhx er riktig
	incl	%edx		  	#flytter pekeren videre	
	movb	(%edx), %cl   	#legger til byte i registeret 
	cmpb    $120, %cl 		#if(char == 'x'){
	je		newhx_add		#newhx()}
	jmp 	add_error		#else{add_erro()}

newhx_add:					#legger til tall i %#x formatet
	movb	$48,(%ebx)		#legger til '0' i resultatet
	incl 	byte_counter	# Byte telleren ooker
	incl	%ebx			# Resultat pekeren ooker
	movb	$120,(%ebx)		#legger til 'x' i resultatet
	incl 	byte_counter	# Byte telleren ooker
	incl	%ebx			# Resultat pekeren ooker
	jmp 	add_hex 		# add_hex()}

exit:					  #avslutter funksjonen, returerer antall bytes
	movb	$0, (%ebx) 	  #null terminerer 
	movl 	byte_counter,%eax
	popl	%ebp          
	ret                      
