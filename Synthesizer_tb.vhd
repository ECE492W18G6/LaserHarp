library ieee;
use ieee.std_logic_1164.all;
 
entity Synthesizer_tb is
end Synthesizer_tb;
 
architecture behave of Synthesizer_tb is
	signal clk_SIG	: std_logic := '0';
	signal reset_SIG	: std_logic := '0';
	signal write_SIG	: std_logic := '0';
	signal read_SIG	: std_logic := '0';
	signal frequency 	: std_logic_vector(31 downto 0) := (others => '0');
	signal data		: std_logic_vector(31 downto 0);
   
  component Synthesizer is
	port(
	clk 		: in std_logic; 
	reset 		: in std_logic; 
	write		: in std_logic; 
	read		: in std_logic; 
	phase_reg1 : in std_logic_vector(31 downto 0); 
	data_out1 : out std_logic_vector(31 downto 0));
  end component Synthesizer;
   
begin
   
  Synth : Synthesizer
    port map (
	clk	=> clk_SIG,
	reset	=> reset_SIG,
	write	=> write_SIG,
	read	=> read_SIG,
	phase_reg1	=> frequency,
	data_out1	=> data
	);
 
  process is
  begin
	-- Reset and initialize clock to 0;
	reset_SIG <= '1';
	wait for 10 ns;
	reset_SIG <= '0';
	clk_SIG <= '0';
	wait for 10 ns;
	-- initialize frequency and enable write signal
	frequency <= x"00000001";
	write_SIG <= '1';
	-- toggle clock
	for I in 0 to 6 loop
		clk_SIG <= '1'; -- transition on rising edge
		wait for 10 ns;
		clk_SIG <= '0';
		wait for 10 ns;
	end loop;
	frequency <= x"00000008"; -- change frequency and continue
	-- toggle clock
	for I in 0 to 6 loop
		clk_SIG <= '1'; -- transition on rising edge
		wait for 10 ns;
		clk_SIG <= '0';
		wait for 10 ns;
	end loop;
  end process;
     
end behave;