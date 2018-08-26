----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 	Fernando Candelario Herrero
--
-- Create Date:    14:19:10 05/24/2018 
-- Design Name: 
-- Module Name:    TecladoCodeReceiver - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TecladoCodeReceiver is
 generic (
	 WL : natural;  -- Sample width
    QM : natural;  -- Decimal numbers of the sample
    FS : real     -- sampling frequency
);
port(
	rst_n     		: in    std_logic;   
   clk       		: in    std_logic;  
	dataRdy   		: in    std_logic;  
	data		 		: in 	std_logic_vector(7 downto 0); 
	outSampleRqt 	: in std_logic; 
	leftChannel 	: in std_logic; 
	en 				: in std_logic; 
	working 			: out std_logic; 
	usingCode		: out std_logic_vector(7 downto 0); 
	sample 			: out std_logic_vector(WL-1 downto 0)
);
end TecladoCodeReceiver;

library ieee;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

architecture Behavioral of TecladoCodeReceiver is
	
	constant QN : natural := WL-QM;  
	
	signal ldCode,ldCodeReg, soundEnable, enRegs,checkData: std_logic;
	signal ini,b1: signed(WL-1 downto 0);
	
	signal code :std_logic_vector(7 downto 0);
	signal outFilterSample : std_logic_vector(WL-1 downto 0);
	
begin

	enRegs<=outSampleRqt and leftChannel;
	
	sampleRegister :
	  process (rst_n, clk)
	  begin
		 if rst_n='0' then
			sample <=(others=>'0');
		 elsif rising_edge(clk) then
				if soundEnable='1' then 
					sample<=outFilterSample;
				else
					sample <=(others=>'0');
				end if;
		end if;
	  end process;
	
	

Filter : IIEFilter
    generic map ( WL =>  16, QM => 14, FS => 48828.0 )
    port map ( rst_n => rst_n, clk => clk, ldCode=>ldCodeReg ,enRegs =>enRegs , inicial =>std_logic_vector(ini) ,b1=>b1  ,outSample => outFilterSample );

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	working<=soundEnable;

	ldCodeRegister :
	  process (rst_n, clk)
	  begin
		 if rst_n='0' then
			ldCodeReg <='0';
		 elsif rising_edge(clk) then
				ldCodeReg<=ldCode;
		end if;
	  end process;

	codeRegister :
	  process (rst_n, clk)
	  begin
		 if rst_n='0' then
			code <=(others =>'0');
		 elsif rising_edge(clk) then
			if(ldCode='1') then
				code<=data;
			end if;
		 end if; 
	  end process;

	usingCode<=code;

	NoteROM :
  with code select
    ini <=
	   toFix(sin((2.0*MATH_PI*130.8)/FS),QN,QM) when X"15",  -- A = Do
		toFix(sin((2.0*MATH_PI*138.6)/FS),QN,QM) when X"1E",  -- W = Do#
		toFix(sin((2.0*MATH_PI*146.8)/FS),QN,QM) when X"1D",  -- S =Re
		toFix(sin((2.0*MATH_PI*155.6)/FS),QN,QM) when X"26",    --E=Re#
		toFix(sin((2.0*MATH_PI*164.8)/FS),QN,QM) when X"24",    --D=Mi
		toFix(sin((2.0*MATH_PI*174.6)/FS),QN,QM) when X"2D",    --F=Fa         
		toFix(sin((2.0*MATH_PI*185.0)/FS),QN,QM) when X"2E",             
		toFix(sin((2.0*MATH_PI*196.0)/FS),QN,QM) when X"2C",             
		toFix(sin((2.0*MATH_PI*207.7)/FS),QN,QM) when X"36",             
		toFix(sin((2.0*MATH_PI*220.0)/FS),QN,QM) when X"35",             
		toFix(sin((2.0*MATH_PI*233.1)/FS),QN,QM) when X"3D",             
		toFix(sin((2.0*MATH_PI*247.0)/FS),QN,QM) when X"3C",
		toFix(sin((2.0*MATH_PI*261.6)/FS),QN,QM) when X"2A",  -- A = Do
      toFix(sin((2.0*MATH_PI*277.2)/FS),QN,QM) when X"34",  -- W = Do#
      toFix(sin((2.0*MATH_PI*293.7)/FS),QN,QM) when X"32",  -- S =Re
		toFix(sin((2.0*MATH_PI*311.1)/FS),QN,QM) when X"33",	--E=Re#
		toFix(sin((2.0*MATH_PI*329.6)/FS),QN,QM) when X"31",	--D=Mi
		toFix(sin((2.0*MATH_PI*349.2)/FS),QN,QM) when X"3A",	--F=Fa		 
		toFix(sin((2.0*MATH_PI*370.0)/FS),QN,QM) when X"42",			 
		toFix(sin((2.0*MATH_PI*392.0)/FS),QN,QM) when X"41",			 
		toFix(sin((2.0*MATH_PI*415.3)/FS),QN,QM) when X"4B",			 
		toFix(sin((2.0*MATH_PI*440.0)/FS),QN,QM) when X"49",			 
		toFix(sin((2.0*MATH_PI*466.2)/FS),QN,QM) when X"4C",			 
		toFix(sin((2.0*MATH_PI*493.9)/FS),QN,QM) when X"4A",			 
		toFix(sin((2.0*MATH_PI*523.3)/FS),QN,QM) when X"59",		
      toFix(0.0,QN,QM) when others;    
		
		
		B1ROM :
  with code select
    b1 <=
      toFix( 2.0*cos( (2.0*MATH_PI*130.8)/FS),QN,QM) when X"15",  -- A = Do
      toFix( 2.0*cos( (2.0*MATH_PI*138.6)/FS),QN,QM) when X"1E",  -- W = Do#
      toFix( 2.0*cos( (2.0*MATH_PI*146.8)/FS),QN,QM) when X"1D",  -- S =Re
		toFix( 2.0*cos( (2.0*MATH_PI*155.6)/FS),QN,QM) when X"26",    --E=Re#
		toFix( 2.0*cos( (2.0*MATH_PI*164.8)/FS),QN,QM) when X"24",    --D=Mi
		toFix( 2.0*cos( (2.0*MATH_PI*174.6)/FS),QN,QM) when X"2D",    --F=Fa	
		toFix( 2.0*cos( (2.0*MATH_PI*185.0)/FS),QN,QM) when X"2E",     --FA#        
		toFix( 2.0*cos( (2.0*MATH_PI*196.0)/FS),QN,QM) when X"2C",     --Sol   
		toFix( 2.0*cos( (2.0*MATH_PI*207.7)/FS),QN,QM) when X"36",     --sol#        
		toFix( 2.0*cos( (2.0*MATH_PI*220.0)/FS),QN,QM) when X"35",     --La        
		toFix( 2.0*cos( (2.0*MATH_PI*233.1)/FS),QN,QM) when X"3D",     --la#     
		toFix( 2.0*cos( (2.0*MATH_PI*247.0)/FS),QN,QM) when X"3C",		--si
		toFix( 2.0*cos( (2.0*MATH_PI*261.6)/FS),QN,QM) when X"2A",  -- A = Do
      toFix( 2.0*cos( (2.0*MATH_PI*277.2)/FS),QN,QM) when X"34",  -- W = Do#
      toFix( 2.0*cos( (2.0*MATH_PI*293.7)/FS),QN,QM) when X"32",  -- S =Re
		toFix( 2.0*cos( (2.0*MATH_PI*311.1)/FS),QN,QM) when X"33",	--E=Re#
		toFix( 2.0*cos( (2.0*MATH_PI*329.6)/FS),QN,QM) when X"31",	--D=Mi
		toFix( 2.0*cos( (2.0*MATH_PI*349.2)/FS),QN,QM) when X"3A",	--F=Fa		 
		toFix( 2.0*cos( (2.0*MATH_PI*370.0)/FS),QN,QM) when X"42",			 
		toFix( 2.0*cos( (2.0*MATH_PI*392.0)/FS),QN,QM) when X"41",			 
		toFix( 2.0*cos( (2.0*MATH_PI*415.3)/FS),QN,QM) when X"4B",			 
		toFix( 2.0*cos( (2.0*MATH_PI*440.0)/FS),QN,QM) when X"49",			 
		toFix( 2.0*cos( (2.0*MATH_PI*466.2)/FS),QN,QM) when X"4C",			 
		toFix( 2.0*cos( (2.0*MATH_PI*493.9)/FS),QN,QM) when X"4A",			 
		toFix( 2.0*cos( (2.0*MATH_PI*523.3)/FS),QN,QM) when X"59",		
      toFix(0.0,QN,QM) when others;  
		

	checkData<= '1' when data=X"15" or data=X"1E" or data=X"1D" or data=X"26" or data=X"24" or data=X"2D" or data=X"2E" or data=X"2C" or data=X"36" or data=X"35" or data=X"3D" or data=X"3C" or data=X"2A" or data=X"34" or data=X"32" or data=X"33" 
								or data=X"31" or data=X"3A" or data=X"42" or data=X"41" or data=X"4B" or data=X"49" or data=X"4C" or data=X"4A" or data=X"59" or data=X"F0" else'0';


		
  fsm:
  process (rst_n, clk, dataRdy, data, code)
    type states is (S0, S1, S2, S3); 
    variable state: states;
  begin 
    --Mealy
    if(dataRdy='1' and data/=X"F0" and state=S0) then
      ldCode<='1';
    else
      ldCode<='0';
    end if;
    --Moore
    case state is 
      when S0 =>
        soundEnable<='0';
      when S1 =>
        soundEnable<='1';
      when S2 =>
        soundEnable<='1';
      when S3 =>
        soundEnable<='0';
      when others =>
        soundEnable<='0';
    end case;
    --FSM
    if rst_n='0' then
      state:=S0;
    elsif rising_edge(clk) then
			case state is 
			when S0 =>
			  if dataRdy='1' and en='1' and checkData='1' and data/=X"F0" then
				 state:=S1;
			  elsif dataRdy='1' and data=X"F0" then
				 state:=S3;
			  end if;
			when S1 =>
			  if dataRdy='1' and data=X"F0" then 
				 state:=S2;
			  end if;
			when S2 =>
			  if dataRdy='1' and data=code then
				 state:=S0;
			  elsif dataRdy='1' and data/=code then
				 state:=S1;
			  end if;
			when S3 =>
			  if dataRdy='1' then
				 state:=S0;
			  end if;
			end case;
		 end if;
 end process;  
		
end Behavioral;

