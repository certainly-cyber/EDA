//�򵥼��������� 2009-4-29  ����Ȩ��ӽ�� Email:accsys@126.com
//�ο���:��ӽ��.PMC����������Ӧ��.�廪��ѧ������.2008-5
//˵������������ļ򵥼��������ƣ��ǳ�ѧ�������Ƶ����ʵ����

//��������ʱ��clock
//��λ���ƣ�reset_n,�͵�λ��Ч
//���������o
//����洢��iram,16λ����5λ����ָ�����,��imem16_1.mif��ʼ��
//���ݴ洢��dram,16λ�����������ļ���ʼ��
//��lpm�洢����ַ�����ź�Ҫ�ȶ�1�ģ��ſ��Զ�д����

//ָ���ʽ:��5λָ�����,11λ��ַ��,16λ������(�ָߵ�8λ)

module jhcpu
	(
		clock,
		reset_n,
		o,
		//�������(���Բ�Ҫ)��
		opc,
		omar,
		ojp,
		oqw,
/*		olda,
		oadd,
		oout,
		osdal,
		osdah,
		ostr,
		osub,
		ojmp,
		ojz,
		ojn,
		ocall,
		oret,
		oir, */
		oda,
		ozf,osp
	);

	input	clock;
	input	reset_n;
	output [15:0]	o;
	
	output [15:0]	oqw,oda;
	output [10:0]	opc,omar,osp;
	output [2:0]	ojp;
	output		ozf;	/*oiro,lda,oadd,oout,osdal,osdah,ostr,osub,
	ojmp,ojz,ojn,ocall,oret,*/
	
	reg 		dwren,swren;
	wire [15:0] q_w,q_data;
    reg  [15:0] ir;
	reg	 [15:0]	b,a,da,oo,ddata;
	reg  [10:0]	pc,pc_back,mar,sp,q_s;
	reg  [2:0]	jp;		//����
//ָ��:
	reg 		lda,	//ȡ��:�����ݵ�Ԫȡ����da
				add,	//��:da�����ݵ�Ԫ��ӣ��������da
				out,	//���:�����ݵ�Ԫ�������������Ĵ���
				sdal,	//��8λ������:��8λ����������Ϊ16λ��da
				sdah,	//��8λ������:��8λ��������Ϊ��8λ����ԭda��8λ���ӳ�16λ����da��
				str,	//da�����ݴ洢��Ԫ:
				sub,	//��:da�����ݵ�Ԫ������������da
				jmp,	//��ת
				jz,		//daΪ0��ת
				jn,		//daΪ����ת
				call,	//�����ӳ���
				ret,	//����
				mult,	//
				divi,	//
				stp;	//ֹͣ
//�����ź����:
	assign o    = oo;	
	assign opc  = pc;
	assign osp  = sp;
	assign omar = mar;
	assign ojp	= jp;
	assign oqw	= q_w;
	assign olda=lda;
	assign oadd=add;
	assign osub=sub;
	assign oout=out;
	assign ojmp=jmp;
	assign ostr=str;
	assign osdal=sdal;
	assign osdah=sdah;
	assign ocall=call;
	assign oret=ret;
	assign ojz=jz;
	assign ojn=jn;
	assign oda=da;
	assign oir=ir;
	assign ozf=~|da;
	
//ָ��洢��:	 
	lpm_rom iram(.address(pc),.inclock(clock),.q(q_w));  //����洢��
	defparam iram.lpm_width = 16;
	defparam iram.lpm_widthad = 11;
	defparam iram.lpm_outdata = "UNREGISTERED";
	defparam iram.lpm_indata = "REGISTERED";
	defparam iram.lpm_address_control = "REGISTERED";
	defparam iram.lpm_file = "jhcpu.mif";  //��ʼ���ļ�,���ó���
//���ݴ洢��:	
	lpm_ram_dq dram(.data(ddata),.address(mar),.we(dwren),.inclock(clock),.q(q_data)); //���ݴ洢��
	defparam dram.lpm_width = 16;
	defparam dram.lpm_widthad = 10;
	defparam dram.lpm_outdata = "UNREGISTERED";
	defparam dram.lpm_indata = "REGISTERED";
	defparam dram.lpm_address_control = "REGISTERED";
	
	lpm_ram_dq sram(.data(pc_back),.address(sp),.we(swren),.inclock(clock),.q(q_s)); //��ջ
	defparam sram.lpm_width = 11;
	defparam sram.lpm_widthad = 10;
	defparam sram.lpm_outdata = "UNREGISTERED";
	defparam sram.lpm_indata = "REGISTERED";
	defparam sram.lpm_address_control = "REGISTERED";

	
		always @(posedge clock or negedge reset_n)
begin
	if (!reset_n)
	begin
		pc 	 	<= 0;
		sp		<= 0;
		lda 	<= 0;   
		add 	<= 0;   
		out 	<= 0;	
		sdal 	<= 0;	
		sdah 	<= 0;	
		str 	<= 0;
		sub		<= 0;
		jmp 	<= 0;
		jz 		<= 0;
		jn 		<= 0;
		call 	<= 0;
		ret 	<= 0;
		mult 	<= 0;		
		divi 	<= 0;
		jp		<= 0;
	end
	else
	begin
//	����jpָ����״̬�� 
		case (jp)
		0:	begin
			jp <= 1;
			end
		1:	begin
				case (q_w[15:11])
				5'b00001:	lda 	<= 1;	//lda:00001
				5'b00010:	add 	<= 1;	//add:00010
				5'b00011:   out 	<= 1;	//out:00011
				5'b00100:   sdal	<= 1;	//��8λ�������з���16λ
				5'b00101:   sdah 	<= 1;	//��8λ����ǰ���8λ����ϳ�16λ
				5'b00110:   str 	<= 1;	//da�����ݵ�Ԫ
				5'b00111:   sub 	<= 1;	
				5'b01000:   jmp 	<= 1;
				5'b01001:   if (da==0) jz 		<= 1;
				5'b01010:   if (da<0)  jn 		<= 1;
				5'b01011:   call 	<= 1;
				5'b01100:   ret 	<= 1;
				5'b01101:   mult 	<= 1;
				5'b01110:   divi 	<= 1;
				5'b11111:   stp 	<= 1;
				default:    jp <= 0;
				endcase
				jp <= 2;
			end
		2:	begin
				case (q_w[15:11])
				5'b00001:	begin  //lda 	<= 1;	
								mar<=q_w[10:0];
								jp <= 3;
							end
				5'b00010:	begin  //add 	<= 1;	
								mar<=q_w[10:0];
								jp <= 3;
							end
				5'b00011:   begin  //out 	<= 1;
								mar<=q_w[10:0];
								jp <= 3;
							end
					
				5'b00100:   begin  //sdal	<= 1;
								da <= {{8{q_w[7]}},q_w[7:0]};        //����16λ�з�����
								sdal<= 0;
								pc <= pc+1;
								jp<= 0;
							end
					
				5'b00101:   begin  //sdah 	<= 1;
								da[15:0] <= {q_w[7:0],da[7:0]};
								sdah <= 0;
								pc <= pc+1;
								jp<= 0;
							end 
					
				5'b00110:   begin  //str 	<= 1;
								mar<=q_w[10:0];
								ddata <= da;
								jp <= 3;
							end
				5'b00111:   begin  //sub 	<= 1;	
								mar<=q_w[10:0];
								jp <= 3;
							end
				
				5'b01000:   begin  //jmp 	<= 1;
								pc <= q_w[10:0];
								jmp <=0;
								jp <= 0;
							end
				5'b01001:   begin  //jz 		<= 1;
								if (jz) pc <= q_w[10:0];
								else 		pc <= pc+1;
								jz <=0;
								jp <= 0;
							end
				
				5'b01010:   begin  //jn 		<= 1;
								if (jn) pc <= q_w[10:0];
								else 		pc <= pc+1;
								jn<=0;
								jp <= 0;
							end
				5'b01011:   begin  //call 	<= 1;
									pc_back <= pc+1;
									jp <= 3;
							end

				5'b01100:   begin  //ret 	<= 1;
									jp <= 3;
							end
				5'b01101:	begin  //mult	<= 1;	
								mar<=q_w[10:0];
								jp <= 3;
							end
				5'b01110:	begin  //divi 	<= 1;	
								mar<=q_w[10:0];
								jp <= 3;
							end
				5'b11111:	jp<=0;
				default:    jp <= 0;
				endcase
			end 
		3:	begin 
				case (q_w[15:11])
				5'b00001:	begin  //lda 	<= 1;	
								jp <= 4;
							end
				5'b00010:	begin  //add 	<= 1;	
								jp <= 4;
							end
							
				5'b00011:   begin  //out 	<= 1;
								jp <= 4;
							end
					
				5'b00110:   begin  //str 	<= 1;
								dwren <= 1;
								jp <= 4;     
							end
				5'b00111:   begin  //sub 	<= 1;	
								jp <= 4;
							end
				
				5'b01011:   begin  //call 	<= 1;
									pc <= q_w[10:0];
									swren <= 1;
									jp <= 4;
							end

				5'b01100:   begin  //ret 	<= 1;
									sp <= sp-1;
									jp <= 4;
							end
				5'b01101:	begin  //mult 	<= 1;	
								jp <= 4;
							end
				5'b01110:	begin  //divi	<= 1;	
								jp <= 4;
							end
				default:    jp <= 0;
				endcase
			end
			
		4:	begin
				case (q_w[15:11])
				5'b00001:	begin  //lda 	<= 1;	
								da<=q_data;
								pc <= pc+1;
								jp <= 0;
								lda<= 0;
							end
				5'b00010:	begin  //add 	<= 1;	
								b<=q_data;
								a<=da;
								jp <= 5;
							end
				5'b00011:   begin  //out 	<= 1;
								oo <= q_data;
								pc <= pc+1;
								jp <= 0;
								out<= 0;
							end
					
				5'b00110:   begin  //str 	<= 1;
								jp <= 5;     
							end
				5'b00111:   begin  //sub 	<= 1;	
								b<=q_data;
								a<=da;
								jp <= 5;
							end
				
				5'b01011:   begin  //call 	<= 1;
									sp <= sp+1;
									jp <= 5;
							end

				5'b01100:   begin  //ret 	<= 1;
									jp <= 5;
							end
				5'b01101:	begin  //mult 	<= 1;	
								b<=q_data;
								a<=da;
								jp <= 5;
							end
				5'b01110:	begin  //divi 	<= 1;	
								b<=q_data;
								a<=da;
								jp <= 5;
							end														
				default:    jp <= 0;
				endcase
			end
			5:	begin
				case (q_w[15:11])
				5'b00010:	begin  //add 	<= 1;	
								da<=a+b;
								pc <= pc+1;
								add <=0;
								jp <= 0;
							end
					
				5'b00110:   begin  //str 	<= 1;
								dwren <= 0;
								pc <= pc+1;
								str <=0;
								jp <= 0;     
							end
				5'b00111:   begin  //sub 	<= 1;	
								da<=a-b;
								pc <= pc+1;
								sub<=0;
								jp <= 0;
							end
				5'b01011:   begin  //call 	<= 1;
									swren <= 0;
									call<=0;
									jp<=0;
							end

				5'b01100:   begin  //ret 	<= 1;
									pc <= q_s;
									ret<=0;
									jp <= 0;
							end
				5'b01101:	begin  //mult 	<= 1;	
								da <=a*b;
								pc <= pc+1;
								mult <=0;
								jp <= 0;						
							end
				5'b01110:	begin  //divi 	<= 1;	
								da <=a/b;
								pc <= pc+1;
								divi <=0;
								jp <= 0;						
							end							
				default:    jp <= 0;
				endcase
			end

		endcase
	end 
end

		endmodule
 
//////  ����ʵ��: ��64*8�����ѭ������ ////////
//
//			���			����   		
//			sdal 1			2001		
//			str	one			3001
//			sub	one			3801
//			str	result		3002
//			str	n			3005
//			sdal 64			2040
//			str	x			3003
//			sdal 8			2008
//			str	y			3004
//loop:		lda	y			0804
//			jz	exit		4812
//			sub	one			3801
//			str	y			3004
//			lda	result		0802	
//			add	x			1003
//			str	result		3002
//			call loopno		5814
//			jmp	loop		4009
//exit:		out	result		1802
//			stp				ffff
//loopno:	lda	n			0805
//			add one			1001
//			str n			3005
//			out n			1805
//			ret				6000
//					
//		�������16������д��imem16_1.mif 	
//		 						 
///////  16���ƽ�����:0200  //////////////////
//
////��֤CPU��ʵ��3: ��8������������
//
//			���			����   		
//			sdal 1			2001		
//			str	one			3001
//			str	result		3002
//			sdal 8			2008
//			str	x			3003
//loop:		lda	x			0803
//			jz	exit		480D
//			mult 	result	6802		
//			str	result		3002
//			lda	x			0803
//			sub	one			3801
//			str	x			3003
//			jmp	loop		4005
//exit:		out	result		1802
//			stp				ffff
//�������16������д��imem16_2013.mif 


/////// ������ص�����������������������֮��Ҫ����ʱ�ӳ���
//
//��ҵ��ƣ��������һ�������걸�ļ����������PMC110��������������������С�


