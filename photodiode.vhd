-- Original Author: Adam Narten
-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity photodiode is
	port (
		avalon_slave_read_n   : in  std_logic                     := '0'; -- avalon_slave.read_n
		avalon_slave_readdata : out std_logic_vector(7 downto 0);        --             .readdata
		conduit_end		      : in  std_logic                     := '0'; --  conduit_end.export
		clk                   : in  std_logic                     := '0'; --        clock.clk
		reset_n               : in  std_logic                     := '0'  --        reset.reset_n
	);
end entity photodiode;

architecture rtl of photodiode is
begin
	process(reset_n, conduit_end) is
	
	begin
	if (reset_n = '0') then
		avalon_slave_readdata <= x"00";
	elsif (conduit_end'event and conduit_end = '0') then
		avalon_slave_readdata <= x"ff";
	elsif (conduit_end'event and conduit_end = '1') then
	end if;
	end process ;
	

end architecture rtl; -- of photodiode
