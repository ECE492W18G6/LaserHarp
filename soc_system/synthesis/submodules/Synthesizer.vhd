-- Original Authors : Simon Doherty, Eric Lunty, Kyle Brooks, Peter Roland
-- Also combined that with the code from http://www.lancasterhunt.co.uk/direct-digital-synthesis-dds-for-idiots-like-me/
-- Additional Authors : Randi Derbyshire, Adam Narten, Oliver Rarog, Celeste Chiasson

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.math_real.all;
use ieee.VITAL_Primitives.all;
use IEEE.STD_LOGIC_SIGNED.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Synthesizer is 

	port(
	clk 			: in std_logic:= '0'; 
	reset 		: in std_logic:= '0'; 
	write		: in std_logic:= '0'; 
	read		: in std_logic:= '0'; 
	
	-- frequnecy input
	phase_reg : in std_logic_vector(31 downto 0) := (others => '0'); 
	-- Sine waveform from laser
	data_out : out std_logic_vector(31 downto 0)
	);
	
end Synthesizer;

architecture full_dds of Synthesizer is

component sin_lut is 

	port (
	clk : in std_logic;
	en		: in std_logic;

	-- take in the values from the phase accumulator.
	address_reg : in std_logic_vector(11 downto 0); 
	sin_out  : out std_logic_vector(31 downto 0)
	);

end component sin_lut;

signal phase_acc : std_logic_vector(31 downto 0);
signal lut_data : std_logic_vector(31 downto 0);
signal lut_data_reg : std_logic_vector(31 downto 0);

begin

dds : process(clk, reset, write)

begin

	if (reset = '1') then
		phase_acc <= x"00000000"; -- reset accumulator.

	elsif (rising_edge(clk)) then 
		if (write = '1') then
			--at every rising edge, we are adding/changing the phase to the accumulator.
			phase_acc <= unsigned(phase_acc) + unsigned(phase_reg);
		end if;
	end if;

end process dds;

---------------------------------------------------------------------
-- use bottom 12-bits of phase accumulator to address the SIN LUT --
---------------------------------------------------------------------
lut_data <= phase_acc;

----------------------------------------------------------------------
-- SIN LUT is 4096 by 12-bit ROM                                    --
-- 12-bit output allows sin amplitudes between 2047 and -2047       --
-- (-2048 not used to keep the output signal perfectly symmetrical) --
-- Phase resolution is 2Pi/4096 = 0.088 degrees                     --
----------------------------------------------------------------------
lut: component sin_lut  port map (
		clk       => clk,
		en        => write,
    	address_reg      => lut_data(11 downto 0),
		sin_out 	=> data_out
 );

---------------------------------
-- Hide the latency of the LUT --
---------------------------------
delay_regs: process(clk, write)
begin
  if (rising_edge(clk)) then
		if (write = '1') then
			lut_data_reg <= lut_data;
		end if;
	end if;
end process delay_regs;

end full_dds;