----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- -- 	Fernando Candelario Herrero
-- Create Date:    12:26:00 05/22/2018 
-- Design Name: 
-- Module Name:    ps2TecladoInterface - Behavioral 
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

entity ps2TecladoInterface is
port(
	rst_n    	: in    std_logic;
   clk        : in    std_logic;
	dataRdy   		: in    std_logic;  -- cuando el dato este disponible
	data		 		: in 	std_logic_vector(7 downto 0); -- dato leido ps2
	teclaPulsada: out std_logic_vector(24 downto 0)
);
end ps2TecladoInterface;

library ieee, unisim;
library ieee;
use ieee.numeric_std.all;
use work.common.all;

architecture Behavioral of ps2TecladoInterface is
	
begin

keyScanner:
  process( rst_n, clk )
    type states is (keyON, keyOFF);
    variable state : states;
    begin
    if rst_n='0' then
      state := keyON;
      teclaPulsada<=(others=>'0');
    elsif rising_edge(clk) then
      if dataRdy='1' then
        case state is
          when keyON =>
            case data is
			  when X"15"=>teclaPulsada(0)<='1';  -- A = DoFA
			  when X"1E"=>teclaPulsada(1)<='1';  -- W = DoFA#
			  when X"1D"=>teclaPulsada(2)<='1';  -- S =ReFA
			  when X"26"=>teclaPulsada(3)<='1';    --E=ReFA#
			  when X"24"=>teclaPulsada(4)<='1';    --D=MiFA
			  when X"2D"=>teclaPulsada(5)<='1';    --F=FaFA         
			  when X"2E"=>teclaPulsada(6)<='1';    --FaFA#         
			  when X"2C"=>teclaPulsada(7)<='1';    --sol        
			  when X"36"=>teclaPulsada(8)<='1';    --solb
			  when X"35"=>teclaPulsada(9)<='1';    --la   
			  when X"3D"=>teclaPulsada(10)<='1';   --lab      
			  when X"3C"=>teclaPulsada(11)<='1';   --si
			  when X"2A"=>teclaPulsada(12)<='1';  -- A = Do
			  when X"34"=>teclaPulsada(13)<='1';  -- W = Do#
			  when X"32"=>teclaPulsada(14)<='1'; -- S =Re
			  when X"33"=>teclaPulsada(15)<='1';	--E=Re#
			  when X"31"=>teclaPulsada(16)<='1';	--D=Mi
			  when X"3A"=>teclaPulsada(17)<='1';	--F=Fa		 
			  when X"42"=>teclaPulsada(18)<='1';	--FaFa#
			  when X"41"=>teclaPulsada(19)<='1';	--sol
			  when X"4B"=>teclaPulsada(20)<='1';   --sol#
			  when X"49"=>teclaPulsada(21)<='1';	--la
			  when X"4C"=>teclaPulsada(22)<='1';   --la#
			  when X"4A"=>teclaPulsada(23)<='1';   --si
			  when X"59"=>teclaPulsada(24)<='1';  --do
           when X"F0" => state := keyOFF;
			  when others => state:=keyON;
              end case;
          when keyOFF =>
            state := keyON;
            case data is
			   when X"15"=>teclaPulsada(0)<='0';  -- A = DoFA
			  when X"1E"=>teclaPulsada(1)<='0';  -- W = DoFA#
			  when X"1D"=>teclaPulsada(2)<='0';  -- S =ReFA
			  when X"26"=>teclaPulsada(3)<='0';    --E=ReFA#
			  when X"24"=>teclaPulsada(4)<='0';    --D=MiFA
			  when X"2D"=>teclaPulsada(5)<='0';    --F=FaFA         
			  when X"2E"=>teclaPulsada(6)<='0';    --FaFA#         
			  when X"2C"=>teclaPulsada(7)<='0';    --sol        
			  when X"36"=>teclaPulsada(8)<='0';    --solb
			  when X"35"=>teclaPulsada(9)<='0';    --la   
			  when X"3D"=>teclaPulsada(10)<='0';   --lab      
			  when X"3C"=>teclaPulsada(11)<='0';   --si
			  when X"2A"=>teclaPulsada(12)<='0';  -- A = Do
			  when X"34"=>teclaPulsada(13)<='0';  -- W = Do#
			  when X"32"=>teclaPulsada(14)<='0'; -- S =Re
			  when X"33"=>teclaPulsada(15)<='0';	--E=Re#
			  when X"31"=>teclaPulsada(16)<='0';	--D=Mi
			  when X"3A"=>teclaPulsada(17)<='0';	--F=Fa		 
			  when X"42"=>teclaPulsada(18)<='0';	--FaFa#
			  when X"41"=>teclaPulsada(19)<='0';	--sol
			  when X"4B"=>teclaPulsada(20)<='0';   --sol#
			  when X"49"=>teclaPulsada(21)<='0';	--la
			  when X"4C"=>teclaPulsada(22)<='0';   --la#
			  when X"4A"=>teclaPulsada(23)<='0';   --si
			  when X"59"=>teclaPulsada(24)<='0';  --do
			  when others => state:=keyON;
            end case;
			end case;
		end if;
	end if;
end process;

end Behavioral;

