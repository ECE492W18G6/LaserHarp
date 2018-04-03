--------------------------------------------------------------------------------------------------------------------------
-- Original Authors : Simon Doherty, Eric Lunty, Kyle Brooks, Peter Roland						--
-- Date created: N/A 													--
--															--
-- Additional Authors : Randi Derbyshire, Adam Narten, Oliver Rarog, Celeste Chiasson					--
-- Date edited: March 26, 2018											--
--															--
-- This program takes a value from the synthesizer.vhd file and runs it through the 12-bit ROM to find the 	 	--
-- respective sine wave value. 												--
--------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;               -- Needed for shifts

entity PianoSin_lut is

port (
	clk      : in  std_logic;
	en       : in  std_logic;
	
	--Address input
	address_reg : in std_logic_vector(11 downto 0); 
	
	--Sine value output
	sin_out  : out std_logic_vector(31 downto 0)
	);
end entity;


architecture rtl of PianoSin_lut is


type rom_type is array (0 to 4095) of std_logic_vector (11 downto 0);

constant SIN_ROM : rom_type :=

(
X"000", X"00A", X"015", X"01E", X"029", X"034", X"03E", X"048", 
X"052", X"05D", X"068", X"071", X"07C", X"087", X"091", X"09B", 
X"0A5", X"0B0", X"0BA", X"0C5", X"0CF", X"0D9", X"0E4", X"0EE", 
X"0F8", X"102", X"10D", X"117", X"121", X"12B", X"136", X"140", 
X"14B", X"154", X"15F", X"169", X"173", X"17D", X"187", X"191", 
X"19C", X"1A5", X"1B0", X"1BA", X"1C4", X"1CD", X"1D8", X"1E2", 
X"1EC", X"1F6", X"200", X"20A", X"214", X"21E", X"227", X"231", 
X"23B", X"245", X"24F", X"259", X"263", X"26D", X"277", X"280", 
X"289", X"293", X"29D", X"2A6", X"2B0", X"2BA", X"2C4", X"2CC", 
X"2D6", X"2E0", X"2EA", X"2F2", X"2FC", X"305", X"30F", X"319", 
X"321", X"32B", X"334", X"33E", X"346", X"350", X"359", X"362", 
X"36B", X"374", X"37D", X"386", X"390", X"398", X"3A1", X"3AA", 
X"3B3", X"3BB", X"3C4", X"3CD", X"3D6", X"3DE", X"3E7", X"3F0", 
X"3F9", X"401", X"40A", X"412", X"41B", X"424", X"42B", X"434", 
X"43C", X"445", X"44D", X"455", X"45D", X"466", X"46D", X"476", 
X"47E", X"486", X"48E", X"495", X"49E", X"4A6", X"4AE", X"4B5", 
X"4BD", X"4C5", X"4CD", X"4D4", X"4DB", X"4E3", X"4EB", X"4F2", 
X"4F9", X"501", X"508", X"510", X"517", X"51E", X"526", X"52D", 
X"533", X"53B", X"542", X"549", X"550", X"557", X"55E", X"565", 
X"56C", X"572", X"579", X"580", X"586", X"58C", X"593", X"59A", 
X"5A0", X"5A6", X"5AD", X"5B3", X"5BA", X"5BF", X"5C6", X"5CC", 
X"5D2", X"5D9", X"5DE", X"5E4", X"5EA", X"5F0", X"5F6", X"5FC", 
X"602", X"607", X"60D", X"612", X"618", X"61E", X"623", X"628", 
X"62E", X"633", X"639", X"63E", X"643", X"648", X"64E", X"652", 
X"657", X"65C", X"662", X"666", X"66B", X"670", X"675", X"67A", 
X"67E", X"683", X"687", X"68C", X"690", X"695", X"699", X"69E", 
X"6A2", X"6A6", X"6AA", X"6AE", X"6B3", X"6B6", X"6BB", X"6BF", 
X"6C3", X"6C6", X"6CA", X"6CE", X"6D2", X"6D5", X"6D9", X"6DD", 
X"6E0", X"6E4", X"6E7", X"6EB", X"6EE", X"6F1", X"6F5", X"6F8", 
X"6FB", X"6FE", X"701", X"704", X"707", X"70A", X"70D", X"710", 
X"713", X"716", X"719", X"71B", X"71E", X"721", X"723", X"726", 
X"728", X"72B", X"72D", X"72F", X"732", X"734", X"736", X"738", 
X"73A", X"73C", X"73F", X"741", X"742", X"744", X"746", X"748", 
X"74A", X"74C", X"74D", X"74F", X"750", X"752", X"754", X"755", 
X"757", X"758", X"759", X"75B", X"75C", X"75D", X"75E", X"760", 
X"761", X"762", X"763", X"764", X"765", X"766", X"767", X"767", 
X"768", X"769", X"76A", X"76A", X"76B", X"76C", X"76C", X"76D", 
X"76D", X"76E", X"76E", X"76F", X"76F", X"76F", X"76F", X"770", 
X"770", X"770", X"770", X"770", X"770", X"770", X"770", X"770", 
X"770", X"770", X"770", X"770", X"770", X"76F", X"76F", X"76F", 
X"76E", X"76E", X"76E", X"76D", X"76D", X"76C", X"76C", X"76B", 
X"76A", X"76A", X"769", X"768", X"768", X"767", X"766", X"765", 
X"764", X"764", X"763", X"762", X"761", X"760", X"75F", X"75E", 
X"75D", X"75C", X"75A", X"759", X"758", X"757", X"756", X"754", 
X"753", X"752", X"750", X"74F", X"74E", X"74C", X"74B", X"749", 
X"748", X"746", X"745", X"743", X"742", X"740", X"73E", X"73D", 
X"73B", X"739", X"738", X"736", X"734", X"732", X"731", X"72F", 
X"72D", X"72B", X"729", X"727", X"726", X"724", X"722", X"720", 
X"71E", X"71C", X"71A", X"718", X"716", X"714", X"711", X"70F", 
X"70D", X"70B", X"709", X"707", X"705", X"702", X"700", X"6FE", 
X"6FC", X"6FA", X"6F7", X"6F5", X"6F3", X"6F1", X"6EE", X"6EC", 
X"6E9", X"6E7", X"6E5", X"6E2", X"6E0", X"6DE", X"6DB", X"6D9", 
X"6D6", X"6D4", X"6D2", X"6CF", X"6CD", X"6CA", X"6C8", X"6C5", 
X"6C3", X"6C0", X"6BE", X"6BB", X"6B9", X"6B6", X"6B3", X"6B1", 
X"6AF", X"6AC", X"6A9", X"6A7", X"6A4", X"6A2", X"69F", X"69C", 
X"69A", X"697", X"695", X"692", X"690", X"68D", X"68A", X"688", 
X"685", X"683", X"680", X"67D", X"67B", X"678", X"675", X"673", 
X"670", X"66E", X"66B", X"668", X"666", X"663", X"660", X"65E", 
X"65B", X"659", X"656", X"653", X"651", X"64E", X"64B", X"649", 
X"646", X"643", X"641", X"63E", X"63C", X"639", X"637", X"634", 
X"631", X"62F", X"62C", X"62A", X"627", X"624", X"622", X"61F", 
X"61D", X"61A", X"618", X"615", X"613", X"610", X"60E", X"60B", 
X"609", X"606", X"604", X"601", X"5FF", X"5FC", X"5FA", X"5F7", 
X"5F5", X"5F2", X"5F0", X"5EE", X"5EB", X"5E9", X"5E6", X"5E4", 
X"5E2", X"5DF", X"5DD", X"5DA", X"5D8", X"5D6", X"5D4", X"5D1", 
X"5CF", X"5CD", X"5CA", X"5C8", X"5C6", X"5C4", X"5C1", X"5BF", 
X"5BD", X"5BB", X"5B8", X"5B6", X"5B4", X"5B2", X"5B0", X"5AE", 
X"5AB", X"5A9", X"5A7", X"5A5", X"5A3", X"5A1", X"59F", X"59D", 
X"59B", X"599", X"597", X"595", X"593", X"591", X"58F", X"58D", 
X"58B", X"589", X"587", X"585", X"583", X"581", X"57F", X"57E", 
X"57C", X"57A", X"578", X"576", X"575", X"573", X"571", X"56F", 
X"56E", X"56C", X"56A", X"568", X"567", X"565", X"563", X"562", 
X"560", X"55F", X"55D", X"55B", X"55A", X"558", X"557", X"555", 
X"554", X"552", X"551", X"54F", X"54E", X"54C", X"54B", X"549", 
X"548", X"547", X"545", X"544", X"543", X"541", X"540", X"53F", 
X"53D", X"53C", X"53B", X"539", X"538", X"537", X"536", X"535", 
X"533", X"532", X"531", X"530", X"52F", X"52E", X"52C", X"52B", 
X"52A", X"529", X"528", X"527", X"526", X"525", X"524", X"523", 
X"522", X"521", X"520", X"51F", X"51E", X"51D", X"51C", X"51C", 
X"51B", X"51A", X"519", X"518", X"517", X"516", X"516", X"515", 
X"514", X"513", X"512", X"512", X"511", X"510", X"510", X"50F", 
X"50E", X"50D", X"50D", X"50C", X"50B", X"50B", X"50A", X"509", 
X"509", X"508", X"508", X"507", X"507", X"506", X"505", X"505", 
X"504", X"504", X"503", X"503", X"502", X"502", X"501", X"501", 
X"500", X"500", X"4FF", X"4FF", X"4FF", X"4FE", X"4FE", X"4FD", 
X"4FD", X"4FD", X"4FC", X"4FC", X"4FB", X"4FB", X"4FB", X"4FA", 
X"4FA", X"4FA", X"4F9", X"4F9", X"4F9", X"4F8", X"4F8", X"4F8", 
X"4F7", X"4F7", X"4F7", X"4F7", X"4F6", X"4F6", X"4F6", X"4F6", 
X"4F5", X"4F5", X"4F5", X"4F5", X"4F4", X"4F4", X"4F4", X"4F4", 
X"4F3", X"4F3", X"4F3", X"4F3", X"4F3", X"4F2", X"4F2", X"4F2", 
X"4F2", X"4F2", X"4F1", X"4F1", X"4F1", X"4F1", X"4F1", X"4F0", 
X"4F0", X"4F0", X"4F0", X"4F0", X"4F0", X"4EF", X"4EF", X"4EF", 
X"4EF", X"4EF", X"4EF", X"4EE", X"4EE", X"4EE", X"4EE", X"4EE", 
X"4ED", X"4ED", X"4ED", X"4ED", X"4ED", X"4ED", X"4EC", X"4EC", 
X"4EC", X"4EC", X"4EC", X"4EB", X"4EB", X"4EB", X"4EB", X"4EB", 
X"4EA", X"4EA", X"4EA", X"4EA", X"4EA", X"4E9", X"4E9", X"4E9", 
X"4E9", X"4E8", X"4E8", X"4E8", X"4E8", X"4E7", X"4E7", X"4E7", 
X"4E6", X"4E6", X"4E6", X"4E6", X"4E5", X"4E5", X"4E5", X"4E4", 
X"4E4", X"4E4", X"4E3", X"4E3", X"4E3", X"4E2", X"4E2", X"4E2", 
X"4E1", X"4E1", X"4E0", X"4E0", X"4E0", X"4DF", X"4DF", X"4DE", 
X"4DE", X"4DD", X"4DD", X"4DC", X"4DC", X"4DB", X"4DB", X"4DA", 
X"4DA", X"4D9", X"4D9", X"4D8", X"4D8", X"4D7", X"4D7", X"4D6", 
X"4D5", X"4D5", X"4D4", X"4D4", X"4D3", X"4D2", X"4D2", X"4D1", 
X"4D0", X"4D0", X"4CF", X"4CE", X"4CD", X"4CD", X"4CC", X"4CB", 
X"4CA", X"4CA", X"4C9", X"4C8", X"4C7", X"4C6", X"4C5", X"4C5", 
X"4C4", X"4C3", X"4C2", X"4C1", X"4C0", X"4BF", X"4BE", X"4BD", 
X"4BC", X"4BB", X"4BA", X"4B9", X"4B8", X"4B7", X"4B6", X"4B5", 
X"4B4", X"4B3", X"4B2", X"4B0", X"4AF", X"4AE", X"4AD", X"4AC", 
X"4AB", X"4A9", X"4A8", X"4A7", X"4A6", X"4A4", X"4A3", X"4A2", 
X"4A0", X"49F", X"49E", X"49C", X"49B", X"49A", X"498", X"497", 
X"495", X"494", X"492", X"491", X"48F", X"48E", X"48C", X"48B", 
X"489", X"487", X"486", X"484", X"483", X"481", X"47F", X"47E", 
X"47C", X"47A", X"478", X"477", X"475", X"473", X"471", X"46F", 
X"46E", X"46C", X"46A", X"468", X"466", X"464", X"462", X"460", 
X"45E", X"45C", X"45A", X"458", X"456", X"454", X"452", X"450", 
X"44E", X"44C", X"44A", X"447", X"445", X"443", X"441", X"43F", 
X"43D", X"43A", X"438", X"436", X"434", X"431", X"42F", X"42C", 
X"42A", X"428", X"425", X"423", X"420", X"41E", X"41C", X"419", 
X"416", X"414", X"412", X"40F", X"40C", X"40A", X"407", X"405", 
X"402", X"3FF", X"3FD", X"3FA", X"3F7", X"3F5", X"3F2", X"3EF", 
X"3EC", X"3EA", X"3E7", X"3E4", X"3E1", X"3DE", X"3DB", X"3D9", 
X"3D6", X"3D3", X"3D0", X"3CD", X"3CA", X"3C7", X"3C4", X"3C1", 
X"3BE", X"3BB", X"3B8", X"3B5", X"3B2", X"3AF", X"3AC", X"3A9", 
X"3A6", X"3A3", X"39F", X"39C", X"399", X"396", X"393", X"38F", 
X"38C", X"389", X"386", X"382", X"37F", X"37C", X"379", X"375", 
X"372", X"36F", X"36B", X"368", X"364", X"361", X"35E", X"35A", 
X"357", X"353", X"350", X"34C", X"349", X"345", X"342", X"33E", 
X"33B", X"337", X"334", X"330", X"32C", X"329", X"325", X"322", 
X"31E", X"31A", X"316", X"313", X"30F", X"30B", X"308", X"304", 
X"300", X"2FD", X"2F9", X"2F5", X"2F1", X"2EE", X"2EA", X"2E6", 
X"2E2", X"2DE", X"2DA", X"2D7", X"2D3", X"2CF", X"2CB", X"2C7", 
X"2C4", X"2C0", X"2BC", X"2B8", X"2B4", X"2B0", X"2AC", X"2A8", 
X"2A4", X"2A0", X"29C", X"298", X"294", X"290", X"28C", X"288", 
X"284", X"280", X"27C", X"278", X"274", X"270", X"26C", X"268", 
X"264", X"260", X"25C", X"258", X"254", X"250", X"24C", X"248", 
X"243", X"23F", X"23B", X"237", X"233", X"22F", X"22B", X"227", 
X"223", X"21E", X"21A", X"216", X"212", X"20E", X"20A", X"206", 
X"202", X"1FD", X"1F9", X"1F5", X"1F1", X"1ED", X"1E8", X"1E4", 
X"1E0", X"1DC", X"1D8", X"1D3", X"1D0", X"1CB", X"1C7", X"1C3", 
X"1BF", X"1BB", X"1B6", X"1B2", X"1AE", X"1AA", X"1A6", X"1A1", 
X"19D", X"199", X"195", X"191", X"18C", X"188", X"184", X"180", 
X"17C", X"178", X"173", X"16F", X"16B", X"167", X"163", X"15E", 
X"15A", X"156", X"152", X"14E", X"14A", X"145", X"141", X"13D", 
X"139", X"135", X"130", X"12D", X"128", X"124", X"120", X"11C", 
X"118", X"114", X"110", X"10C", X"108", X"103", X"0FF", X"0FB", 
X"0F7", X"0F3", X"0EF", X"0EB", X"0E7", X"0E3", X"0DF", X"0DA", 
X"0D7", X"0D3", X"0CE", X"0CA", X"0C7", X"0C3", X"0BE", X"0BA", 
X"0B6", X"0B3", X"0AF", X"0AA", X"0A6", X"0A3", X"09F", X"09B", 
X"097", X"093", X"08F", X"08B", X"087", X"083", X"07F", X"07C", 
X"078", X"074", X"070", X"06C", X"068", X"064", X"061", X"05D", 
X"059", X"055", X"052", X"04E", X"04A", X"046", X"042", X"03F", 
X"03B", X"037", X"033", X"030", X"02C", X"029", X"025", X"021", 
X"01E", X"01A", X"016", X"013", X"00F", X"00C", X"008", X"004", 
X"001", X"FFD", X"FFA", X"FF6", X"FF3", X"FEF", X"FEC", X"FE8", 
X"FE5", X"FE2", X"FDE", X"FDB", X"FD7", X"FD4", X"FD1", X"FCD", 
X"FCA", X"FC7", X"FC3", X"FC0", X"FBD", X"FB9", X"FB6", X"FB3", 
X"FAF", X"FAC", X"FA9", X"FA6", X"FA3", X"F9F", X"F9C", X"F99", 
X"F96", X"F93", X"F90", X"F8D", X"F8A", X"F87", X"F84", X"F81", 
X"F7E", X"F7A", X"F77", X"F75", X"F72", X"F6F", X"F6C", X"F69", 
X"F66", X"F63", X"F60", X"F5D", X"F5A", X"F58", X"F55", X"F52", 
X"F4F", X"F4C", X"F4A", X"F47", X"F44", X"F42", X"F3F", X"F3C", 
X"F3A", X"F37", X"F34", X"F31", X"F2F", X"F2C", X"F2A", X"F27", 
X"F25", X"F22", X"F20", X"F1D", X"F1B", X"F18", X"F16", X"F13", 
X"F11", X"F0F", X"F0C", X"F0A", X"F07", X"F05", X"F03", X"F01", 
X"EFE", X"EFC", X"EFA", X"EF8", X"EF5", X"EF3", X"EF1", X"EEF", 
X"EED", X"EEB", X"EE9", X"EE6", X"EE4", X"EE2", X"EE0", X"EDE", 
X"EDC", X"EDA", X"ED8", X"ED6", X"ED4", X"ED2", X"ED0", X"ECF", 
X"ECD", X"ECB", X"EC9", X"EC7", X"EC5", X"EC4", X"EC2", X"EC0", 
X"EBE", X"EBD", X"EBB", X"EB9", X"EB7", X"EB6", X"EB4", X"EB2", 
X"EB1", X"EAF", X"EAE", X"EAC", X"EAA", X"EA9", X"EA8", X"EA6", 
X"EA4", X"EA3", X"EA2", X"EA0", X"E9F", X"E9D", X"E9C", X"E9B", 
X"E99", X"E98", X"E97", X"E95", X"E94", X"E93", X"E92", X"E90", 
X"E8F", X"E8E", X"E8D", X"E8C", X"E8A", X"E89", X"E88", X"E87", 
X"E86", X"E85", X"E84", X"E83", X"E82", X"E81", X"E80", X"E7F", 
X"E7E", X"E7D", X"E7C", X"E7B", X"E7A", X"E79", X"E79", X"E78", 
X"E77", X"E76", X"E75", X"E74", X"E74", X"E73", X"E72", X"E72", 
X"E71", X"E70", X"E70", X"E6F", X"E6E", X"E6E", X"E6D", X"E6C", 
X"E6C", X"E6B", X"E6B", X"E6A", X"E6A", X"E69", X"E69", X"E68", 
X"E68", X"E67", X"E67", X"E66", X"E66", X"E66", X"E65", X"E65", 
X"E65", X"E64", X"E64", X"E64", X"E63", X"E63", X"E63", X"E63", 
X"E62", X"E62", X"E62", X"E62", X"E62", X"E62", X"E61", X"E61", 
X"E61", X"E61", X"E61", X"E61", X"E61", X"E61", X"E61", X"E61", 
X"E61", X"E61", X"E61", X"E61", X"E61", X"E61", X"E61", X"E61", 
X"E61", X"E61", X"E61", X"E62", X"E62", X"E62", X"E62", X"E62", 
X"E62", X"E63", X"E63", X"E63", X"E63", X"E64", X"E64", X"E64", 
X"E65", X"E65", X"E65", X"E66", X"E66", X"E66", X"E67", X"E67", 
X"E67", X"E68", X"E68", X"E69", X"E69", X"E6A", X"E6A", X"E6A", 
X"E6B", X"E6B", X"E6C", X"E6C", X"E6D", X"E6E", X"E6E", X"E6F", 
X"E6F", X"E70", X"E70", X"E71", X"E72", X"E72", X"E73", X"E73", 
X"E74", X"E75", X"E75", X"E76", X"E77", X"E77", X"E78", X"E79", 
X"E7A", X"E7A", X"E7B", X"E7C", X"E7D", X"E7D", X"E7E", X"E7F", 
X"E80", X"E81", X"E81", X"E82", X"E83", X"E84", X"E85", X"E86", 
X"E86", X"E87", X"E88", X"E89", X"E8A", X"E8B", X"E8C", X"E8D", 
X"E8E", X"E8E", X"E8F", X"E90", X"E91", X"E92", X"E93", X"E94", 
X"E95", X"E96", X"E97", X"E98", X"E99", X"E9A", X"E9B", X"E9C", 
X"E9D", X"E9E", X"E9F", X"EA0", X"EA2", X"EA3", X"EA4", X"EA5", 
X"EA6", X"EA7", X"EA8", X"EA9", X"EAA", X"EAB", X"EAD", X"EAE", 
X"EAF", X"EB0", X"EB1", X"EB2", X"EB3", X"EB5", X"EB6", X"EB7", 
X"EB8", X"EB9", X"EBA", X"EBC", X"EBD", X"EBE", X"EBF", X"EC0", 
X"EC2", X"EC3", X"EC4", X"EC5", X"EC6", X"EC8", X"EC9", X"ECA", 
X"ECB", X"ECD", X"ECE", X"ECF", X"ED0", X"ED2", X"ED3", X"ED4", 
X"ED5", X"ED7", X"ED8", X"ED9", X"EDB", X"EDC", X"EDD", X"EDE", 
X"EE0", X"EE1", X"EE2", X"EE3", X"EE5", X"EE6", X"EE7", X"EE9", 
X"EEA", X"EEB", X"EED", X"EEE", X"EEF", X"EF1", X"EF2", X"EF3", 
X"EF5", X"EF6", X"EF7", X"EF8", X"EFA", X"EFB", X"EFC", X"EFE", 
X"EFF", X"F00", X"F02", X"F03", X"F04", X"F06", X"F07", X"F08", 
X"F0A", X"F0B", X"F0C", X"F0E", X"F0F", X"F10", X"F12", X"F13", 
X"F14", X"F16", X"F17", X"F19", X"F1A", X"F1B", X"F1C", X"F1E", 
X"F1F", X"F20", X"F22", X"F23", X"F25", X"F26", X"F27", X"F29", 
X"F2A", X"F2B", X"F2C", X"F2E", X"F2F", X"F31", X"F32", X"F33", 
X"F34", X"F36", X"F37", X"F38", X"F3A", X"F3B", X"F3C", X"F3E", 
X"F3F", X"F40", X"F42", X"F43", X"F44", X"F46", X"F47", X"F48", 
X"F49", X"F4B", X"F4C", X"F4D", X"F4F", X"F50", X"F51", X"F52", 
X"F54", X"F55", X"F56", X"F58", X"F59", X"F5A", X"F5B", X"F5D", 
X"F5E", X"F5F", X"F60", X"F62", X"F63", X"F64", X"F65", X"F66", 
X"F68", X"F69", X"F6A", X"F6B", X"F6D", X"F6E", X"F6F", X"F70", 
X"F71", X"F73", X"F74", X"F75", X"F76", X"F77", X"F79", X"F7A", 
X"F7B", X"F7C", X"F7D", X"F7E", X"F80", X"F81", X"F82", X"F83", 
X"F84", X"F85", X"F86", X"F88", X"F89", X"F8A", X"F8B", X"F8C", 
X"F8D", X"F8E", X"F8F", X"F90", X"F92", X"F93", X"F94", X"F95", 
X"F96", X"F97", X"F98", X"F99", X"F9A", X"F9B", X"F9C", X"F9D", 
X"F9E", X"F9F", X"FA0", X"FA1", X"FA2", X"FA3", X"FA4", X"FA5", 
X"FA6", X"FA7", X"FA8", X"FA9", X"FAA", X"FAB", X"FAC", X"FAD", 
X"FAE", X"FAF", X"FB0", X"FB1", X"FB2", X"FB3", X"FB4", X"FB5", 
X"FB6", X"FB7", X"FB7", X"FB8", X"FB9", X"FBA", X"FBB", X"FBC", 
X"FBD", X"FBE", X"FBF", X"FBF", X"FC0", X"FC1", X"FC2", X"FC3", 
X"FC4", X"FC4", X"FC5", X"FC6", X"FC7", X"FC8", X"FC9", X"FC9", 
X"FCA", X"FCB", X"FCC", X"FCC", X"FCD", X"FCE", X"FCF", X"FCF", 
X"FD0", X"FD1", X"FD2", X"FD2", X"FD3", X"FD4", X"FD4", X"FD5", 
X"FD6", X"FD7", X"FD7", X"FD8", X"FD9", X"FD9", X"FDA", X"FDB", 
X"FDB", X"FDC", X"FDC", X"FDD", X"FDE", X"FDE", X"FDF", X"FE0", 
X"FE0", X"FE1", X"FE1", X"FE2", X"FE3", X"FE3", X"FE4", X"FE4", 
X"FE5", X"FE5", X"FE6", X"FE7", X"FE7", X"FE8", X"FE8", X"FE9", 
X"FE9", X"FEA", X"FEA", X"FEB", X"FEB", X"FEC", X"FEC", X"FED", 
X"FED", X"FEE", X"FEE", X"FEE", X"FEF", X"FEF", X"FF0", X"FF0", 
X"FF1", X"FF1", X"FF1", X"FF2", X"FF2", X"FF3", X"FF3", X"FF4", 
X"FF4", X"FF4", X"FF5", X"FF5", X"FF5", X"FF6", X"FF6", X"FF6", 
X"FF7", X"FF7", X"FF7", X"FF8", X"FF8", X"FF8", X"FF9", X"FF9", 
X"FF9", X"FFA", X"FFA", X"FFA", X"FFB", X"FFB", X"FFB", X"FFB", 
X"FFC", X"FFC", X"FFC", X"FFC", X"FFD", X"FFD", X"FFD", X"FFD", 
X"FFE", X"FFE", X"FFE", X"FFE", X"FFE", X"FFF", X"FFF", X"FFF", 
X"FFF", X"FFF", X"000", X"000", X"000", X"000", X"000", X"000", 
X"001", X"001", X"001", X"001", X"001", X"001", X"001", X"002", 
X"002", X"002", X"002", X"002", X"002", X"002", X"002", X"002", 
X"003", X"003", X"003", X"003", X"003", X"003", X"003", X"003", 
X"003", X"003", X"003", X"003", X"003", X"003", X"003", X"003", 
X"004", X"004", X"004", X"004", X"004", X"004", X"004", X"004", 
X"004", X"004", X"004", X"004", X"004", X"004", X"004", X"004", 
X"004", X"004", X"004", X"004", X"004", X"004", X"004", X"004", 
X"004", X"004", X"003", X"003", X"003", X"003", X"003", X"003", 
X"003", X"003", X"003", X"003", X"003", X"003", X"003", X"003", 
X"003", X"003", X"003", X"003", X"003", X"002", X"002", X"002", 
X"002", X"002", X"002", X"002", X"002", X"002", X"002", X"002", 
X"002", X"002", X"001", X"001", X"001", X"001", X"001", X"001", 
X"001", X"001", X"001", X"001", X"001", X"001", X"000", X"000", 
X"000", X"000", X"000", X"000", X"000", X"000", X"000", X"000", 
X"000", X"FFF", X"FFF", X"FFF", X"FFF", X"FFF", X"FFF", X"FFF", 
X"FFF", X"FFF", X"FFF", X"FFE", X"FFE", X"FFE", X"FFE", X"FFE", 
X"FFE", X"FFE", X"FFE", X"FFE", X"FFE", X"FFE", X"FFE", X"FFD", 
X"FFD", X"FFD", X"FFD", X"FFD", X"FFD", X"FFD", X"FFD", X"FFD", 
X"FFD", X"FFD", X"FFD", X"FFD", X"FFC", X"FFC", X"FFC", X"FFC", 
X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", 
X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFB", 
X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", 
X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", 
X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", X"FFB", 
X"FFB", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", 
X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", X"FFC", 
X"FFC", X"FFD", X"FFD", X"FFD", X"FFD", X"FFD", X"FFD", X"FFD", 
X"FFD", X"FFD", X"FFE", X"FFE", X"FFE", X"FFE", X"FFE", X"FFE", 
X"FFE", X"FFF", X"FFF", X"FFF", X"FFF", X"FFF", X"FFF", X"000", 
X"000", X"000", X"000", X"000", X"001", X"001", X"001", X"001", 
X"001", X"002", X"002", X"002", X"002", X"003", X"003", X"003", 
X"003", X"004", X"004", X"004", X"004", X"005", X"005", X"005", 
X"006", X"006", X"006", X"007", X"007", X"007", X"008", X"008", 
X"008", X"009", X"009", X"009", X"00A", X"00A", X"00A", X"00B", 
X"00B", X"00B", X"00C", X"00C", X"00D", X"00D", X"00E", X"00E", 
X"00E", X"00F", X"00F", X"010", X"010", X"011", X"011", X"011", 
X"012", X"012", X"013", X"013", X"014", X"014", X"015", X"015", 
X"016", X"016", X"017", X"017", X"018", X"018", X"019", X"01A", 
X"01A", X"01B", X"01B", X"01C", X"01C", X"01D", X"01E", X"01E", 
X"01F", X"01F", X"020", X"021", X"021", X"022", X"023", X"023", 
X"024", X"024", X"025", X"026", X"026", X"027", X"028", X"028", 
X"029", X"02A", X"02B", X"02B", X"02C", X"02D", X"02D", X"02E", 
X"02F", X"030", X"030", X"031", X"032", X"033", X"033", X"034", 
X"035", X"036", X"036", X"037", X"038", X"039", X"03A", X"03B", 
X"03B", X"03C", X"03D", X"03E", X"03F", X"040", X"040", X"041", 
X"042", X"043", X"044", X"045", X"046", X"047", X"048", X"048", 
X"049", X"04A", X"04B", X"04C", X"04D", X"04E", X"04F", X"050", 
X"051", X"052", X"053", X"054", X"055", X"056", X"057", X"058", 
X"059", X"05A", X"05B", X"05C", X"05D", X"05E", X"05F", X"060", 
X"061", X"062", X"063", X"064", X"065", X"066", X"067", X"068", 
X"069", X"06A", X"06B", X"06C", X"06D", X"06F", X"070", X"071", 
X"072", X"073", X"074", X"075", X"076", X"077", X"079", X"07A", 
X"07B", X"07C", X"07D", X"07E", X"07F", X"081", X"082", X"083", 
X"084", X"085", X"086", X"088", X"089", X"08A", X"08B", X"08C", 
X"08E", X"08F", X"090", X"091", X"092", X"094", X"095", X"096", 
X"097", X"099", X"09A", X"09B", X"09C", X"09D", X"09F", X"0A0", 
X"0A1", X"0A2", X"0A4", X"0A5", X"0A6", X"0A7", X"0A9", X"0AA", 
X"0AB", X"0AD", X"0AE", X"0AF", X"0B0", X"0B2", X"0B3", X"0B4", 
X"0B6", X"0B7", X"0B8", X"0B9", X"0BB", X"0BC", X"0BD", X"0BF", 
X"0C0", X"0C1", X"0C3", X"0C4", X"0C5", X"0C7", X"0C8", X"0C9", 
X"0CB", X"0CC", X"0CD", X"0CE", X"0D0", X"0D1", X"0D3", X"0D4", 
X"0D5", X"0D6", X"0D8", X"0D9", X"0DA", X"0DC", X"0DD", X"0DF", 
X"0E0", X"0E1", X"0E3", X"0E4", X"0E5", X"0E6", X"0E8", X"0E9", 
X"0EB", X"0EC", X"0ED", X"0EF", X"0F0", X"0F1", X"0F3", X"0F4", 
X"0F5", X"0F7", X"0F8", X"0F9", X"0FB", X"0FC", X"0FD", X"0FF", 
X"100", X"101", X"103", X"104", X"105", X"107", X"108", X"109", 
X"10A", X"10C", X"10D", X"10E", X"110", X"111", X"112", X"114", 
X"115", X"116", X"118", X"119", X"11A", X"11C", X"11D", X"11E", 
X"11F", X"121", X"122", X"123", X"124", X"126", X"127", X"128", 
X"12A", X"12B", X"12C", X"12D", X"12F", X"130", X"131", X"132", 
X"134", X"135", X"136", X"137", X"139", X"13A", X"13B", X"13C", 
X"13D", X"13F", X"140", X"141", X"142", X"143", X"145", X"146", 
X"147", X"148", X"149", X"14A", X"14C", X"14D", X"14E", X"14F", 
X"150", X"151", X"152", X"154", X"155", X"156", X"157", X"158", 
X"159", X"15A", X"15B", X"15C", X"15D", X"15F", X"160", X"161", 
X"162", X"163", X"164", X"165", X"166", X"167", X"168", X"169", 
X"16A", X"16B", X"16C", X"16D", X"16E", X"16F", X"170", X"171", 
X"171", X"172", X"173", X"174", X"175", X"176", X"177", X"178", 
X"179", X"179", X"17A", X"17B", X"17C", X"17D", X"17E", X"17E", 
X"17F", X"180", X"181", X"182", X"182", X"183", X"184", X"185", 
X"185", X"186", X"187", X"188", X"188", X"189", X"18A", X"18A", 
X"18B", X"18C", X"18C", X"18D", X"18D", X"18E", X"18F", X"18F", 
X"190", X"190", X"191", X"191", X"192", X"193", X"193", X"194", 
X"194", X"195", X"195", X"195", X"196", X"196", X"197", X"197", 
X"198", X"198", X"198", X"199", X"199", X"199", X"19A", X"19A", 
X"19A", X"19B", X"19B", X"19B", X"19C", X"19C", X"19C", X"19C", 
X"19D", X"19D", X"19D", X"19D", X"19D", X"19D", X"19E", X"19E", 
X"19E", X"19E", X"19E", X"19E", X"19E", X"19E", X"19E", X"19E", 
X"19E", X"19E", X"19E", X"19E", X"19E", X"19E", X"19E", X"19E", 
X"19E", X"19E", X"19E", X"19D", X"19D", X"19D", X"19D", X"19D", 
X"19D", X"19C", X"19C", X"19C", X"19C", X"19B", X"19B", X"19B", 
X"19A", X"19A", X"19A", X"199", X"199", X"199", X"198", X"198", 
X"197", X"197", X"196", X"196", X"195", X"195", X"194", X"194", 
X"193", X"193", X"192", X"191", X"191", X"190", X"18F", X"18F", 
X"18E", X"18D", X"18D", X"18C", X"18B", X"18B", X"18A", X"189", 
X"188", X"187", X"186", X"186", X"185", X"184", X"183", X"182", 
X"181", X"180", X"17F", X"17E", X"17D", X"17C", X"17B", X"17A", 
X"179", X"178", X"177", X"176", X"175", X"173", X"172", X"171", 
X"170", X"16F", X"16D", X"16C", X"16B", X"16A", X"168", X"167", 
X"166", X"164", X"163", X"162", X"160", X"15F", X"15D", X"15C", 
X"15B", X"159", X"157", X"156", X"155", X"153", X"151", X"150", 
X"14E", X"14D", X"14B", X"149", X"148", X"146", X"144", X"142", 
X"141", X"13F", X"13D", X"13B", X"13A", X"138", X"136", X"134", 
X"132", X"130", X"12F", X"12D", X"12B", X"129", X"127", X"125", 
X"123", X"121", X"11F", X"11D", X"11B", X"119", X"116", X"114", 
X"112", X"110", X"10E", X"10C", X"10A", X"107", X"105", X"103", 
X"101", X"0FE", X"0FC", X"0FA", X"0F8", X"0F5", X"0F3", X"0F0", 
X"0EE", X"0EC", X"0E9", X"0E7", X"0E4", X"0E2", X"0DF", X"0DD", 
X"0DA", X"0D8", X"0D5", X"0D3", X"0D0", X"0CE", X"0CB", X"0C8", 
X"0C5", X"0C3", X"0C0", X"0BD", X"0BB", X"0B8", X"0B5", X"0B3", 
X"0B0", X"0AD", X"0AA", X"0A7", X"0A5", X"0A2", X"09F", X"09C", 
X"099", X"096", X"093", X"090", X"08D", X"08A", X"088", X"085", 
X"081", X"07E", X"07B", X"078", X"075", X"072", X"06F", X"06C", 
X"069", X"066", X"063", X"060", X"05C", X"059", X"056", X"053", 
X"050", X"04C", X"049", X"046", X"042", X"03F", X"03C", X"038", 
X"035", X"032", X"02E", X"02B", X"028", X"024", X"021", X"01D", 
X"01A", X"017", X"013", X"010", X"00C", X"009", X"005", X"002", 
X"FFE", X"FFB", X"FF7", X"FF3", X"FF0", X"FEC", X"FE9", X"FE5", 
X"FE1", X"FDE", X"FDA", X"FD6", X"FD3", X"FCF", X"FCC", X"FC8", 
X"FC4", X"FC0", X"FBD", X"FB9", X"FB5", X"FB1", X"FAD", X"FAA", 
X"FA6", X"FA2", X"F9E", X"F9B", X"F97", X"F93", X"F8F", X"F8B", 
X"F87", X"F83", X"F80", X"F7C", X"F78", X"F74", X"F70", X"F6C", 
X"F68", X"F64", X"F60", X"F5C", X"F59", X"F55", X"F50", X"F4C", 
X"F49", X"F45", X"F41", X"F3C", X"F38", X"F35", X"F31", X"F2C", 
X"F28", X"F25", X"F20", X"F1C", X"F18", X"F14", X"F10", X"F0C", 
X"F08", X"F04", X"F00", X"EFC", X"EF7", X"EF3", X"EEF", X"EEB", 
X"EE7", X"EE3", X"EDF", X"EDB", X"ED7", X"ED2", X"ECF", X"ECA", 
X"EC6", X"EC2", X"EBE", X"EBA", X"EB5", X"EB1", X"EAD", X"EA9", 
X"EA5", X"EA1", X"E9C", X"E98", X"E94", X"E90", X"E8C", X"E87", 
X"E83", X"E7F", X"E7B", X"E77", X"E73", X"E6E", X"E6A", X"E66", 
X"E62", X"E5E", X"E59", X"E55", X"E51", X"E4D", X"E49", X"E44", 
X"E40", X"E3C", X"E38", X"E34", X"E2F", X"E2C", X"E27", X"E23", 
X"E1F", X"E1B", X"E17", X"E12", X"E0E", X"E0A", X"E06", X"E02", 
X"DFD", X"DF9", X"DF5", X"DF1", X"DED", X"DE9", X"DE5", X"DE1", 
X"DDC", X"DD8", X"DD4", X"DD0", X"DCC", X"DC8", X"DC4", X"DC0", 
X"DBC", X"DB7", X"DB3", X"DAF", X"DAB", X"DA7", X"DA3", X"D9F", 
X"D9B", X"D97", X"D93", X"D8F", X"D8B", X"D87", X"D83", X"D7F", 
X"D7B", X"D77", X"D73", X"D6F", X"D6B", X"D67", X"D63", X"D5F", 
X"D5B", X"D57", X"D53", X"D4F", X"D4B", X"D47", X"D43", X"D3F", 
X"D3B", X"D38", X"D34", X"D30", X"D2C", X"D28", X"D25", X"D21", 
X"D1D", X"D19", X"D15", X"D11", X"D0E", X"D0A", X"D06", X"D02", 
X"CFF", X"CFB", X"CF7", X"CF4", X"CF0", X"CEC", X"CE9", X"CE5", 
X"CE1", X"CDD", X"CDA", X"CD6", X"CD3", X"CCF", X"CCB", X"CC8", 
X"CC4", X"CC1", X"CBD", X"CBA", X"CB6", X"CB3", X"CAF", X"CAC", 
X"CA8", X"CA5", X"CA1", X"C9E", X"C9B", X"C97", X"C94", X"C90", 
X"C8D", X"C8A", X"C86", X"C83", X"C80", X"C7D", X"C79", X"C76", 
X"C73", X"C70", X"C6C", X"C69", X"C66", X"C63", X"C60", X"C5C", 
X"C59", X"C56", X"C53", X"C50", X"C4D", X"C4A", X"C47", X"C44", 
X"C41", X"C3E", X"C3B", X"C38", X"C35", X"C32", X"C2F", X"C2C", 
X"C29", X"C26", X"C24", X"C21", X"C1E", X"C1B", X"C18", X"C15", 
X"C13", X"C10", X"C0D", X"C0A", X"C08", X"C05", X"C02", X"C00", 
X"BFD", X"BFA", X"BF8", X"BF5", X"BF3", X"BF0", X"BED", X"BEB", 
X"BE9", X"BE6", X"BE3", X"BE1", X"BDF", X"BDC", X"BDA", X"BD7", 
X"BD5", X"BD3", X"BD0", X"BCE", X"BCB", X"BC9", X"BC7", X"BC5", 
X"BC2", X"BC0", X"BBE", X"BBC", X"BBA", X"BB8", X"BB5", X"BB3", 
X"BB1", X"BAF", X"BAD", X"BAB", X"BA9", X"BA7", X"BA5", X"BA3", 
X"BA1", X"B9F", X"B9D", X"B9B", X"B99", X"B97", X"B95", X"B93", 
X"B91", X"B90", X"B8E", X"B8C", X"B8A", X"B88", X"B87", X"B85", 
X"B83", X"B81", X"B80", X"B7E", X"B7C", X"B7B", X"B79", X"B78", 
X"B76", X"B74", X"B73", X"B71", X"B70", X"B6E", X"B6D", X"B6B", 
X"B6A", X"B68", X"B67", X"B65", X"B64", X"B63", X"B61", X"B60", 
X"B5F", X"B5D", X"B5C", X"B5B", X"B59", X"B58", X"B57", X"B56", 
X"B54", X"B53", X"B52", X"B51", X"B50", X"B4F", X"B4D", X"B4C", 
X"B4B", X"B4A", X"B49", X"B48", X"B47", X"B46", X"B45", X"B44", 
X"B43", X"B42", X"B41", X"B40", X"B3F", X"B3E", X"B3D", X"B3C", 
X"B3B", X"B3A", X"B3A", X"B39", X"B38", X"B37", X"B36", X"B35", 
X"B35", X"B34", X"B33", X"B32", X"B32", X"B31", X"B30", X"B2F", 
X"B2F", X"B2E", X"B2D", X"B2D", X"B2C", X"B2B", X"B2B", X"B2A", 
X"B2A", X"B29", X"B28", X"B28", X"B27", X"B27", X"B26", X"B26", 
X"B25", X"B25", X"B24", X"B24", X"B23", X"B23", X"B22", X"B22", 
X"B21", X"B21", X"B20", X"B20", X"B1F", X"B1F", X"B1F", X"B1E", 
X"B1E", X"B1D", X"B1D", X"B1D", X"B1C", X"B1C", X"B1C", X"B1B", 
X"B1B", X"B1B", X"B1A", X"B1A", X"B1A", X"B19", X"B19", X"B19", 
X"B19", X"B18", X"B18", X"B18", X"B17", X"B17", X"B17", X"B17", 
X"B16", X"B16", X"B16", X"B16", X"B15", X"B15", X"B15", X"B15", 
X"B15", X"B14", X"B14", X"B14", X"B14", X"B14", X"B13", X"B13", 
X"B13", X"B13", X"B13", X"B12", X"B12", X"B12", X"B12", X"B12", 
X"B12", X"B11", X"B11", X"B11", X"B11", X"B11", X"B10", X"B10", 
X"B10", X"B10", X"B10", X"B10", X"B0F", X"B0F", X"B0F", X"B0F", 
X"B0F", X"B0F", X"B0E", X"B0E", X"B0E", X"B0E", X"B0E", X"B0D", 
X"B0D", X"B0D", X"B0D", X"B0D", X"B0C", X"B0C", X"B0C", X"B0C", 
X"B0C", X"B0B", X"B0B", X"B0B", X"B0B", X"B0A", X"B0A", X"B0A", 
X"B0A", X"B09", X"B09", X"B09", X"B09", X"B08", X"B08", X"B08", 
X"B08", X"B07", X"B07", X"B07", X"B06", X"B06", X"B06", X"B05", 
X"B05", X"B05", X"B04", X"B04", X"B04", X"B03", X"B03", X"B02", 
X"B02", X"B02", X"B01", X"B01", X"B00", X"B00", X"B00", X"AFF", 
X"AFF", X"AFE", X"AFE", X"AFD", X"AFD", X"AFC", X"AFC", X"AFB", 
X"AFB", X"AFA", X"AFA", X"AF9", X"AF8", X"AF8", X"AF7", X"AF7", 
X"AF6", X"AF6", X"AF5", X"AF4", X"AF4", X"AF3", X"AF2", X"AF2", 
X"AF1", X"AF0", X"AEF", X"AEF", X"AEE", X"AED", X"AED", X"AEC", 
X"AEB", X"AEA", X"AE9", X"AE9", X"AE8", X"AE7", X"AE6", X"AE5", 
X"AE4", X"AE3", X"AE3", X"AE2", X"AE1", X"AE0", X"ADF", X"ADE", 
X"ADD", X"ADC", X"ADB", X"ADA", X"AD9", X"AD8", X"AD7", X"AD6", 
X"AD5", X"AD4", X"AD3", X"AD1", X"AD0", X"ACF", X"ACE", X"ACD", 
X"ACC", X"ACA", X"AC9", X"AC8", X"AC7", X"AC6", X"AC4", X"AC3", 
X"AC2", X"AC0", X"ABF", X"ABE", X"ABC", X"ABB", X"ABA", X"AB8", 
X"AB7", X"AB6", X"AB4", X"AB3", X"AB1", X"AB0", X"AAE", X"AAD", 
X"AAB", X"AAA", X"AA8", X"AA7", X"AA5", X"AA4", X"AA2", X"AA0", 
X"A9F", X"A9D", X"A9C", X"A9A", X"A98", X"A97", X"A95", X"A93", 
X"A91", X"A90", X"A8E", X"A8C", X"A8A", X"A89", X"A87", X"A85", 
X"A83", X"A81", X"A80", X"A7E", X"A7C", X"A7A", X"A78", X"A76", 
X"A74", X"A72", X"A70", X"A6E", X"A6C", X"A6A", X"A68", X"A66", 
X"A64", X"A62", X"A60", X"A5E", X"A5C", X"A5A", X"A58", X"A56", 
X"A54", X"A51", X"A4F", X"A4D", X"A4B", X"A49", X"A47", X"A44", 
X"A42", X"A40", X"A3E", X"A3B", X"A39", X"A37", X"A35", X"A32", 
X"A30", X"A2E", X"A2B", X"A29", X"A27", X"A25", X"A22", X"A20", 
X"A1D", X"A1B", X"A19", X"A16", X"A14", X"A11", X"A0F", X"A0D", 
X"A0A", X"A08", X"A05", X"A03", X"A00", X"9FE", X"9FB", X"9F9", 
X"9F6", X"9F4", X"9F1", X"9EF", X"9EC", X"9EA", X"9E7", X"9E5", 
X"9E2", X"9E0", X"9DD", X"9DB", X"9D8", X"9D5", X"9D3", X"9D0", 
X"9CE", X"9CB", X"9C8", X"9C6", X"9C3", X"9C1", X"9BE", X"9BC", 
X"9B9", X"9B6", X"9B4", X"9B1", X"9AE", X"9AC", X"9A9", X"9A6", 
X"9A4", X"9A1", X"99F", X"99C", X"999", X"997", X"994", X"991", 
X"98F", X"98C", X"98A", X"987", X"984", X"982", X"97F", X"97C", 
X"97A", X"977", X"975", X"972", X"96F", X"96D", X"96A", X"968", 
X"965", X"963", X"960", X"95D", X"95B", X"958", X"956", X"953", 
X"950", X"94E", X"94C", X"949", X"946", X"944", X"941", X"93F", 
X"93C", X"93A", X"937", X"935", X"932", X"930", X"92D", X"92B", 
X"929", X"926", X"924", X"921", X"91F", X"91D", X"91A", X"918", 
X"916", X"913", X"911", X"90E", X"90C", X"90A", X"908", X"905", 
X"903", X"901", X"8FF", X"8FD", X"8FA", X"8F8", X"8F6", X"8F4", 
X"8F2", X"8F0", X"8EE", X"8EB", X"8E9", X"8E7", X"8E5", X"8E3", 
X"8E1", X"8DF", X"8DD", X"8DB", X"8D9", X"8D8", X"8D6", X"8D4", 
X"8D2", X"8D0", X"8CE", X"8CD", X"8CB", X"8C9", X"8C7", X"8C6", 
X"8C4", X"8C2", X"8C1", X"8BF", X"8BD", X"8BC", X"8BA", X"8B9", 
X"8B7", X"8B6", X"8B4", X"8B3", X"8B1", X"8B0", X"8AF", X"8AD", 
X"8AC", X"8AB", X"8A9", X"8A8", X"8A7", X"8A6", X"8A5", X"8A3", 
X"8A2", X"8A1", X"8A0", X"89F", X"89E", X"89D", X"89C", X"89B", 
X"89B", X"89A", X"899", X"898", X"897", X"897", X"896", X"895", 
X"895", X"894", X"893", X"893", X"892", X"892", X"891", X"891", 
X"891", X"890", X"890", X"890", X"88F", X"88F", X"88F", X"88F", 
X"88F", X"88F", X"88F", X"88F", X"88F", X"88F", X"88F", X"88F", 
X"88F", X"88F", X"890", X"890", X"890", X"890", X"891", X"891", 
X"892", X"892", X"893", X"893", X"894", X"895", X"895", X"896", 
X"897", X"898", X"898", X"899", X"89A", X"89B", X"89C", X"89D", 
X"89E", X"89F", X"8A1", X"8A2", X"8A3", X"8A4", X"8A6", X"8A7", 
X"8A8", X"8AA", X"8AB", X"8AD", X"8AF", X"8B0", X"8B2", X"8B3", 
X"8B5", X"8B7", X"8B9", X"8BB", X"8BD", X"8BE", X"8C0", X"8C3", 
X"8C5", X"8C7", X"8C9", X"8CB", X"8CD", X"8D0", X"8D2", X"8D4", 
X"8D7", X"8D9", X"8DC", X"8DE", X"8E1", X"8E4", X"8E6", X"8E9", 
X"8EC", X"8EF", X"8F2", X"8F5", X"8F8", X"8FB", X"8FE", X"901", 
X"904", X"907", X"90A", X"90E", X"911", X"914", X"918", X"91B", 
X"91F", X"922", X"926", X"92A", X"92D", X"931", X"935", X"939", 
X"93C", X"940", X"944", X"949", X"94C", X"951", X"955", X"959", 
X"95D", X"961", X"966", X"96A", X"96F", X"973", X"978", X"97C", 
X"981", X"985", X"98A", X"98F", X"994", X"999", X"99D", X"9A3", 
X"9A8", X"9AD", X"9B1", X"9B7", X"9BC", X"9C1", X"9C6", X"9CC", 
X"9D1", X"9D7", X"9DC", X"9E1", X"9E7", X"9ED", X"9F2", X"9F8", 
X"9FD", X"A03", X"A09", X"A0F", X"A15", X"A1B", X"A21", X"A26", 
X"A2D", X"A33", X"A39", X"A40", X"A45", X"A4C", X"A52", X"A59", 
X"A5F", X"A65", X"A6C", X"A73", X"A79", X"A7F", X"A86", X"A8D", 
X"A93", X"A9A", X"AA1", X"AA8", X"AAF", X"AB6", X"ABD", X"AC4", 
X"ACC", X"AD2", X"AD9", X"AE1", X"AE8", X"AEF", X"AF7", X"AFE", 
X"B06", X"B0D", X"B14", X"B1C", X"B24", X"B2B", X"B32", X"B3A", 
X"B42", X"B4A", X"B51", X"B59", X"B61", X"B6A", X"B71", X"B79", 
X"B81", X"B89", X"B92", X"B99", X"BA2", X"BAA", X"BB2", X"BBA", 
X"BC3", X"BCB", X"BD4", X"BDB", X"BE4", X"BED", X"BF5", X"BFE", 
X"C06", X"C0F", X"C18", X"C21", X"C29", X"C32", X"C3B", X"C44", 
X"C4C", X"C55", X"C5E", X"C67", X"C6F", X"C79", X"C82", X"C8B", 
X"C94", X"C9D", X"CA6", X"CAF", X"CB9", X"CC1", X"CCB", X"CD4", 
X"CDE", X"CE6", X"CF0", X"CFA", X"D03", X"D0D", X"D15", X"D1F", 
X"D29", X"D33", X"D3B", X"D45", X"D4F", X"D59", X"D62", X"D6C", 
X"D76", X"D7F", X"D88", X"D92", X"D9C", X"DA6", X"DB0", X"DBA", 
X"DC4", X"DCE", X"DD8", X"DE1", X"DEB", X"DF5", X"DFF", X"E09", 
X"E13", X"E1D", X"E27", X"E32", X"E3B", X"E45", X"E4F", X"E5A", 
X"E63", X"E6E", X"E78", X"E82", X"E8C", X"E96", X"EA0", X"EAB", 
X"EB4", X"EBF", X"EC9", X"ED4", X"EDE", X"EE8", X"EF2", X"EFD", 
X"F07", X"F11", X"F1B", X"F26", X"F30", X"F3A", X"F45", X"F4F", 
X"F5A", X"F64", X"F6E", X"F78", X"F83", X"F8E", X"F97", X"FA2", 
X"FAD", X"FB7", X"FC1", X"FCB", X"FD6", X"FE1", X"FEA", X"FF5"
);

signal data : std_logic_vector(31 downto 0);

begin

rom_select: process (clk, en)
begin
	if (rising_edge(clk)) then
    if (en = '1') then
		data <= (SIN_ROM(conv_integer(address_reg)) & x"00000");
		sin_out <= std_logic_vector(shift_right(signed(data), 20));
    end if;
  end if;
end process rom_select;

end rtl;
