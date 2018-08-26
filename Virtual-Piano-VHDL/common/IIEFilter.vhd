----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 	Fernando Candelario Herrero
--
-- Create Date:    12:35:15 05/22/2018 
-- Design Name: 
-- Module Name:    IIEFilter - Behavioral 
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

entity IIEFilter is
generic (
    WL : natural;  -- anchura de la muestra
    QM : natural;  -- número de bits decimales en la muestra
    FS : real     -- frecuencia de muestreo
  );
  port(
    rst_n     : in    std_logic;  -- reset asíncrono del sistema (a baja)
    clk       : in    std_logic;  -- reloj del sistema
    ldCode : in    std_logic;  -- elige el multiplexor que usar.
    enRegs  : in    std_logic;  -- outSample and left channel
		inicial : in std_logic_vector(WL-1 downto 0); --inicializacion del registro x
    b1 : in std_logic_vector(WL-1 downto 0);
	outSample : out   std_logic_vector(WL-1 downto 0)   -- muestra de salida
  );
end IIEFilter;

library ieee;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

architecture Behavioral of IIEFilter is

	constant QN : natural := WL-QM;  -- número de bits enteros en la muestra

	constant b2 : signed(WL-1 downto 0) := toFix(-1.0, QN, QM );
	
	signal x, y , sample: signed(WL-1 downto 0);
	signal mulOp1,mulOp2  : signed(2*WL-1 downto 0);
	signal acc  : signed(2*WL-1 downto 0); -- Por el posible acarreo+1
	

begin

	filterFU :
	mulOp1<= x*signed(b1);
	mulOp2<= y*b2;
	
	acc <= mulOp1+mulOp2;
	
	wrapping :
	sample <= acc(QM+WL-1 downto QM);
	
	outSample<=std_logic_vector(sample) ;

	
	filterRegisters :
  process (rst_n, clk)
  begin
    if rst_n='0' then
      x<=(others=>'0');
		y<=(others=>'0');
	elsif rising_edge(clk) then
      if ldCode='1' or enRegs='1' then
        if ldCode='1' then
				x<=signed(inicial);
				y<=(others=>'0');
			elsif ldCode='0' then
				x<=sample;
				y<=x;
		 end if;
      end if;
    end if; 
  end process;
	
	
end Behavioral;

