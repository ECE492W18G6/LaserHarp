--------------------------------------------------------------------------------------------------------------------------
-- Original Authors : Oliver Rarog						                                                                --
-- Date created: March 11, 2018 													                                    --
--															                                                            --
-- This component is a simple muliplexer for 8 generic vector signals. It takes as an input the 8 signals               --
-- that you want to mux together and also a selection input (sel). The decimal value of the sel correspondes            --
-- to the number of the input that you want to output through data_out. In the entity declaration for this              --
-- component, you must specifiy the size of the input signals, which must all be uniform. If you do not                 --
-- specifiy a size, it is assumed to be 32 bit input and output signals     									        --
--															                                                            --
--------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity Mux8X1 is
	generic (N : Integer := 32);
	port(
		clk 			: in std_logic:= '0'; 		
		sel		:	in std_logic_vector(2 downto 0);
		data_in0	: 	in std_logic_vector(N-1 downto 0); 
		data_in1	: 	in std_logic_vector(N-1 downto 0); 
		data_in2	: 	in std_logic_vector(N-1 downto 0); 
		data_in3	: 	in std_logic_vector(N-1 downto 0); 
		data_in4	: 	in std_logic_vector(N-1 downto 0); 
		data_in5	: 	in std_logic_vector(N-1 downto 0); 
		data_in6	: 	in std_logic_vector(N-1 downto 0); 
		data_in7	: 	in std_logic_vector(N-1 downto 0); 
		data_out	:	out std_logic_vector(N-1 downto 0)
	);
END Mux8X1;

architecture behaviour of Mux8X1 is
begin
process (sel, clk)
begin
  if(rising_edge(clk)) then
	case sel is
		when "000" => data_out <= data_in0;
		when "001" => data_out <= data_in1;
		when "010" => data_out <= data_in2;
		when "011" => data_out <= data_in3;
		when "100" => data_out <= data_in4;
		when "101" => data_out <= data_in5;
		when "110" => data_out <= data_in6;
		when "111" => data_out <= data_in7;
		when others =>
  end case;
 end if;
end process;
end behaviour;
