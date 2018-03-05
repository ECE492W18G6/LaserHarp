-- Original Author : Simon Doherty, Eric Lunty, Kyle Brooks, Peter Roland
-- Additional Authors : Randi Derbyshire, Adam Narten, Oliver Rarog, Celeste Chiasson

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity sin_lut is

port (
	clk      : in  std_logic;
	en       : in  std_logic;
	
	--Address input
	address_reg : in std_logic_vector(11 downto 0); 
	
	--Sine value output
	sin_out  : out std_logic_vector(31 downto 0)
	);
end entity;


architecture rtl of sin_lut is


type rom_type is array (0 to 4095) of std_logic_vector (11 downto 0);

constant SIN_ROM : rom_type :=

(
X"000", X"003", X"006", X"009", X"00d", X"010", X"013", X"016", 
X"019", X"01c", X"01f", X"023", X"026", X"029", X"02c", X"02f", 
X"032", X"035", X"039", X"03c", X"03f", X"042", X"045", X"048", 
X"04b", X"04e", X"052", X"055", X"058", X"05b", X"05e", X"061", 
X"064", X"068", X"06b", X"06e", X"071", X"074", X"077", X"07a", 
X"07e", X"081", X"084", X"087", X"08a", X"08d", X"090", X"093", 
X"097", X"09a", X"09d", X"0a0", X"0a3", X"0a6", X"0a9", X"0ac", 
X"0b0", X"0b3", X"0b6", X"0b9", X"0bc", X"0bf", X"0c2", X"0c6", 
X"0c9", X"0cc", X"0cf", X"0d2", X"0d5", X"0d8", X"0db", X"0df", 
X"0e2", X"0e5", X"0e8", X"0eb", X"0ee", X"0f1", X"0f4", X"0f7", 
X"0fb", X"0fe", X"101", X"104", X"107", X"10a", X"10d", X"110", 
X"113", X"117", X"11a", X"11d", X"120", X"123", X"126", X"129", 
X"12c", X"12f", X"133", X"136", X"139", X"13c", X"13f", X"142", 
X"145", X"148", X"14b", X"14e", X"152", X"155", X"158", X"15b", 
X"15e", X"161", X"164", X"167", X"16a", X"16d", X"171", X"174", 
X"177", X"17a", X"17d", X"180", X"183", X"186", X"189", X"18c", 
X"18f", X"192", X"196", X"199", X"19c", X"19f", X"1a2", X"1a5", 
X"1a8", X"1ab", X"1ae", X"1b1", X"1b4", X"1b7", X"1ba", X"1bd", 
X"1c1", X"1c4", X"1c7", X"1ca", X"1cd", X"1d0", X"1d3", X"1d6", 
X"1d9", X"1dc", X"1df", X"1e2", X"1e5", X"1e8", X"1eb", X"1ee", 
X"1f1", X"1f4", X"1f7", X"1fb", X"1fe", X"201", X"204", X"207", 
X"20a", X"20d", X"210", X"213", X"216", X"219", X"21c", X"21f", 
X"222", X"225", X"228", X"22b", X"22e", X"231", X"234", X"237", 
X"23a", X"23d", X"240", X"243", X"246", X"249", X"24c", X"24f", 
X"252", X"255", X"258", X"25b", X"25e", X"261", X"264", X"267", 
X"26a", X"26d", X"270", X"273", X"276", X"279", X"27c", X"27f", 
X"282", X"285", X"288", X"28b", X"28e", X"291", X"294", X"297", 
X"29a", X"29d", X"2a0", X"2a3", X"2a6", X"2a9", X"2ac", X"2af", 
X"2b2", X"2b5", X"2b8", X"2ba", X"2bd", X"2c0", X"2c3", X"2c6", 
X"2c9", X"2cc", X"2cf", X"2d2", X"2d5", X"2d8", X"2db", X"2de", 
X"2e1", X"2e4", X"2e7", X"2e9", X"2ec", X"2ef", X"2f2", X"2f5", 
X"2f8", X"2fb", X"2fe", X"301", X"304", X"307", X"30a", X"30c", 
X"30f", X"312", X"315", X"318", X"31b", X"31e", X"321", X"324", 
X"327", X"329", X"32c", X"32f", X"332", X"335", X"338", X"33b", 
X"33e", X"340", X"343", X"346", X"349", X"34c", X"34f", X"352", 
X"354", X"357", X"35a", X"35d", X"360", X"363", X"366", X"368", 
X"36b", X"36e", X"371", X"374", X"377", X"379", X"37c", X"37f", 
X"382", X"385", X"387", X"38a", X"38d", X"390", X"393", X"396", 
X"398", X"39b", X"39e", X"3a1", X"3a4", X"3a6", X"3a9", X"3ac", 
X"3af", X"3b2", X"3b4", X"3b7", X"3ba", X"3bd", X"3bf", X"3c2", 
X"3c5", X"3c8", X"3ca", X"3cd", X"3d0", X"3d3", X"3d6", X"3d8", 
X"3db", X"3de", X"3e1", X"3e3", X"3e6", X"3e9", X"3eb", X"3ee", 
X"3f1", X"3f4", X"3f6", X"3f9", X"3fc", X"3ff", X"401", X"404", 
X"407", X"409", X"40c", X"40f", X"412", X"414", X"417", X"41a", 
X"41c", X"41f", X"422", X"424", X"427", X"42a", X"42c", X"42f", 
X"432", X"435", X"437", X"43a", X"43d", X"43f", X"442", X"444", 
X"447", X"44a", X"44c", X"44f", X"452", X"454", X"457", X"45a", 
X"45c", X"45f", X"462", X"464", X"467", X"469", X"46c", X"46f", 
X"471", X"474", X"476", X"479", X"47c", X"47e", X"481", X"483", 
X"486", X"489", X"48b", X"48e", X"490", X"493", X"496", X"498", 
X"49b", X"49d", X"4a0", X"4a2", X"4a5", X"4a7", X"4aa", X"4ad", 
X"4af", X"4b2", X"4b4", X"4b7", X"4b9", X"4bc", X"4be", X"4c1", 
X"4c3", X"4c6", X"4c8", X"4cb", X"4cd", X"4d0", X"4d2", X"4d5", 
X"4d7", X"4da", X"4dc", X"4df", X"4e1", X"4e4", X"4e6", X"4e9", 
X"4eb", X"4ee", X"4f0", X"4f3", X"4f5", X"4f8", X"4fa", X"4fd", 
X"4ff", X"502", X"504", X"506", X"509", X"50b", X"50e", X"510", 
X"513", X"515", X"517", X"51a", X"51c", X"51f", X"521", X"524", 
X"526", X"528", X"52b", X"52d", X"530", X"532", X"534", X"537", 
X"539", X"53b", X"53e", X"540", X"543", X"545", X"547", X"54a", 
X"54c", X"54e", X"551", X"553", X"555", X"558", X"55a", X"55c", 
X"55f", X"561", X"563", X"566", X"568", X"56a", X"56d", X"56f", 
X"571", X"573", X"576", X"578", X"57a", X"57d", X"57f", X"581", 
X"583", X"586", X"588", X"58a", X"58d", X"58f", X"591", X"593", 
X"596", X"598", X"59a", X"59c", X"59f", X"5a1", X"5a3", X"5a5", 
X"5a7", X"5aa", X"5ac", X"5ae", X"5b0", X"5b3", X"5b5", X"5b7", 
X"5b9", X"5bb", X"5bd", X"5c0", X"5c2", X"5c4", X"5c6", X"5c8", 
X"5cb", X"5cd", X"5cf", X"5d1", X"5d3", X"5d5", X"5d7", X"5da", 
X"5dc", X"5de", X"5e0", X"5e2", X"5e4", X"5e6", X"5e9", X"5eb", 
X"5ed", X"5ef", X"5f1", X"5f3", X"5f5", X"5f7", X"5f9", X"5fb", 
X"5fd", X"600", X"602", X"604", X"606", X"608", X"60a", X"60c", 
X"60e", X"610", X"612", X"614", X"616", X"618", X"61a", X"61c", 
X"61e", X"620", X"622", X"624", X"626", X"628", X"62a", X"62c", 
X"62e", X"630", X"632", X"634", X"636", X"638", X"63a", X"63c", 
X"63e", X"640", X"642", X"644", X"646", X"648", X"64a", X"64c", 
X"64e", X"650", X"652", X"654", X"655", X"657", X"659", X"65b", 
X"65d", X"65f", X"661", X"663", X"665", X"667", X"668", X"66a", 
X"66c", X"66e", X"670", X"672", X"674", X"675", X"677", X"679", 
X"67b", X"67d", X"67f", X"681", X"682", X"684", X"686", X"688", 
X"68a", X"68b", X"68d", X"68f", X"691", X"693", X"694", X"696", 
X"698", X"69a", X"69b", X"69d", X"69f", X"6a1", X"6a3", X"6a4", 
X"6a6", X"6a8", X"6a9", X"6ab", X"6ad", X"6af", X"6b0", X"6b2", 
X"6b4", X"6b6", X"6b7", X"6b9", X"6bb", X"6bc", X"6be", X"6c0", 
X"6c1", X"6c3", X"6c5", X"6c6", X"6c8", X"6ca", X"6cb", X"6cd", 
X"6cf", X"6d0", X"6d2", X"6d4", X"6d5", X"6d7", X"6d9", X"6da", 
X"6dc", X"6dd", X"6df", X"6e1", X"6e2", X"6e4", X"6e5", X"6e7", 
X"6e9", X"6ea", X"6ec", X"6ed", X"6ef", X"6f0", X"6f2", X"6f4", 
X"6f5", X"6f7", X"6f8", X"6fa", X"6fb", X"6fd", X"6fe", X"700", 
X"701", X"703", X"704", X"706", X"707", X"709", X"70a", X"70c", 
X"70d", X"70f", X"710", X"712", X"713", X"715", X"716", X"718", 
X"719", X"71a", X"71c", X"71d", X"71f", X"720", X"722", X"723", 
X"724", X"726", X"727", X"729", X"72a", X"72b", X"72d", X"72e", 
X"730", X"731", X"732", X"734", X"735", X"736", X"738", X"739", 
X"73a", X"73c", X"73d", X"73e", X"740", X"741", X"742", X"744", 
X"745", X"746", X"748", X"749", X"74a", X"74c", X"74d", X"74e", 
X"74f", X"751", X"752", X"753", X"754", X"756", X"757", X"758", 
X"759", X"75b", X"75c", X"75d", X"75e", X"760", X"761", X"762", 
X"763", X"764", X"766", X"767", X"768", X"769", X"76a", X"76b", 
X"76d", X"76e", X"76f", X"770", X"771", X"772", X"774", X"775", 
X"776", X"777", X"778", X"779", X"77a", X"77b", X"77d", X"77e", 
X"77f", X"780", X"781", X"782", X"783", X"784", X"785", X"786", 
X"787", X"788", X"789", X"78a", X"78c", X"78d", X"78e", X"78f", 
X"790", X"791", X"792", X"793", X"794", X"795", X"796", X"797", 
X"798", X"799", X"79a", X"79b", X"79c", X"79d", X"79e", X"79e", 
X"79f", X"7a0", X"7a1", X"7a2", X"7a3", X"7a4", X"7a5", X"7a6", 
X"7a7", X"7a8", X"7a9", X"7aa", X"7aa", X"7ab", X"7ac", X"7ad", 
X"7ae", X"7af", X"7b0", X"7b1", X"7b1", X"7b2", X"7b3", X"7b4", 
X"7b5", X"7b6", X"7b7", X"7b7", X"7b8", X"7b9", X"7ba", X"7bb", 
X"7bb", X"7bc", X"7bd", X"7be", X"7bf", X"7bf", X"7c0", X"7c1", 
X"7c2", X"7c2", X"7c3", X"7c4", X"7c5", X"7c5", X"7c6", X"7c7", 
X"7c8", X"7c8", X"7c9", X"7ca", X"7ca", X"7cb", X"7cc", X"7cd", 
X"7cd", X"7ce", X"7cf", X"7cf", X"7d0", X"7d1", X"7d1", X"7d2", 
X"7d3", X"7d3", X"7d4", X"7d5", X"7d5", X"7d6", X"7d6", X"7d7", 
X"7d8", X"7d8", X"7d9", X"7d9", X"7da", X"7db", X"7db", X"7dc", 
X"7dc", X"7dd", X"7de", X"7de", X"7df", X"7df", X"7e0", X"7e0", 
X"7e1", X"7e1", X"7e2", X"7e2", X"7e3", X"7e3", X"7e4", X"7e5", 
X"7e5", X"7e6", X"7e6", X"7e6", X"7e7", X"7e7", X"7e8", X"7e8", 
X"7e9", X"7e9", X"7ea", X"7ea", X"7eb", X"7eb", X"7ec", X"7ec", 
X"7ec", X"7ed", X"7ed", X"7ee", X"7ee", X"7ee", X"7ef", X"7ef", 
X"7f0", X"7f0", X"7f0", X"7f1", X"7f1", X"7f1", X"7f2", X"7f2", 
X"7f3", X"7f3", X"7f3", X"7f4", X"7f4", X"7f4", X"7f5", X"7f5", 
X"7f5", X"7f5", X"7f6", X"7f6", X"7f6", X"7f7", X"7f7", X"7f7", 
X"7f7", X"7f8", X"7f8", X"7f8", X"7f8", X"7f9", X"7f9", X"7f9", 
X"7f9", X"7fa", X"7fa", X"7fa", X"7fa", X"7fb", X"7fb", X"7fb", 
X"7fb", X"7fb", X"7fc", X"7fc", X"7fc", X"7fc", X"7fc", X"7fc", 
X"7fd", X"7fd", X"7fd", X"7fd", X"7fd", X"7fd", X"7fd", X"7fd", 
X"7fe", X"7fe", X"7fe", X"7fe", X"7fe", X"7fe", X"7fe", X"7fe", 
X"7fe", X"7fe", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", 
X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", 
X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", 
X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7ff", X"7fe", 
X"7fe", X"7fe", X"7fe", X"7fe", X"7fe", X"7fe", X"7fe", X"7fe", 
X"7fe", X"7fd", X"7fd", X"7fd", X"7fd", X"7fd", X"7fd", X"7fd", 
X"7fd", X"7fc", X"7fc", X"7fc", X"7fc", X"7fc", X"7fc", X"7fb", 
X"7fb", X"7fb", X"7fb", X"7fb", X"7fa", X"7fa", X"7fa", X"7fa", 
X"7f9", X"7f9", X"7f9", X"7f9", X"7f8", X"7f8", X"7f8", X"7f8", 
X"7f7", X"7f7", X"7f7", X"7f7", X"7f6", X"7f6", X"7f6", X"7f5", 
X"7f5", X"7f5", X"7f5", X"7f4", X"7f4", X"7f4", X"7f3", X"7f3", 
X"7f3", X"7f2", X"7f2", X"7f1", X"7f1", X"7f1", X"7f0", X"7f0", 
X"7f0", X"7ef", X"7ef", X"7ee", X"7ee", X"7ee", X"7ed", X"7ed", 
X"7ec", X"7ec", X"7ec", X"7eb", X"7eb", X"7ea", X"7ea", X"7e9", 
X"7e9", X"7e8", X"7e8", X"7e7", X"7e7", X"7e6", X"7e6", X"7e6", 
X"7e5", X"7e5", X"7e4", X"7e3", X"7e3", X"7e2", X"7e2", X"7e1", 
X"7e1", X"7e0", X"7e0", X"7df", X"7df", X"7de", X"7de", X"7dd", 
X"7dc", X"7dc", X"7db", X"7db", X"7da", X"7d9", X"7d9", X"7d8", 
X"7d8", X"7d7", X"7d6", X"7d6", X"7d5", X"7d5", X"7d4", X"7d3", 
X"7d3", X"7d2", X"7d1", X"7d1", X"7d0", X"7cf", X"7cf", X"7ce", 
X"7cd", X"7cd", X"7cc", X"7cb", X"7ca", X"7ca", X"7c9", X"7c8", 
X"7c8", X"7c7", X"7c6", X"7c5", X"7c5", X"7c4", X"7c3", X"7c2", 
X"7c2", X"7c1", X"7c0", X"7bf", X"7bf", X"7be", X"7bd", X"7bc", 
X"7bb", X"7bb", X"7ba", X"7b9", X"7b8", X"7b7", X"7b7", X"7b6", 
X"7b5", X"7b4", X"7b3", X"7b2", X"7b1", X"7b1", X"7b0", X"7af", 
X"7ae", X"7ad", X"7ac", X"7ab", X"7aa", X"7aa", X"7a9", X"7a8", 
X"7a7", X"7a6", X"7a5", X"7a4", X"7a3", X"7a2", X"7a1", X"7a0", 
X"79f", X"79e", X"79e", X"79d", X"79c", X"79b", X"79a", X"799", 
X"798", X"797", X"796", X"795", X"794", X"793", X"792", X"791", 
X"790", X"78f", X"78e", X"78d", X"78c", X"78a", X"789", X"788", 
X"787", X"786", X"785", X"784", X"783", X"782", X"781", X"780", 
X"77f", X"77e", X"77d", X"77b", X"77a", X"779", X"778", X"777", 
X"776", X"775", X"774", X"772", X"771", X"770", X"76f", X"76e", 
X"76d", X"76b", X"76a", X"769", X"768", X"767", X"766", X"764", 
X"763", X"762", X"761", X"760", X"75e", X"75d", X"75c", X"75b", 
X"759", X"758", X"757", X"756", X"754", X"753", X"752", X"751", 
X"74f", X"74e", X"74d", X"74c", X"74a", X"749", X"748", X"746", 
X"745", X"744", X"742", X"741", X"740", X"73e", X"73d", X"73c", 
X"73a", X"739", X"738", X"736", X"735", X"734", X"732", X"731", 
X"730", X"72e", X"72d", X"72b", X"72a", X"729", X"727", X"726", 
X"724", X"723", X"722", X"720", X"71f", X"71d", X"71c", X"71a", 
X"719", X"718", X"716", X"715", X"713", X"712", X"710", X"70f", 
X"70d", X"70c", X"70a", X"709", X"707", X"706", X"704", X"703", 
X"701", X"700", X"6fe", X"6fd", X"6fb", X"6fa", X"6f8", X"6f7", 
X"6f5", X"6f4", X"6f2", X"6f0", X"6ef", X"6ed", X"6ec", X"6ea", 
X"6e9", X"6e7", X"6e5", X"6e4", X"6e2", X"6e1", X"6df", X"6dd", 
X"6dc", X"6da", X"6d9", X"6d7", X"6d5", X"6d4", X"6d2", X"6d0", 
X"6cf", X"6cd", X"6cb", X"6ca", X"6c8", X"6c6", X"6c5", X"6c3", 
X"6c1", X"6c0", X"6be", X"6bc", X"6bb", X"6b9", X"6b7", X"6b6", 
X"6b4", X"6b2", X"6b0", X"6af", X"6ad", X"6ab", X"6a9", X"6a8", 
X"6a6", X"6a4", X"6a3", X"6a1", X"69f", X"69d", X"69b", X"69a", 
X"698", X"696", X"694", X"693", X"691", X"68f", X"68d", X"68b", 
X"68a", X"688", X"686", X"684", X"682", X"681", X"67f", X"67d", 
X"67b", X"679", X"677", X"675", X"674", X"672", X"670", X"66e", 
X"66c", X"66a", X"668", X"667", X"665", X"663", X"661", X"65f", 
X"65d", X"65b", X"659", X"657", X"655", X"654", X"652", X"650", 
X"64e", X"64c", X"64a", X"648", X"646", X"644", X"642", X"640", 
X"63e", X"63c", X"63a", X"638", X"636", X"634", X"632", X"630", 
X"62e", X"62c", X"62a", X"628", X"626", X"624", X"622", X"620", 
X"61e", X"61c", X"61a", X"618", X"616", X"614", X"612", X"610", 
X"60e", X"60c", X"60a", X"608", X"606", X"604", X"602", X"600", 
X"5fd", X"5fb", X"5f9", X"5f7", X"5f5", X"5f3", X"5f1", X"5ef", 
X"5ed", X"5eb", X"5e9", X"5e6", X"5e4", X"5e2", X"5e0", X"5de", 
X"5dc", X"5da", X"5d7", X"5d5", X"5d3", X"5d1", X"5cf", X"5cd", 
X"5cb", X"5c8", X"5c6", X"5c4", X"5c2", X"5c0", X"5bd", X"5bb", 
X"5b9", X"5b7", X"5b5", X"5b3", X"5b0", X"5ae", X"5ac", X"5aa", 
X"5a7", X"5a5", X"5a3", X"5a1", X"59f", X"59c", X"59a", X"598", 
X"596", X"593", X"591", X"58f", X"58d", X"58a", X"588", X"586", 
X"583", X"581", X"57f", X"57d", X"57a", X"578", X"576", X"573", 
X"571", X"56f", X"56d", X"56a", X"568", X"566", X"563", X"561", 
X"55f", X"55c", X"55a", X"558", X"555", X"553", X"551", X"54e", 
X"54c", X"54a", X"547", X"545", X"543", X"540", X"53e", X"53b", 
X"539", X"537", X"534", X"532", X"530", X"52d", X"52b", X"528", 
X"526", X"524", X"521", X"51f", X"51c", X"51a", X"517", X"515", 
X"513", X"510", X"50e", X"50b", X"509", X"506", X"504", X"502", 
X"4ff", X"4fd", X"4fa", X"4f8", X"4f5", X"4f3", X"4f0", X"4ee", 
X"4eb", X"4e9", X"4e6", X"4e4", X"4e1", X"4df", X"4dc", X"4da", 
X"4d7", X"4d5", X"4d2", X"4d0", X"4cd", X"4cb", X"4c8", X"4c6", 
X"4c3", X"4c1", X"4be", X"4bc", X"4b9", X"4b7", X"4b4", X"4b2", 
X"4af", X"4ad", X"4aa", X"4a7", X"4a5", X"4a2", X"4a0", X"49d", 
X"49b", X"498", X"496", X"493", X"490", X"48e", X"48b", X"489", 
X"486", X"483", X"481", X"47e", X"47c", X"479", X"476", X"474", 
X"471", X"46f", X"46c", X"469", X"467", X"464", X"462", X"45f", 
X"45c", X"45a", X"457", X"454", X"452", X"44f", X"44c", X"44a", 
X"447", X"444", X"442", X"43f", X"43d", X"43a", X"437", X"435", 
X"432", X"42f", X"42c", X"42a", X"427", X"424", X"422", X"41f", 
X"41c", X"41a", X"417", X"414", X"412", X"40f", X"40c", X"409", 
X"407", X"404", X"401", X"3ff", X"3fc", X"3f9", X"3f6", X"3f4", 
X"3f1", X"3ee", X"3eb", X"3e9", X"3e6", X"3e3", X"3e1", X"3de", 
X"3db", X"3d8", X"3d6", X"3d3", X"3d0", X"3cd", X"3ca", X"3c8", 
X"3c5", X"3c2", X"3bf", X"3bd", X"3ba", X"3b7", X"3b4", X"3b2", 
X"3af", X"3ac", X"3a9", X"3a6", X"3a4", X"3a1", X"39e", X"39b", 
X"398", X"396", X"393", X"390", X"38d", X"38a", X"387", X"385", 
X"382", X"37f", X"37c", X"379", X"377", X"374", X"371", X"36e", 
X"36b", X"368", X"366", X"363", X"360", X"35d", X"35a", X"357", 
X"354", X"352", X"34f", X"34c", X"349", X"346", X"343", X"340", 
X"33e", X"33b", X"338", X"335", X"332", X"32f", X"32c", X"329", 
X"327", X"324", X"321", X"31e", X"31b", X"318", X"315", X"312", 
X"30f", X"30c", X"30a", X"307", X"304", X"301", X"2fe", X"2fb", 
X"2f8", X"2f5", X"2f2", X"2ef", X"2ec", X"2e9", X"2e7", X"2e4", 
X"2e1", X"2de", X"2db", X"2d8", X"2d5", X"2d2", X"2cf", X"2cc", 
X"2c9", X"2c6", X"2c3", X"2c0", X"2bd", X"2ba", X"2b8", X"2b5", 
X"2b2", X"2af", X"2ac", X"2a9", X"2a6", X"2a3", X"2a0", X"29d", 
X"29a", X"297", X"294", X"291", X"28e", X"28b", X"288", X"285", 
X"282", X"27f", X"27c", X"279", X"276", X"273", X"270", X"26d", 
X"26a", X"267", X"264", X"261", X"25e", X"25b", X"258", X"255", 
X"252", X"24f", X"24c", X"249", X"246", X"243", X"240", X"23d", 
X"23a", X"237", X"234", X"231", X"22e", X"22b", X"228", X"225", 
X"222", X"21f", X"21c", X"219", X"216", X"213", X"210", X"20d", 
X"20a", X"207", X"204", X"201", X"1fe", X"1fb", X"1f7", X"1f4", 
X"1f1", X"1ee", X"1eb", X"1e8", X"1e5", X"1e2", X"1df", X"1dc", 
X"1d9", X"1d6", X"1d3", X"1d0", X"1cd", X"1ca", X"1c7", X"1c4", 
X"1c1", X"1bd", X"1ba", X"1b7", X"1b4", X"1b1", X"1ae", X"1ab", 
X"1a8", X"1a5", X"1a2", X"19f", X"19c", X"199", X"196", X"192", 
X"18f", X"18c", X"189", X"186", X"183", X"180", X"17d", X"17a", 
X"177", X"174", X"171", X"16d", X"16a", X"167", X"164", X"161", 
X"15e", X"15b", X"158", X"155", X"152", X"14e", X"14b", X"148", 
X"145", X"142", X"13f", X"13c", X"139", X"136", X"133", X"12f", 
X"12c", X"129", X"126", X"123", X"120", X"11d", X"11a", X"117", 
X"113", X"110", X"10d", X"10a", X"107", X"104", X"101", X"0fe", 
X"0fb", X"0f7", X"0f4", X"0f1", X"0ee", X"0eb", X"0e8", X"0e5", 
X"0e2", X"0df", X"0db", X"0d8", X"0d5", X"0d2", X"0cf", X"0cc", 
X"0c9", X"0c6", X"0c2", X"0bf", X"0bc", X"0b9", X"0b6", X"0b3", 
X"0b0", X"0ac", X"0a9", X"0a6", X"0a3", X"0a0", X"09d", X"09a", 
X"097", X"093", X"090", X"08d", X"08a", X"087", X"084", X"081", 
X"07e", X"07a", X"077", X"074", X"071", X"06e", X"06b", X"068", 
X"064", X"061", X"05e", X"05b", X"058", X"055", X"052", X"04e", 
X"04b", X"048", X"045", X"042", X"03f", X"03c", X"039", X"035", 
X"032", X"02f", X"02c", X"029", X"026", X"023", X"01f", X"01c", 
X"019", X"016", X"013", X"010", X"00d", X"009", X"006", X"003", 
X"000", X"ffd", X"ffa", X"ff7", X"ff3", X"ff0", X"fed", X"fea", 
X"fe7", X"fe4", X"fe1", X"fdd", X"fda", X"fd7", X"fd4", X"fd1", 
X"fce", X"fcb", X"fc7", X"fc4", X"fc1", X"fbe", X"fbb", X"fb8", 
X"fb5", X"fb2", X"fae", X"fab", X"fa8", X"fa5", X"fa2", X"f9f", 
X"f9c", X"f98", X"f95", X"f92", X"f8f", X"f8c", X"f89", X"f86", 
X"f82", X"f7f", X"f7c", X"f79", X"f76", X"f73", X"f70", X"f6d", 
X"f69", X"f66", X"f63", X"f60", X"f5d", X"f5a", X"f57", X"f54", 
X"f50", X"f4d", X"f4a", X"f47", X"f44", X"f41", X"f3e", X"f3a", 
X"f37", X"f34", X"f31", X"f2e", X"f2b", X"f28", X"f25", X"f21", 
X"f1e", X"f1b", X"f18", X"f15", X"f12", X"f0f", X"f0c", X"f09", 
X"f05", X"f02", X"eff", X"efc", X"ef9", X"ef6", X"ef3", X"ef0", 
X"eed", X"ee9", X"ee6", X"ee3", X"ee0", X"edd", X"eda", X"ed7", 
X"ed4", X"ed1", X"ecd", X"eca", X"ec7", X"ec4", X"ec1", X"ebe", 
X"ebb", X"eb8", X"eb5", X"eb2", X"eae", X"eab", X"ea8", X"ea5", 
X"ea2", X"e9f", X"e9c", X"e99", X"e96", X"e93", X"e8f", X"e8c", 
X"e89", X"e86", X"e83", X"e80", X"e7d", X"e7a", X"e77", X"e74", 
X"e71", X"e6e", X"e6a", X"e67", X"e64", X"e61", X"e5e", X"e5b", 
X"e58", X"e55", X"e52", X"e4f", X"e4c", X"e49", X"e46", X"e43", 
X"e3f", X"e3c", X"e39", X"e36", X"e33", X"e30", X"e2d", X"e2a", 
X"e27", X"e24", X"e21", X"e1e", X"e1b", X"e18", X"e15", X"e12", 
X"e0f", X"e0c", X"e09", X"e05", X"e02", X"dff", X"dfc", X"df9", 
X"df6", X"df3", X"df0", X"ded", X"dea", X"de7", X"de4", X"de1", 
X"dde", X"ddb", X"dd8", X"dd5", X"dd2", X"dcf", X"dcc", X"dc9", 
X"dc6", X"dc3", X"dc0", X"dbd", X"dba", X"db7", X"db4", X"db1", 
X"dae", X"dab", X"da8", X"da5", X"da2", X"d9f", X"d9c", X"d99", 
X"d96", X"d93", X"d90", X"d8d", X"d8a", X"d87", X"d84", X"d81", 
X"d7e", X"d7b", X"d78", X"d75", X"d72", X"d6f", X"d6c", X"d69", 
X"d66", X"d63", X"d60", X"d5d", X"d5a", X"d57", X"d54", X"d51", 
X"d4e", X"d4b", X"d48", X"d46", X"d43", X"d40", X"d3d", X"d3a", 
X"d37", X"d34", X"d31", X"d2e", X"d2b", X"d28", X"d25", X"d22", 
X"d1f", X"d1c", X"d19", X"d17", X"d14", X"d11", X"d0e", X"d0b", 
X"d08", X"d05", X"d02", X"cff", X"cfc", X"cf9", X"cf6", X"cf4", 
X"cf1", X"cee", X"ceb", X"ce8", X"ce5", X"ce2", X"cdf", X"cdc", 
X"cd9", X"cd7", X"cd4", X"cd1", X"cce", X"ccb", X"cc8", X"cc5", 
X"cc2", X"cc0", X"cbd", X"cba", X"cb7", X"cb4", X"cb1", X"cae", 
X"cac", X"ca9", X"ca6", X"ca3", X"ca0", X"c9d", X"c9a", X"c98", 
X"c95", X"c92", X"c8f", X"c8c", X"c89", X"c87", X"c84", X"c81", 
X"c7e", X"c7b", X"c79", X"c76", X"c73", X"c70", X"c6d", X"c6a", 
X"c68", X"c65", X"c62", X"c5f", X"c5c", X"c5a", X"c57", X"c54", 
X"c51", X"c4e", X"c4c", X"c49", X"c46", X"c43", X"c41", X"c3e", 
X"c3b", X"c38", X"c36", X"c33", X"c30", X"c2d", X"c2a", X"c28", 
X"c25", X"c22", X"c1f", X"c1d", X"c1a", X"c17", X"c15", X"c12", 
X"c0f", X"c0c", X"c0a", X"c07", X"c04", X"c01", X"bff", X"bfc", 
X"bf9", X"bf7", X"bf4", X"bf1", X"bee", X"bec", X"be9", X"be6", 
X"be4", X"be1", X"bde", X"bdc", X"bd9", X"bd6", X"bd4", X"bd1", 
X"bce", X"bcb", X"bc9", X"bc6", X"bc3", X"bc1", X"bbe", X"bbc", 
X"bb9", X"bb6", X"bb4", X"bb1", X"bae", X"bac", X"ba9", X"ba6", 
X"ba4", X"ba1", X"b9e", X"b9c", X"b99", X"b97", X"b94", X"b91", 
X"b8f", X"b8c", X"b8a", X"b87", X"b84", X"b82", X"b7f", X"b7d", 
X"b7a", X"b77", X"b75", X"b72", X"b70", X"b6d", X"b6a", X"b68", 
X"b65", X"b63", X"b60", X"b5e", X"b5b", X"b59", X"b56", X"b53", 
X"b51", X"b4e", X"b4c", X"b49", X"b47", X"b44", X"b42", X"b3f", 
X"b3d", X"b3a", X"b38", X"b35", X"b33", X"b30", X"b2e", X"b2b", 
X"b29", X"b26", X"b24", X"b21", X"b1f", X"b1c", X"b1a", X"b17", 
X"b15", X"b12", X"b10", X"b0d", X"b0b", X"b08", X"b06", X"b03", 
X"b01", X"afe", X"afc", X"afa", X"af7", X"af5", X"af2", X"af0", 
X"aed", X"aeb", X"ae9", X"ae6", X"ae4", X"ae1", X"adf", X"adc", 
X"ada", X"ad8", X"ad5", X"ad3", X"ad0", X"ace", X"acc", X"ac9", 
X"ac7", X"ac5", X"ac2", X"ac0", X"abd", X"abb", X"ab9", X"ab6", 
X"ab4", X"ab2", X"aaf", X"aad", X"aab", X"aa8", X"aa6", X"aa4", 
X"aa1", X"a9f", X"a9d", X"a9a", X"a98", X"a96", X"a93", X"a91", 
X"a8f", X"a8d", X"a8a", X"a88", X"a86", X"a83", X"a81", X"a7f", 
X"a7d", X"a7a", X"a78", X"a76", X"a73", X"a71", X"a6f", X"a6d", 
X"a6a", X"a68", X"a66", X"a64", X"a61", X"a5f", X"a5d", X"a5b", 
X"a59", X"a56", X"a54", X"a52", X"a50", X"a4d", X"a4b", X"a49", 
X"a47", X"a45", X"a43", X"a40", X"a3e", X"a3c", X"a3a", X"a38", 
X"a35", X"a33", X"a31", X"a2f", X"a2d", X"a2b", X"a29", X"a26", 
X"a24", X"a22", X"a20", X"a1e", X"a1c", X"a1a", X"a17", X"a15", 
X"a13", X"a11", X"a0f", X"a0d", X"a0b", X"a09", X"a07", X"a05", 
X"a03", X"a00", X"9fe", X"9fc", X"9fa", X"9f8", X"9f6", X"9f4", 
X"9f2", X"9f0", X"9ee", X"9ec", X"9ea", X"9e8", X"9e6", X"9e4", 
X"9e2", X"9e0", X"9de", X"9dc", X"9da", X"9d8", X"9d6", X"9d4", 
X"9d2", X"9d0", X"9ce", X"9cc", X"9ca", X"9c8", X"9c6", X"9c4", 
X"9c2", X"9c0", X"9be", X"9bc", X"9ba", X"9b8", X"9b6", X"9b4", 
X"9b2", X"9b0", X"9ae", X"9ac", X"9ab", X"9a9", X"9a7", X"9a5", 
X"9a3", X"9a1", X"99f", X"99d", X"99b", X"999", X"998", X"996", 
X"994", X"992", X"990", X"98e", X"98c", X"98b", X"989", X"987", 
X"985", X"983", X"981", X"97f", X"97e", X"97c", X"97a", X"978", 
X"976", X"975", X"973", X"971", X"96f", X"96d", X"96c", X"96a", 
X"968", X"966", X"965", X"963", X"961", X"95f", X"95d", X"95c", 
X"95a", X"958", X"957", X"955", X"953", X"951", X"950", X"94e", 
X"94c", X"94a", X"949", X"947", X"945", X"944", X"942", X"940", 
X"93f", X"93d", X"93b", X"93a", X"938", X"936", X"935", X"933", 
X"931", X"930", X"92e", X"92c", X"92b", X"929", X"927", X"926", 
X"924", X"923", X"921", X"91f", X"91e", X"91c", X"91b", X"919", 
X"917", X"916", X"914", X"913", X"911", X"910", X"90e", X"90c", 
X"90b", X"909", X"908", X"906", X"905", X"903", X"902", X"900", 
X"8ff", X"8fd", X"8fc", X"8fa", X"8f9", X"8f7", X"8f6", X"8f4", 
X"8f3", X"8f1", X"8f0", X"8ee", X"8ed", X"8eb", X"8ea", X"8e8", 
X"8e7", X"8e6", X"8e4", X"8e3", X"8e1", X"8e0", X"8de", X"8dd", 
X"8dc", X"8da", X"8d9", X"8d7", X"8d6", X"8d5", X"8d3", X"8d2", 
X"8d0", X"8cf", X"8ce", X"8cc", X"8cb", X"8ca", X"8c8", X"8c7", 
X"8c6", X"8c4", X"8c3", X"8c2", X"8c0", X"8bf", X"8be", X"8bc", 
X"8bb", X"8ba", X"8b8", X"8b7", X"8b6", X"8b4", X"8b3", X"8b2", 
X"8b1", X"8af", X"8ae", X"8ad", X"8ac", X"8aa", X"8a9", X"8a8", 
X"8a7", X"8a5", X"8a4", X"8a3", X"8a2", X"8a0", X"89f", X"89e", 
X"89d", X"89c", X"89a", X"899", X"898", X"897", X"896", X"895", 
X"893", X"892", X"891", X"890", X"88f", X"88e", X"88c", X"88b", 
X"88a", X"889", X"888", X"887", X"886", X"885", X"883", X"882", 
X"881", X"880", X"87f", X"87e", X"87d", X"87c", X"87b", X"87a", 
X"879", X"878", X"877", X"876", X"874", X"873", X"872", X"871", 
X"870", X"86f", X"86e", X"86d", X"86c", X"86b", X"86a", X"869", 
X"868", X"867", X"866", X"865", X"864", X"863", X"862", X"862", 
X"861", X"860", X"85f", X"85e", X"85d", X"85c", X"85b", X"85a", 
X"859", X"858", X"857", X"856", X"856", X"855", X"854", X"853", 
X"852", X"851", X"850", X"84f", X"84f", X"84e", X"84d", X"84c", 
X"84b", X"84a", X"849", X"849", X"848", X"847", X"846", X"845", 
X"845", X"844", X"843", X"842", X"841", X"841", X"840", X"83f", 
X"83e", X"83e", X"83d", X"83c", X"83b", X"83b", X"83a", X"839", 
X"838", X"838", X"837", X"836", X"836", X"835", X"834", X"833", 
X"833", X"832", X"831", X"831", X"830", X"82f", X"82f", X"82e", 
X"82d", X"82d", X"82c", X"82b", X"82b", X"82a", X"82a", X"829", 
X"828", X"828", X"827", X"827", X"826", X"825", X"825", X"824", 
X"824", X"823", X"822", X"822", X"821", X"821", X"820", X"820", 
X"81f", X"81f", X"81e", X"81e", X"81d", X"81d", X"81c", X"81b", 
X"81b", X"81a", X"81a", X"81a", X"819", X"819", X"818", X"818", 
X"817", X"817", X"816", X"816", X"815", X"815", X"814", X"814", 
X"814", X"813", X"813", X"812", X"812", X"812", X"811", X"811", 
X"810", X"810", X"810", X"80f", X"80f", X"80f", X"80e", X"80e", 
X"80d", X"80d", X"80d", X"80c", X"80c", X"80c", X"80b", X"80b", 
X"80b", X"80b", X"80a", X"80a", X"80a", X"809", X"809", X"809", 
X"809", X"808", X"808", X"808", X"808", X"807", X"807", X"807", 
X"807", X"806", X"806", X"806", X"806", X"805", X"805", X"805", 
X"805", X"805", X"804", X"804", X"804", X"804", X"804", X"804", 
X"803", X"803", X"803", X"803", X"803", X"803", X"803", X"803", 
X"802", X"802", X"802", X"802", X"802", X"802", X"802", X"802", 
X"802", X"802", X"801", X"801", X"801", X"801", X"801", X"801", 
X"801", X"801", X"801", X"801", X"801", X"801", X"801", X"801", 
X"801", X"801", X"801", X"801", X"801", X"801", X"801", X"801", 
X"801", X"801", X"801", X"801", X"801", X"801", X"801", X"802", 
X"802", X"802", X"802", X"802", X"802", X"802", X"802", X"802", 
X"802", X"803", X"803", X"803", X"803", X"803", X"803", X"803", 
X"803", X"804", X"804", X"804", X"804", X"804", X"804", X"805", 
X"805", X"805", X"805", X"805", X"806", X"806", X"806", X"806", 
X"807", X"807", X"807", X"807", X"808", X"808", X"808", X"808", 
X"809", X"809", X"809", X"809", X"80a", X"80a", X"80a", X"80b", 
X"80b", X"80b", X"80b", X"80c", X"80c", X"80c", X"80d", X"80d", 
X"80d", X"80e", X"80e", X"80f", X"80f", X"80f", X"810", X"810", 
X"810", X"811", X"811", X"812", X"812", X"812", X"813", X"813", 
X"814", X"814", X"814", X"815", X"815", X"816", X"816", X"817", 
X"817", X"818", X"818", X"819", X"819", X"81a", X"81a", X"81a", 
X"81b", X"81b", X"81c", X"81d", X"81d", X"81e", X"81e", X"81f", 
X"81f", X"820", X"820", X"821", X"821", X"822", X"822", X"823", 
X"824", X"824", X"825", X"825", X"826", X"827", X"827", X"828", 
X"828", X"829", X"82a", X"82a", X"82b", X"82b", X"82c", X"82d", 
X"82d", X"82e", X"82f", X"82f", X"830", X"831", X"831", X"832", 
X"833", X"833", X"834", X"835", X"836", X"836", X"837", X"838", 
X"838", X"839", X"83a", X"83b", X"83b", X"83c", X"83d", X"83e", 
X"83e", X"83f", X"840", X"841", X"841", X"842", X"843", X"844", 
X"845", X"845", X"846", X"847", X"848", X"849", X"849", X"84a", 
X"84b", X"84c", X"84d", X"84e", X"84f", X"84f", X"850", X"851", 
X"852", X"853", X"854", X"855", X"856", X"856", X"857", X"858", 
X"859", X"85a", X"85b", X"85c", X"85d", X"85e", X"85f", X"860", 
X"861", X"862", X"862", X"863", X"864", X"865", X"866", X"867", 
X"868", X"869", X"86a", X"86b", X"86c", X"86d", X"86e", X"86f", 
X"870", X"871", X"872", X"873", X"874", X"876", X"877", X"878", 
X"879", X"87a", X"87b", X"87c", X"87d", X"87e", X"87f", X"880", 
X"881", X"882", X"883", X"885", X"886", X"887", X"888", X"889", 
X"88a", X"88b", X"88c", X"88e", X"88f", X"890", X"891", X"892", 
X"893", X"895", X"896", X"897", X"898", X"899", X"89a", X"89c", 
X"89d", X"89e", X"89f", X"8a0", X"8a2", X"8a3", X"8a4", X"8a5", 
X"8a7", X"8a8", X"8a9", X"8aa", X"8ac", X"8ad", X"8ae", X"8af", 
X"8b1", X"8b2", X"8b3", X"8b4", X"8b6", X"8b7", X"8b8", X"8ba", 
X"8bb", X"8bc", X"8be", X"8bf", X"8c0", X"8c2", X"8c3", X"8c4", 
X"8c6", X"8c7", X"8c8", X"8ca", X"8cb", X"8cc", X"8ce", X"8cf", 
X"8d0", X"8d2", X"8d3", X"8d5", X"8d6", X"8d7", X"8d9", X"8da", 
X"8dc", X"8dd", X"8de", X"8e0", X"8e1", X"8e3", X"8e4", X"8e6", 
X"8e7", X"8e8", X"8ea", X"8eb", X"8ed", X"8ee", X"8f0", X"8f1", 
X"8f3", X"8f4", X"8f6", X"8f7", X"8f9", X"8fa", X"8fc", X"8fd", 
X"8ff", X"900", X"902", X"903", X"905", X"906", X"908", X"909", 
X"90b", X"90c", X"90e", X"910", X"911", X"913", X"914", X"916", 
X"917", X"919", X"91b", X"91c", X"91e", X"91f", X"921", X"923", 
X"924", X"926", X"927", X"929", X"92b", X"92c", X"92e", X"930", 
X"931", X"933", X"935", X"936", X"938", X"93a", X"93b", X"93d", 
X"93f", X"940", X"942", X"944", X"945", X"947", X"949", X"94a", 
X"94c", X"94e", X"950", X"951", X"953", X"955", X"957", X"958", 
X"95a", X"95c", X"95d", X"95f", X"961", X"963", X"965", X"966", 
X"968", X"96a", X"96c", X"96d", X"96f", X"971", X"973", X"975", 
X"976", X"978", X"97a", X"97c", X"97e", X"97f", X"981", X"983", 
X"985", X"987", X"989", X"98b", X"98c", X"98e", X"990", X"992", 
X"994", X"996", X"998", X"999", X"99b", X"99d", X"99f", X"9a1", 
X"9a3", X"9a5", X"9a7", X"9a9", X"9ab", X"9ac", X"9ae", X"9b0", 
X"9b2", X"9b4", X"9b6", X"9b8", X"9ba", X"9bc", X"9be", X"9c0", 
X"9c2", X"9c4", X"9c6", X"9c8", X"9ca", X"9cc", X"9ce", X"9d0", 
X"9d2", X"9d4", X"9d6", X"9d8", X"9da", X"9dc", X"9de", X"9e0", 
X"9e2", X"9e4", X"9e6", X"9e8", X"9ea", X"9ec", X"9ee", X"9f0", 
X"9f2", X"9f4", X"9f6", X"9f8", X"9fa", X"9fc", X"9fe", X"a00", 
X"a03", X"a05", X"a07", X"a09", X"a0b", X"a0d", X"a0f", X"a11", 
X"a13", X"a15", X"a17", X"a1a", X"a1c", X"a1e", X"a20", X"a22", 
X"a24", X"a26", X"a29", X"a2b", X"a2d", X"a2f", X"a31", X"a33", 
X"a35", X"a38", X"a3a", X"a3c", X"a3e", X"a40", X"a43", X"a45", 
X"a47", X"a49", X"a4b", X"a4d", X"a50", X"a52", X"a54", X"a56", 
X"a59", X"a5b", X"a5d", X"a5f", X"a61", X"a64", X"a66", X"a68", 
X"a6a", X"a6d", X"a6f", X"a71", X"a73", X"a76", X"a78", X"a7a", 
X"a7d", X"a7f", X"a81", X"a83", X"a86", X"a88", X"a8a", X"a8d", 
X"a8f", X"a91", X"a93", X"a96", X"a98", X"a9a", X"a9d", X"a9f", 
X"aa1", X"aa4", X"aa6", X"aa8", X"aab", X"aad", X"aaf", X"ab2", 
X"ab4", X"ab6", X"ab9", X"abb", X"abd", X"ac0", X"ac2", X"ac5", 
X"ac7", X"ac9", X"acc", X"ace", X"ad0", X"ad3", X"ad5", X"ad8", 
X"ada", X"adc", X"adf", X"ae1", X"ae4", X"ae6", X"ae9", X"aeb", 
X"aed", X"af0", X"af2", X"af5", X"af7", X"afa", X"afc", X"afe", 
X"b01", X"b03", X"b06", X"b08", X"b0b", X"b0d", X"b10", X"b12", 
X"b15", X"b17", X"b1a", X"b1c", X"b1f", X"b21", X"b24", X"b26", 
X"b29", X"b2b", X"b2e", X"b30", X"b33", X"b35", X"b38", X"b3a", 
X"b3d", X"b3f", X"b42", X"b44", X"b47", X"b49", X"b4c", X"b4e", 
X"b51", X"b53", X"b56", X"b59", X"b5b", X"b5e", X"b60", X"b63", 
X"b65", X"b68", X"b6a", X"b6d", X"b70", X"b72", X"b75", X"b77", 
X"b7a", X"b7d", X"b7f", X"b82", X"b84", X"b87", X"b8a", X"b8c", 
X"b8f", X"b91", X"b94", X"b97", X"b99", X"b9c", X"b9e", X"ba1", 
X"ba4", X"ba6", X"ba9", X"bac", X"bae", X"bb1", X"bb4", X"bb6", 
X"bb9", X"bbc", X"bbe", X"bc1", X"bc3", X"bc6", X"bc9", X"bcb", 
X"bce", X"bd1", X"bd4", X"bd6", X"bd9", X"bdc", X"bde", X"be1", 
X"be4", X"be6", X"be9", X"bec", X"bee", X"bf1", X"bf4", X"bf7", 
X"bf9", X"bfc", X"bff", X"c01", X"c04", X"c07", X"c0a", X"c0c", 
X"c0f", X"c12", X"c15", X"c17", X"c1a", X"c1d", X"c1f", X"c22", 
X"c25", X"c28", X"c2a", X"c2d", X"c30", X"c33", X"c36", X"c38", 
X"c3b", X"c3e", X"c41", X"c43", X"c46", X"c49", X"c4c", X"c4e", 
X"c51", X"c54", X"c57", X"c5a", X"c5c", X"c5f", X"c62", X"c65", 
X"c68", X"c6a", X"c6d", X"c70", X"c73", X"c76", X"c79", X"c7b", 
X"c7e", X"c81", X"c84", X"c87", X"c89", X"c8c", X"c8f", X"c92", 
X"c95", X"c98", X"c9a", X"c9d", X"ca0", X"ca3", X"ca6", X"ca9", 
X"cac", X"cae", X"cb1", X"cb4", X"cb7", X"cba", X"cbd", X"cc0", 
X"cc2", X"cc5", X"cc8", X"ccb", X"cce", X"cd1", X"cd4", X"cd7", 
X"cd9", X"cdc", X"cdf", X"ce2", X"ce5", X"ce8", X"ceb", X"cee", 
X"cf1", X"cf4", X"cf6", X"cf9", X"cfc", X"cff", X"d02", X"d05", 
X"d08", X"d0b", X"d0e", X"d11", X"d14", X"d17", X"d19", X"d1c", 
X"d1f", X"d22", X"d25", X"d28", X"d2b", X"d2e", X"d31", X"d34", 
X"d37", X"d3a", X"d3d", X"d40", X"d43", X"d46", X"d48", X"d4b", 
X"d4e", X"d51", X"d54", X"d57", X"d5a", X"d5d", X"d60", X"d63", 
X"d66", X"d69", X"d6c", X"d6f", X"d72", X"d75", X"d78", X"d7b", 
X"d7e", X"d81", X"d84", X"d87", X"d8a", X"d8d", X"d90", X"d93", 
X"d96", X"d99", X"d9c", X"d9f", X"da2", X"da5", X"da8", X"dab", 
X"dae", X"db1", X"db4", X"db7", X"dba", X"dbd", X"dc0", X"dc3", 
X"dc6", X"dc9", X"dcc", X"dcf", X"dd2", X"dd5", X"dd8", X"ddb", 
X"dde", X"de1", X"de4", X"de7", X"dea", X"ded", X"df0", X"df3", 
X"df6", X"df9", X"dfc", X"dff", X"e02", X"e05", X"e09", X"e0c", 
X"e0f", X"e12", X"e15", X"e18", X"e1b", X"e1e", X"e21", X"e24", 
X"e27", X"e2a", X"e2d", X"e30", X"e33", X"e36", X"e39", X"e3c", 
X"e3f", X"e43", X"e46", X"e49", X"e4c", X"e4f", X"e52", X"e55", 
X"e58", X"e5b", X"e5e", X"e61", X"e64", X"e67", X"e6a", X"e6e", 
X"e71", X"e74", X"e77", X"e7a", X"e7d", X"e80", X"e83", X"e86", 
X"e89", X"e8c", X"e8f", X"e93", X"e96", X"e99", X"e9c", X"e9f", 
X"ea2", X"ea5", X"ea8", X"eab", X"eae", X"eb2", X"eb5", X"eb8", 
X"ebb", X"ebe", X"ec1", X"ec4", X"ec7", X"eca", X"ecd", X"ed1", 
X"ed4", X"ed7", X"eda", X"edd", X"ee0", X"ee3", X"ee6", X"ee9", 
X"eed", X"ef0", X"ef3", X"ef6", X"ef9", X"efc", X"eff", X"f02", 
X"f05", X"f09", X"f0c", X"f0f", X"f12", X"f15", X"f18", X"f1b", 
X"f1e", X"f21", X"f25", X"f28", X"f2b", X"f2e", X"f31", X"f34", 
X"f37", X"f3a", X"f3e", X"f41", X"f44", X"f47", X"f4a", X"f4d", 
X"f50", X"f54", X"f57", X"f5a", X"f5d", X"f60", X"f63", X"f66", 
X"f69", X"f6d", X"f70", X"f73", X"f76", X"f79", X"f7c", X"f7f", 
X"f82", X"f86", X"f89", X"f8c", X"f8f", X"f92", X"f95", X"f98", 
X"f9c", X"f9f", X"fa2", X"fa5", X"fa8", X"fab", X"fae", X"fb2", 
X"fb5", X"fb8", X"fbb", X"fbe", X"fc1", X"fc4", X"fc7", X"fcb", 
X"fce", X"fd1", X"fd4", X"fd7", X"fda", X"fdd", X"fe1", X"fe4", 
X"fe7", X"fea", X"fed", X"ff0", X"ff3", X"ff7", X"ffa", X"ffd"
);

begin

rom_select: process (clk, en)
begin
	if (rising_edge(clk)) then
    if (en = '1') then
		sin_out <= (SIN_ROM(conv_integer(address_reg)) & x"00000");
    end if;
  end if;
end process rom_select;

end rtl;
