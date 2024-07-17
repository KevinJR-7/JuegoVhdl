
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all;
use IEEE.std_logic_textio.all;
library UNISIM;
use UNISIM.VComponents.all;



entity VGACounter is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           PBTON : in  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (11 downto 0);
		   ps2Clk   : in STD_LOGIC;                    
           ps2Data 	: in STD_LOGIC
	       );
end VGACounter;

architecture Behavioral of VGACounter is
	-- Declaramos componentes
	COMPONENT BIN2BCD_0a999
	PORT(
		BIN : IN std_logic_vector(9 downto 0);          
		BCD2 : OUT std_logic_vector(3 downto 0);
		BCD1 : OUT std_logic_vector(3 downto 0);
		BCD0 : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	
	COMPONENT display34segm is 
	generic(SG_WD : integer range 0 to 31 := 5; --Segment width
               DL : integer range 0 to 511 := 100  --DYSPLAY_LENGTH
        ); 
	PORT(
		posx : in integer range 0 to 639; 
        posy : in integer range 0 to 480;
        segments : in STD_LOGIC_VECTOR (33 downto 0);
        hcount : in  STD_LOGIC_VECTOR (10 downto 0);
        vcount : in  STD_LOGIC_VECTOR (10 downto 0);
        paint : out  STD_LOGIC
      );
    End component;
    
    
  component ps2_keyboard_to_ascii IS
  GENERIC(
      clk_freq                  : INTEGER := 50_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 8);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
  PORT(
      clk        : IN  STD_LOGIC;                     --system clock input
      ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
      ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value
END component;
    
    
	COMPONENT vga_ctrl_640x480_60Hz
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		rgb_in : IN std_logic_vector(11 downto 0);          
		HS : OUT std_logic;
		VS : OUT std_logic;
		hcount : OUT std_logic_vector(10 downto 0);
		vcount : OUT std_logic_vector(10 downto 0);
		rgb_out : OUT std_logic_vector(11 downto 0);
		blank : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT Display 
	GENERIC ( LW: INTEGER:=10;
				 DW: INTEGER:=50;
				 DL: INTEGER:=100;
				 POSX: INTEGER:= 0;
				 POSY: INTEGER:= 0
         	); 
   PORT (  HCOUNT : in  STD_LOGIC_VECTOR (10 downto 0);
           VCOUNT : in  STD_LOGIC_VECTOR (10 downto 0);
           VALUE : in  STD_LOGIC_VECTOR (3 downto 0);
           PAINT : out  STD_LOGIC);
	end COMPONENT;
	
	COMPONENT AlphaNumerico
	GENERIC ( LW: INTEGER:=10;
				 DW: INTEGER:=50;
				 DL: INTEGER:=100;
				 POSX: INTEGER:= 0;
				 POSY: INTEGER:= 0
         	); 
	PORT(
		ALPHANUM : IN std_logic_vector(6 downto 0);
		HCOUNT : IN std_logic_vector(10 downto 0);
		VCOUNT : IN std_logic_vector(10 downto 0);          
		PAINT : OUT std_logic
		);
	END COMPONENT;
	
   COMPONENT cohete
   GENERIC ( 
   L : integer:= 20;
   w : integer:= 10     
   );
   PORT(
   xc : in STD_LOGIC_VECTOR (10 downto 0);
   yc : in STD_LOGIC_VECTOR (10 downto 0);
   hcout : in std_logic_vector(10 downto 0);
   vcout : in std_logic_vector(10 downto 0);
   paint : out std_logic;
   clkat : in std_logic
   );
   END COMPONENT;
   
   
   COMPONENT barrera
   GENERIC ( 
   L : integer:= 20;
   w : integer:= 10     
   );
   PORT(
   xc : in STD_LOGIC_VECTOR (10 downto 0);
   yc : in STD_LOGIC_VECTOR (10 downto 0);
   hcout : in std_logic_vector(10 downto 0);
   vcout : in std_logic_vector(10 downto 0);
   paint : out std_logic
   );
   END COMPONENT;
   
   	
	-- Declaramos seales
	signal hcount : STD_LOGIC_VECTOR (10 downto 0);
	signal vcount : STD_LOGIC_VECTOR (10 downto 0);
   signal paint2 : STD_LOGIC;
   signal paint1 : STD_LOGIC;
   signal paint0 : STD_LOGIC;
	signal rgb_aux1 : STD_LOGIC_VECTOR (2 downto 0);
	signal rgb_aux2 : STD_LOGIC_VECTOR (11 downto 0);
	signal rgb_aux3 : STD_LOGIC_VECTOR (11 downto 0);
	signal conteo : std_logic_vector(9 downto 0);
	signal unidades : std_logic_vector(3 downto 0);
	signal decenas : std_logic_vector(3 downto 0);
	signal centenas : std_logic_vector(3 downto 0);
	signal CLK_1Hz : STD_LOGIC:='0';
	signal count_clk : INTEGER:=0;
	signal count_clk2: INTEGER:=0;
	signal clk_interno : STD_LOGIC;
	signal vs2 :std_logic;
	signal contx : std_logic_vector(10 downto 0);
	signal conty : std_logic_vector(10 downto 0);
	signal contyb1: std_logic_vector(10 downto 0):="00011001000";
	signal contyb2: std_logic_vector(10 downto 0):="00101111100";
	signal clk_interno2 : std_logic;
	signal chpy:std_logic_vector(10 downto 0):="00010110000";
	--señales teclado
	  --signal clk_s:  STD_LOGIC;                     
      signal ps2_clk_s   :  STD_LOGIC;                    
      signal ps2_data_s  :  STD_LOGIC;                     
      signal ascii_new_s  :  STD_LOGIC;                     
      signal ascii_code_s:  STD_LOGIC_VECTOR(6 DOWNTO 0); 
	
	constant deltax: integer:=6;
	constant deltay: integer:=4;
	constant deltayc: integer:=3;
	--constantes de posicion
	constant consty: std_logic_vector(10 downto 0):="00011111111";
	constant constx: std_logic_vector(10 downto 0):="01001001110";
	
	--Colores
	constant CNUM1 :STD_LOGIC_VECTOR (11 downto 0):="111100000000";
	constant CNUM2 :STD_LOGIC_VECTOR (11 downto 0):="000011110000";
	constant CNUM3 :STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	
	constant CLA:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	constant CLN:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	constant CLG:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	constant CLE:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	constant CLL:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	
	constant CLK1:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	constant CLE1:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	constant CLV:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	constant CLI:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	constant CLN1:STD_LOGIC_VECTOR (11 downto 0):="000000001111";
	
	signal CCH :STD_LOGIC_VECTOR (11 downto 0):="001001001000";
	constant CB :STD_LOGIC_VECTOR (11 downto 0):="111000000000";
	constant CB1: STD_LOGIC_VECTOR (11 downto 0):="111000000000";
	constant CB2: STD_LOGIC_VECTOR (11 downto 0):="111000000000";
	signal Cback:STD_LOGIC_VECTOR (11 downto 0):= "111111111111";
	

 --letras_display
constant segA: std_logic_vector (33 downto 0):="001100" & "011100000111" & "01000000" & "10000000";
constant segN: std_logic_vector (33 downto 0):="000000" & "111101101111" & "10000001" & "00000000";
constant segG: std_logic_vector (33 downto 0):="110110" & "111100000010" & "00000000" & "00000001";
constant segE: std_logic_vector (33 downto 0):="111111" & "111100000000" & "00000000" & "00000000";
constant segL: std_logic_vector (33 downto 0):="000011" & "111100000000" & "00000000" & "00000000";
--constant seg_E: std_logic_vector (33 downto 0):="000000" & "01110111011" & "01000000" & "10000000";
constant segK: std_logic_vector (33 downto 0):="001000" & "111100001001" & "00000100" & "00010000";
constant segE1: std_logic_vector (33 downto 0):="111111" & "111100000000" & "00000000" & "00000000";
constant segV: std_logic_vector (33 downto 0):="000000" & "111000001110" & "00000010" & "00000001";
constant segI: std_logic_vector (33 downto 0):="110011" & "000011110000" & "00000000" & "00000000";
constant segN1: std_logic_vector (33 downto 0):="000000" & "111101101111" & "10000001" & "00000000";
   --letras_color
   --Angel
   signal paintA: STD_LOGIC;
   signal paintN : STD_LOGIC;
   signal paintG : STD_LOGIC;
   signal paintE : STD_LOGIC;
   signal paintL : STD_LOGIC;
   --kevin
   signal paintK: STD_LOGIC;
   signal paintE1 : STD_LOGIC;
   signal paintv : STD_LOGIC;
   signal paintI : STD_LOGIC;
   signal paintN1 : STD_LOGIC;
   --color objetos 
   signal paintC: std_logic;
   signal paintB: std_logic;
   signal paintB1: std_logic;
   signal paintB2 : std_logic;
   
   signal colision : std_logic;
   --signal paintK : STD_LOGIC;
begin
	CLK_DIV: process(clk_interno)
	begin
		if(clk_interno'event and clk_interno='1') then
			if (count_clk = 10000000) then
				count_clk <= 0;
				CLK_1Hz <= not CLK_1Hz;
			else
				count_clk <= count_clk +1;
			end if;
		end if;
	end process;
	
	CONT: process(CLK_1Hz,RST)
	begin
		if (RST='1') then
		elsif (CLK_1Hz'event and CLK_1Hz='1') then
	 		cch<=not(cch);
		end if;
	end process;
	
	LA: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 10,
             posy => 10,
             segments =>segA, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintA
        );
     LN: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 40,
             posy => 10,
             segments =>segN, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintN
        );
        LG: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 70,
             posy => 10,
             segments =>segG, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintG
        ); 
        LE: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 100,
             posy => 10,
             segments =>segE, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintE
        ); 
        LL: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 130,
             posy => 10,
             segments =>segL, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintL
        ); 
        
        
        
        
         LK: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 170,
             posy => 10,
             segments =>segK, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintK
        );   
         LE1: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 200,
             posy => 10,
             segments =>segE1, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintE1
        );   
         LV: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 230,
             posy => 10,
             segments =>segV, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintV
        );   
         LI: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 260,
             posy => 10,
             segments =>segI, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintI
        );
         LN1: display34segm
	   GENERIC MAP(
	       SG_WD =>3,
            DL =>30
	       )
        port map (
             posx => 290,
             posy => 10,
             segments =>segN1, 
             hcount => hcount,
             vcount => vcount,
             paint  => paintN1
        );        
        
	BIN2BCD: BIN2BCD_0a999 PORT MAP(
		BIN => conteo,
		BCD2 => centenas,
		BCD1 => decenas,
		BCD0 => unidades
	);
	
	Display2: Display  
	GENERIC MAP (
		LW => 5,
		DW => 25,
		DL => 30,
		POSX => 340,
		POSY => 10)
	PORT MAP(
		HCOUNT => hcount,
		VCOUNT => vcount,
		VALUE => centenas,
		PAINT => paint2
	);
	
	Display1: Display  
	GENERIC MAP (
		LW => 5,
		DW => 25,
		DL => 30,
		POSX => 375,
		POSY => 10)
	PORT MAP(
		HCOUNT => hcount,
		VCOUNT => vcount,
		VALUE => decenas,
		PAINT => paint1
	);
	
	Display0: Display 
	GENERIC MAP (
		LW => 5,
		DW => 25,
		DL => 30,
		POSX => 410,
		POSY => 10)
	PORT MAP(
		HCOUNT => hcount,
		VCOUNT => vcount,
		VALUE => unidades,
		PAINT => paint0
	);
	
PROCESS
       
begin
 if Vcount<=60  then
     Cback<="000000000000";
 elsif Vcount<=120 then
     Cback<="000000000001";
 elsif  Vcount<=180 then
     Cback<="000000000011";
 elsif  Vcount<=240  then
     Cback<="000000000111";
 elsif Vcount<=320 then
     Cback<="000000001111";
 elsif  Vcount<=400 then
     Cback<="000000011111";
 elsif  Vcount<=480  then
     Cback<="000000111111";
 elsif Vcount<=240 then
     Cback<="000001111111";
 elsif  Vcount<=270 then
     Cback<="000011111111";
 elsif  Vcount<=300  then
     Cback<="000111111111";
 elsif  Vcount<=330  then
     Cback<="001111111111";
 elsif  Vcount<=360  then
     Cback<="011111111111";
 elsif  Vcount<=390  then
     Cback<="111111111111";
 elsif  Vcount<=420  then
     Cback<="111111111111";
 elsif  Vcount<=460  then
     Cback<="111111111111";
 elsif  Vcount<=480  then
     Cback<="111111111111";
--        elsif  Vcount>=385 and hcount<=480 then
--            Cback<="000011110000";
        end if;
end process;

	rgb_aux3 <= CNUM1 when paint2='1' else
	            CNUM2 when paint1='1' else
				CNUM3 when paint0='1' else
				CCH when paintc='1' else
				CB when paintb='1' else
			    CLA when paintA ='1' else
			    CLN when paintN ='1' else
			    CLG when paintG ='1' else
			    CLE when paintE ='1' else
			    CLL when paintL ='1' else
			    CLK1 when paintK ='1' else
			    CLE1 when paintE1 ='1' else
			    CLV when paintV ='1' else
			    CLI when paintI ='1' else
			    CLN1 when paintN1 ='1' else	
			    CB1 when paintb1='1' else
			    CB2 when paintb2='1' else   	    
				  Cback ;

	Inst_vga_ctrl_640x480_60Hz: vga_ctrl_640x480_60Hz PORT MAP(
		rst => RST,
		clk => clk_interno,
		rgb_in => rgb_aux3,
		HS => HS,
		VS => VS2,
		hcount => hcount,
		vcount => vcount,
		rgb_out => RGB,
		blank => open
	);
	cohete1 : cohete
   GENERIC MAP( 
   L => 22,
   w => 39    
   )
   PORT MAP(
   xc => CONTX,
   yc => chpy,
   hcout=> hcount,
   vcout => vcount,
   paint => paintc,
   clkat => clk_1hz
   );
   
   barrera1 : barrera
    GENERIC MAP( 
   L => 34,
   w => 23   
   )
   PORT MAP(
   xc => CONSTX,
   yc => conty,
   hcout=> hcount,
   vcout => vcount,
   paint => paintB
   );
   
   barrera2 : barrera
    GENERIC MAP( 
   L => 34,
   w => 23    
   )
   PORT MAP(
   xc => CONSTX,
   yc => contyb1,
   hcout=> hcount,
   vcout => vcount,
   paint => paintB1
   );
   
   barrera3 : barrera
    GENERIC MAP( 
   L => 34,
   w => 23   
   )
   PORT MAP(
   xc => CONSTX,
   yc => contyb2,
   hcout=> hcount,
   vcout => vcount,
   paint => paintB2
   );
   
   teclado : ps2_keyboard_to_ascii
   port map(
      clk => clK_interno,      
      ps2_clk => ps2Clk,   
      ps2_data => ps2Data,  
      ascii_new =>ascii_new_s, 
      ascii_code => ascii_code_s
   );
   
   
	-- generador de reloj de 50 MHZ
    process (CLK)
        begin  
            if (CLK'event and CLK = '1') then
                clk_interno <= NOT clk_interno;
            end if;
        end process;
    vs <= vs2;
    
CLK_DIV2: process(clk_interno)
	begin
		if(clk_interno'event and clk_interno='1') then
			if (count_clk2 = 200000) then
				count_clk2 <= 0;
				clk_interno2<= not clk_interno2;
			else
				count_clk2 <= count_clk2 +1;
			end if;
		end if;
	end process;

   PROCESS(paintc,paintb,paintb1,paintb2)  
   begin
   if(Hcount>="01001001110") then
   if( (paintc='1' and( paintb='1' or paintb1='1' or paintb2='1'))) then 
   colision<='1';
   else
   colision<='0';
   end if;
   else
   colision<='0';
   end if;
   end process;
   
    process(vs2,rst,ascii_new_s,ascii_code_s,contx)
        begin
        
      if(rst='1'or colision='1') then contx<=(others=>'0');
        else
        if(ascii_new_s ='1'and ascii_code_s=X"64") 
        then contx<=Contx;
        elsif(vs2'event and vs2 = '1') then     
            if(contx >= "1010101000") then 
            contx<=(others=>'0');
            if (conteo=999) then
					conteo <= (others=>'0');
				else
					conteo <= conteo + 1;
				end if;
            else 
                    contx<=contx+deltax;
            end if;         
        end if;
        end if;
        end process; 
        
    PROCESS(vs2,rst)
    begin
        if(rst='1') then conty<=(others=>'0');
        elsif(vs2'event and vs2 = '1') then
            if(conty>= "111011111") then 
            conty<=(others=>'0');
 
            else 
                conty<=conty+deltay;
            end if;
        end if;
        end process; 
        
         PROCESS(vs2,rst)
    begin
        if(rst='1') then contyb1<=(others=>'0');
        elsif(vs2'event and vs2 = '1') then
            if(contyb1>= "111011111") then 
            contyb1<=(others=>'0');
 
            else 
                contyb1<=contyb1+deltay;
            end if;
        end if;
        end process; 
        
           PROCESS(vs2,rst)
    begin
        if(rst='1') then contyb2<=(others=>'0');
        elsif(vs2'event and vs2 = '1') then
            if(contyb2 >= "111011111") then 
            contyb2<=(others=>'0');
 
            else 
                contyb2<=contyb2+deltay;
            end if;
        end if;
        end process;
           process(vs2,rst, ascii_new_s,ascii_code_s,contx,chpy, clk_interno2)
           begin
            if(clk_interno2'event and clk_interno2='1') then 
            if(ascii_new_s ='1'and ascii_code_s=X"73") then
            chpy<=chpy-deltayc;
            elsif(ascii_new_s ='1'and ascii_code_s=X"66") then
            chpy<=chpy+deltayc;
            end if;
            end if;
           end process;
end Behavioral;
