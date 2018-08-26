----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 	Fernando Candelario Herrero
--	
-- Create Date:    14:22:05 05/10/2018 
-- Design Name: 
-- Module Name:    Teclado - Behavioral 
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
--	
--
--DOFA	0											
--rebFA ,1											
--reFA,	2											
--mibFA, 3											 
--miFA,	4											
--faFA,	5											
--solbFA,6																						
--solFA,7											
--labFA,8											
--laFA,	9											
--sibFA,10																				
--siFA,11 			 								


--Octave
--DO	13											
--reb, 14											
--re,	15											
--mib,  16											 
--mi,	17											
--fa,	18											
--solb, 19																						
--sol,  20											
--lab, 21										
--la,	22											
--sib,  23																				
--si,  24 			 								
--DO1  25


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

entity Teclado is 
port(
    rstPb_n    : in    std_logic;
    osc        : in    std_logic;
	 --PS2 signals
	 ps2Clk  : in  std_logic;
    ps2Data : in  std_logic;
	 --IIS signals
	 mclk       : out   std_logic;
    sclk       : out   std_logic;
    lrck       : out   std_logic;
    sdti       : out   std_logic;
	 sdto       : in    std_logic;
	 --InfoSignals
	 leds       : out std_logic_vector(7 downto 0);
	 rightSegs	: out std_logic_vector(7 downto 0); 
	 leftSegs	: out std_logic_vector(7 downto 0);
	 --VGA signals
	 hSync   	: out std_logic;
    vSync   	: out std_logic;
    RGB     	: out std_logic_vector(8 downto 0)
  );
end Teclado;

library ieee, unisim;
library ieee;
use ieee.numeric_std.all;
use unisim.vcomponents.all;
use work.common.all;

architecture Behavioral of Teclado is
	                                                                                                                               
	signal teclaPulsada : std_logic_vector(24 downto 0);--flags para saber si la nota esta siendo pulsada.
	signal clk, rst_n,dataRdy,outSampleRqt,leftChannel,working1,working2,working3 ,working4,en3,en2,en1,en4,en4Aux,en3Aux,check1,check2,check3,check4 : std_logic;
	
	signal outFilterSample1,outFilterSample2,outFilterSample3,outFilterSample4 : std_logic_vector(15 downto 0);
	signal data,usingCode1,usingCode2,usingCode3,usingCode4 : std_logic_vector(7 downto 0);
	
	
	signal sumSamples12,sumSamples34 : signed(16 downto 0);
	signal finalSumSamples : signed(17 downto 0);
begin
	clk <= osc;
	
	 resetSyncronizer : synchronizer
    generic map ( STAGES => 2, INIT => '0' )
    port map ( rst_n => rstPb_n, clk => clk, x => '1', xSync => rst_n );
--------------------------------------------------------------------------



  ps2KeyboardInterface : ps2Receiver
    generic map ( REGOUTPUTS => true )
    port map ( rst_n=>rst_n, clk=>clk, dataRdy=>dataRdy , data=>data, ps2Clk =>ps2Clk, ps2Data=>ps2Data);
-----------------------------------------------------------------------------------------------------------




	keyScannet : ps2TecladoInterface
	port map (rst_n =>rst_n, clk=>clk, dataRdy=>dataRdy, data=>data, teclaPulsada=>teclaPulsada);
------------------------------------------------------------------------------------------------------	  


	Graphics : vgaTecladoInterface
	port map (rst_n =>rst_n, clk=>clk,teclaPulsada=>teclaPulsada, hSync=>hSync, vSync=>vSync, RGB=>RGB);
-------------------------------------------------------------------------------------------------------------
--
	check4<= '1' when (usingCode4/=data and working4='1')else '0';
	check3<= '1' when (usingCode3/=data and working3='1')else '0';
	check2<= '1' when (usingCode2/=data and working2='1')else '0';
	check1<= '1' when (usingCode1/=data and working1='1')else '0';
---

	en1<='1' when (dataRdy='1' and ( (check2='1' or working2='0') and (check3='1' or working3='0') and (check4='1' or working4='0'))) else '0';
	
	codeReceiver1 : TecladoCodeReceiver 
	 generic map( WL =>16, QM=>14,FS=>48828.0)
	 port map(rst_n =>rst_n,clk=>clk,dataRdy=>dataRdy,data=>data,outSampleRqt=>outSampleRqt,leftChannel=>leftChannel,en=>en1,working =>working1,usingCode=>usingCode1,sample=>outFilterSample1);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

	en2<='1' when( working1='1' and dataRdy='1' and (check1='1' and (check3='1' or working3='0') and (check4='1' or working4='0')) ) else '0';


	codeReceiver2 : TecladoCodeReceiver 
		 generic map( WL =>16, QM=>14,FS=>48828.0)
		 port map(rst_n =>rst_n,clk=>clk,dataRdy=>dataRdy,data=>data,outSampleRqt=>outSampleRqt,leftChannel=>leftChannel,en=>en2,working =>working2,usingCode=>usingCode2,sample=>outFilterSample2);
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	en3Aux<= '1' when working1='1' and working2='1' else'0';
	

	en3<='1' when (en3Aux='1' and dataRdy='1' and (check1='1' and check2='1' and (check4='1'  or working4='0')) ) else '0';


	codeReceiver3 : TecladoCodeReceiver 
		 generic map( WL =>16, QM=>14,FS=>48828.0)
		 port map(rst_n =>rst_n,clk=>clk,dataRdy=>dataRdy,data=>data,outSampleRqt=>outSampleRqt,leftChannel=>leftChannel,en=>en3,working =>working3,usingCode=>usingCode3,sample=>outFilterSample3);
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	en4Aux<= '1' when working1='1' and working2='1' and working3='1'  else'0';
	
	
	en4<='1' when ( en4Aux='1' and dataRdy='1' and (check1='1' and check2='1' and check3='1') ) else '0';

	codeReceiver4 : TecladoCodeReceiver 
	 generic map( WL =>16, QM=>14,FS=>48828.0)
	 port map(rst_n =>rst_n,clk=>clk,dataRdy=>dataRdy,data=>data,outSampleRqt=>outSampleRqt,leftChannel=>leftChannel,en=>en4,working =>working4,usingCode=>usingCode4,sample=>outFilterSample4);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

	leds<= "0000" & working4 & working3 & working2 & working1 ;
	
	leftConverter : bin2segs 
    port map ( bin =>data(7 downto 4), dp => '0', segs =>leftSegs  );
  
  rigthConverter : bin2segs 
    port map ( bin =>data(3 downto 0), dp => '0', segs =>rightSegs );
	 
--Final sum segmented.	
	sumSamples12Register:
	  process (rst_n, clk)
	  begin
		 if rst_n='0' then
			sumSamples12<=(others=>'0');
		 elsif rising_edge(clk) then
			sumSamples12<=signed(outFilterSample1(15) & outFilterSample1) + signed(outFilterSample2(15) & outFilterSample2);
		end if;
	  end process;
	  
	sumSamples34Register :
	  process (rst_n, clk)
	  begin
		 if rst_n='0' then
			sumSamples34<=(others=>'0');
		 elsif rising_edge(clk) then
			sumSamples34<=signed(outFilterSample3(15) & outFilterSample3) + signed(outFilterSample4(15) & outFilterSample4);
		end if;
	  end process;
	  
	finalSumSamplesRegister :
	  process (rst_n, clk)
	  begin
		 if rst_n='0' then
			finalSumSamples<=(others=>'0');
		 elsif rising_edge(clk) then
			finalSumSamples<=signed(sumSamples12(16) & sumSamples12) + signed(sumSamples34(16) & sumSamples34);
		end if;
	  end process;
	  
	codecInterface : iisInterface
		 generic map( WIDTH => 16 ) 
		 port map( 
			rst_n => rst_n, clk => clk, 
			leftChannel => leftChannel, inSample => open, inSampleRdy => open, outSample => std_logic_vector(finalSumSamples(17 downto 2)), outSampleRqt => outSampleRqt,
			mclk => mclk, sclk => sclk, lrck => lrck, sdti => sdti, sdto => sdto
		 );
-----------------------------------------------------------------------------------------------------------------------------------------------------
end Behavioral;

