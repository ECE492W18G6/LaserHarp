--------------------------------------------------------------------------------------------------------------------------
-- Original Authors : Simon Doherty, Eric Lunty, Kyle Brooks, Peter Roland						--
-- Date created: N/A 													--
--															--
-- Additional Authors : Randi Derbyshire, Adam Narten, Oliver Rarog, Celeste Chiasson					--
-- Date edited: February 5, 2018											--
--															--
-- This program takes a value from the synthesizer.vhd file and runs it through the 12-bit ROM to find the 	 	--
-- respective sine wave value. 												--
--------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;               -- Needed for shifts

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
X"C54", X"C5D", X"C66", X"C6E", X"C76", X"C7F", X"C88", X"C90", 
X"C99", X"CA2", X"CAB", X"CB3", X"CBB", X"CC4", X"CCD", X"CD5", 
X"CDE", X"CE7", X"CEF", X"CF8", X"D00", X"D09", X"D12", X"D1B", 
X"D23", X"D2C", X"D34", X"D3D", X"D45", X"D4E", X"D57", X"D60", 
X"D69", X"D71", X"D79", X"D82", X"D8B", X"D93", X"D9C", X"DA5", 
X"DAE", X"DB6", X"DBE", X"DC7", X"DD0", X"DD8", X"DE1", X"DEA", 
X"DF3", X"DFB", X"E03", X"E0C", X"E15", X"E1E", X"E26", X"E2F", 
X"E38", X"E40", X"E48", X"E51", X"E5A", X"E63", X"E6C", X"E74", 
X"E7D", X"E85", X"E8E", X"E96", X"E9F", X"EA8", X"EB1", X"EB9", 
X"EC1", X"ECA", X"ED3", X"EDB", X"EE4", X"EED", X"EF6", X"EFE", 
X"F06", X"F0F", X"F18", X"F21", X"F29", X"F32", X"F3B", X"F43", 
X"F4B", X"F54", X"F5D", X"F66", X"F6F", X"F77", X"F80", X"F88", 
X"F91", X"F99", X"FA2", X"FAB", X"FB4", X"FBC", X"FC5", X"FCD", 
X"FD6", X"FDE", X"FE7", X"FF0", X"FF9", X"002", X"00A", X"012", 
X"01B", X"024", X"02C", X"035", X"03E", X"047", X"04F", X"057", 
X"060", X"069", X"072", X"07A", X"083", X"08B", X"094", X"09C", 
X"0A5", X"0AE", X"0B7", X"0BF", X"0C8", X"0D0", X"0D9", X"0E1", 
X"0EA", X"0F3", X"0FC", X"105", X"10D", X"115", X"11E", X"127", 
X"12F", X"138", X"141", X"14A", X"152", X"15A", X"163", X"16C", 
X"175", X"17D", X"186", X"18F", X"197", X"19F", X"1A8", X"1B1", 
X"1BA", X"1C2", X"1CB", X"1D4", X"1DC", X"1E4", X"1ED", X"1F6", 
X"1FF", X"208", X"210", X"219", X"221", X"22A", X"232", X"23B", 
X"244", X"24D", X"255", X"25E", X"266", X"26F", X"278", X"280", 
X"289", X"292", X"29A", X"2A2", X"2AB", X"2B4", X"2BD", X"2C5", 
X"2CE", X"2D7", X"2DF", X"2E7", X"2F0", X"2F9", X"302", X"30B", 
X"313", X"31C", X"324", X"32D", X"335", X"33E", X"347", X"350", 
X"358", X"361", X"369", X"372", X"37B", X"383", X"38C", X"395", 
X"39E", X"3A6", X"3AE", X"3B7", X"3C0", X"3C8", X"3D1", X"3DA", 
X"3E3", X"3EB", X"3F3", X"3FC", X"405", X"40E", X"416", X"41F", 
X"428", X"430", X"438", X"441", X"44A", X"453", X"45B", X"464", 
X"46C", X"475", X"47E", X"486", X"48F", X"498", X"4A1", X"4A9", 
X"4B1", X"4BA", X"4C3", X"4CB", X"4D4", X"4DD", X"4E6", X"4EE", 
X"4F6", X"4FF", X"508", X"511", X"519", X"522", X"52B", X"533", 
X"53B", X"544", X"54D", X"556", X"55E", X"567", X"570", X"578", 
X"581", X"589", X"592", X"59B", X"5A4", X"5AC", X"5B5", X"5BD", 
X"5C6", X"5CE", X"5D7", X"5E0", X"5E9", X"5F1", X"5FA", X"602", 
X"60B", X"614", X"61C", X"625", X"62E", X"636", X"63E", X"647", 
X"650", X"659", X"661", X"66A", X"673", X"67B", X"684", X"68C", 
X"695", X"69E", X"6A7", X"6AF", X"6B8", X"6C0", X"6C9", X"6D1", 
X"6DA", X"6E3", X"6EC", X"6F4", X"6FD", X"705", X"70E", X"717", 
X"71F", X"728", X"731", X"73A", X"742", X"74A", X"753", X"75C", 
X"764", X"76D", X"776", X"77F", X"787", X"78F", X"798", X"7A1", 
X"7AA", X"7B2", X"7BB", X"7C4", X"7CC", X"7D4", X"7DD", X"7E6", 
X"7EF", X"7F7", X"800", X"808", X"811", X"81A", X"822", X"82B", 
X"834", X"83D", X"845", X"84D", X"856", X"85F", X"867", X"870", 
X"879", X"882", X"88A", X"892", X"89B", X"8A4", X"8AD", X"8B5", 
X"8BE", X"8C7", X"8CF", X"8D7", X"8E0", X"8E9", X"8F2", X"8FA", 
X"903", X"90C", X"914", X"91D", X"925", X"92E", X"937", X"940", 
X"948", X"951", X"959", X"962", X"96A", X"973", X"97C", X"985", 
X"98E", X"996", X"99E", X"9A7", X"9B0", X"9B8", X"9C1", X"9CA", 
X"9D2", X"9DB", X"9E3", X"9EC", X"9F5", X"9FD", X"A06", X"A0F", 
X"A17", X"A20", X"A28", X"A31", X"A3A", X"A43", X"A4B", X"A54", 
X"A5C", X"A65", X"A6D", X"A76", X"A7F", X"A88", X"A91", X"A99", 
X"AA1", X"AAA", X"AB3", X"ABB", X"AC4", X"ACD", X"AD6", X"ADE", 
X"AE6", X"AEF", X"AF8", X"B00", X"B09", X"B12", X"B1B", X"B23", 
X"B2B", X"B34", X"B3D", X"B46", X"B4E", X"B57", X"B60", X"B68", 
X"B70", X"B79", X"B82", X"B8B", X"B94", X"B9C", X"BA4", X"BAD", 
X"BB6", X"BBE", X"BC7", X"BD0", X"BD9", X"BE1", X"BE9", X"BF2", 
X"BFB", X"C03", X"C0C", X"C15", X"C1E", X"C26", X"C2E", X"C37", 
X"C40", X"C49", X"C51", X"C5A", X"C63", X"C6B", X"C73", X"C7C", 
X"C85", X"C8E", X"C97", X"C9F", X"CA8", X"CB0", X"CB9", X"CC1", 
X"CCA", X"CD3", X"CDC", X"CE4", X"CED", X"CF5", X"CFE", X"D06", 
X"D0F", X"D18", X"D21", X"D2A", X"D32", X"D3A", X"D43", X"D4C", 
X"D54", X"D5D", X"D66", X"D6E", X"D77", X"D7F", X"D88", X"D91", 
X"D9A", X"DA2", X"DAB", X"DB3", X"DBC", X"DC4", X"DCD", X"DD6", 
X"DDF", X"DE7", X"DF0", X"DF8", X"E01", X"E09", X"E12", X"E1B", 
X"E24", X"E2D", X"E35", X"E3D", X"E46", X"E4F", X"E57", X"E60", 
X"E69", X"E72", X"E7A", X"E82", X"E8B", X"E94", X"E9C", X"EA5", 
X"EAE", X"EB7", X"EBF", X"EC7", X"ED0", X"ED9", X"EE2", X"EEA", 
X"EF3", X"EFC", X"F04", X"F0C", X"F15", X"F1E", X"F27", X"F30", 
X"F38", X"F41", X"F49", X"F52", X"F5A", X"F63", X"F6C", X"F75", 
X"F7D", X"F85", X"F8E", X"F97", X"F9F", X"FA8", X"FB1", X"FBA", 
X"FC2", X"FCA", X"FD3", X"FDC", X"FE5", X"FED", X"FF6", X"FFF", 
X"007", X"00F", X"961", X"96A", X"972", X"97B", X"983", X"98C", 
X"995", X"99E", X"9A6", X"9AF", X"9B7", X"9C0", X"9C8", X"9D1", 
X"9DA", X"9E3", X"9EB", X"9F4", X"9FC", X"A05", X"A0E", X"A16", 
X"A1F", X"A28", X"A31", X"A39", X"A41", X"A4A", X"A53", X"A5B", 
X"A64", X"A6D", X"A76", X"A7E", X"A86", X"A8F", X"A98", X"AA1", 
X"AA9", X"AB2", X"ABA", X"AC3", X"ACB", X"AD4", X"ADD", X"AE6", 
X"AEE", X"AF7", X"AFF", X"B08", X"B11", X"B19", X"B22", X"B2B", 
X"B34", X"B3C", X"B44", X"B4D", X"B56", X"B5E", X"B67", X"B70", 
X"B79", X"B81", X"B89", X"B92", X"B9B", X"BA4", X"BAC", X"BB5", 
X"BBE", X"BC6", X"BCE", X"BD7", X"BE0", X"BE9", X"BF1", X"BFA", 
X"C03", X"C0B", X"C14", X"C1C", X"C25", X"C2E", X"C37", X"C3F", 
X"C48", X"C50", X"C59", X"C61", X"C6A", X"C73", X"C7C", X"C84", 
X"C8C", X"C95", X"C9E", X"CA7", X"CAF", X"CB8", X"CC1", X"CC9", 
X"CD1", X"CDA", X"CE3", X"CEC", X"CF4", X"CFD", X"D06", X"D0E", 
X"D17", X"D1F", X"D28", X"D31", X"D3A", X"D42", X"D4B", X"D53", 
X"D5C", X"D64", X"D6D", X"D76", X"D7F", X"D88", X"D90", X"D98", 
X"DA1", X"DAA", X"DB2", X"DBB", X"DC4", X"DCD", X"DD5", X"DDD", 
X"DE6", X"DEF", X"DF7", X"E00", X"E09", X"E12", X"E1A", X"E22", 
X"E2B", X"E34", X"E3D", X"E45", X"E4E", X"E56", X"E5F", X"E67", 
X"E70", X"E79", X"E82", X"E8B", X"E93", X"E9B", X"EA4", X"EAD", 
X"EB5", X"EBE", X"EC7", X"ED0", X"ED8", X"EE0", X"EE9", X"EF2", 
X"EFA", X"F03", X"F0C", X"F15", X"F1D", X"F25", X"F2E", X"F37", 
X"F40", X"F48", X"F51", X"F5A", X"F62", X"F6A", X"F73", X"F7C", 
X"F85", X"F8E", X"F96", X"F9F", X"FA7", X"FB0", X"FB8", X"FC1", 
X"FCA", X"FD3", X"FDB", X"FE4", X"FEC", X"FF5", X"FFD", X"006", 
X"00F", X"018", X"020", X"029", X"031", X"03A", X"043", X"04B", 
X"054", X"05D", X"065", X"06D", X"076", X"07F", X"088", X"091", 
X"099", X"0A2", X"0AA", X"0B3", X"0BB", X"0C4", X"0CD", X"0D6", 
X"0DE", X"0E7", X"0EF", X"0F8", X"100", X"109", X"112", X"11B", 
X"124", X"12C", X"134", X"13D", X"4A4", X"4AC", X"4B5", X"4BD", 
X"4C6", X"4CE", X"4D7", X"4E0", X"4E9", X"4F2", X"4FA", X"502", 
X"50B", X"514", X"51C", X"525", X"52E", X"537", X"53F", X"547", 
X"550", X"559", X"561", X"56A", X"573", X"57C", X"584", X"58C", 
X"595", X"59E", X"5A7", X"5AF", X"5B8", X"5C1", X"5C9", X"5D1", 
X"5DA", X"5E3", X"5EC", X"5F5", X"5FD", X"606", X"60E", X"617", 
X"61F", X"628", X"631", X"63A", X"642", X"64A", X"653", X"65C", 
X"664", X"66D", X"676", X"67F", X"687", X"68F", X"698", X"6A1", 
X"6AA", X"6B2", X"6BB", X"6C4", X"6CC", X"6D4", X"6DD", X"6E6", 
X"6EF", X"6F8", X"700", X"709", X"711", X"71A", X"722", X"72B", 
X"734", X"73D", X"745", X"74E", X"756", X"75F", X"767", X"770", 
X"779", X"782", X"78B", X"793", X"79B", X"7A4", X"7AD", X"7B5", 
X"7BE", X"7C7", X"7D0", X"7D8", X"7E0", X"7E9", X"7F2", X"7FB", 
X"803", X"80C", X"814", X"81D", X"825", X"82E", X"837", X"840", 
X"848", X"851", X"859", X"862", X"86A", X"873", X"87C", X"885", 
X"88E", X"896", X"89E", X"8A7", X"8B0", X"8B8", X"8C1", X"8CA", 
X"8D3", X"8DB", X"8E3", X"8EC", X"8F5", X"8FE", X"906", X"90F", 
X"918", X"920", X"928", X"931", X"93A", X"943", X"94B", X"954", 
X"95D", X"965", X"96D", X"976", X"97F", X"988", X"991", X"999", 
X"9A2", X"9AA", X"9B3", X"9BB", X"9C4", X"9CD", X"9D6", X"9DE", 
X"9E6", X"9EF", X"9F8", X"A01", X"A09", X"A12", X"A1B", X"A23", 
X"A2B", X"A34", X"A3D", X"A46", X"A4E", X"A57", X"A60", X"A68", 
X"A70", X"A79", X"A82", X"A8B", X"A94", X"A9C", X"AA5", X"AAD", 
X"AB6", X"ABE", X"AC7", X"AD0", X"AD9", X"AE1", X"AEA", X"AF2", 
X"AFB", X"B04", X"B0C", X"B15", X"B1E", X"B27", X"B2F", X"B37", 
X"B40", X"B49", X"B51", X"B5A", X"B63", X"B6C", X"B74", X"B7C", 
X"B85", X"B8E", X"B97", X"B9F", X"BA8", X"BB0", X"BB9", X"BC1", 
X"BCA", X"BD3", X"BDC", X"BE4", X"BED", X"BF5", X"BFE", X"C06", 
X"C0F", X"C18", X"C21", X"C2A", X"C32", X"C3A", X"C43", X"C4C", 
X"C54", X"C5D", X"C66", X"C6F", X"C77", X"C7F", X"C88", X"C91", 
X"C9A", X"CA2", X"CAB", X"CB4", X"CBC", X"CC4", X"CCD", X"CD6", 
X"CDF", X"CE7", X"CF0", X"CF9", X"D01", X"D09", X"D12", X"D1B", 
X"D24", X"D2D", X"D35", X"D3E", X"D46", X"D4F", X"D57", X"D60", 
X"D69", X"D72", X"D7A", X"D83", X"D8B", X"D94", X"D9D", X"DA5", 
X"DAE", X"DB7", X"DBF", X"DC7", X"DD0", X"DD9", X"DE2", X"DEA", 
X"DF3", X"DFC", X"E04", X"E0C", X"E15", X"E1E", X"E27", X"E30", 
X"E38", X"E41", X"E49", X"E52", X"E5A", X"E63", X"E6C", X"E75", 
X"E7D", X"E86", X"E8E", X"E97", X"EA0", X"EA8", X"EB1", X"EBA", 
X"EC3", X"ECB", X"ED3", X"EDC", X"EE5", X"EED", X"EF6", X"EFF", 
X"F08", X"F10", X"F18", X"F21", X"F2A", X"F33", X"F3B", X"F44", 
X"F4D", X"F55", X"F5D", X"F66", X"F6F", X"F78", X"F80", X"F89", 
X"F91", X"F9A", X"FA3", X"FAB", X"FB4", X"FBD", X"FC6", X"FCE", 
X"FD6", X"FDF", X"FE8", X"FF0", X"FF9", X"002", X"00B", X"013", 
X"01B", X"024", X"02D", X"036", X"03E", X"047", X"050", X"058", 
X"060", X"069", X"072", X"9C3", X"9CB", X"9D4", X"9DD", X"9E6", 
X"9EF", X"9F7", X"A00", X"A08", X"A11", X"A19", X"A22", X"A2B", 
X"A34", X"A3C", X"A45", X"A4D", X"A56", X"A5E", X"A67", X"A70", 
X"A79", X"A82", X"A8A", X"A92", X"A9B", X"AA4", X"AAC", X"AB5", 
X"ABE", X"AC6", X"ACF", X"AD7", X"AE0", X"AE9", X"AF2", X"AFA", 
X"B03", X"B0B", X"B14", X"B1C", X"B25", X"B2E", X"B37", X"B3F", 
X"B48", X"B50", X"B59", X"B61", X"B6A", X"B73", X"B7C", X"B85", 
X"B8D", X"B95", X"B9E", X"BA7", X"BAF", X"BB8", X"BC1", X"BCA", 
X"BD2", X"BDA", X"BE3", X"BEC", X"BF5", X"BFD", X"C06", X"C0F", 
X"C17", X"C1F", X"C28", X"C31", X"C3A", X"C42", X"C4B", X"C54", 
X"C5C", X"C64", X"C6D", X"C76", X"C7F", X"C88", X"C90", X"C98", 
X"CA1", X"CAA", X"CB2", X"CBB", X"CC4", X"CCD", X"CD5", X"CDD", 
X"CE6", X"CEF", X"CF8", X"D00", X"D09", X"D12", X"D1A", X"D22", 
X"D2B", X"D34", X"D3D", X"D45", X"D4E", X"D57", X"D5F", X"D67", 
X"D70", X"D79", X"D82", X"D8B", X"D93", X"D9C", X"DA4", X"DAD", 
X"DB5", X"DBE", X"DC7", X"DD0", X"DD8", X"DE1", X"DE9", X"DF2", 
X"DFB", X"E03", X"E0C", X"E15", X"E1E", X"E26", X"E2E", X"E37", 
X"E40", X"E48", X"E51", X"E5A", X"E62", X"E6B", X"E73", X"E7C", 
X"E85", X"E8E", X"E96", X"E9F", X"EA7", X"EB0", X"EB8", X"EC1", 
X"ECA", X"ED3", X"EDB", X"EE4", X"EEC", X"EF5", X"EFE", X"F06", 
X"F0F", X"F18", X"F21", X"F29", X"F31", X"F3A", X"F43", X"F4B", 
X"F54", X"F5D", X"F66", X"F6E", X"F76", X"F7F", X"F88", X"F91", 
X"F99", X"FA2", X"FAB", X"FB3", X"FBB", X"FC4", X"FCD", X"FD6", 
X"FDE", X"FE7", X"FF0", X"FF8", X"001", X"009", X"012", X"01B", 
X"024", X"02C", X"035", X"03D", X"046", X"04E", X"C57", X"C60", 
X"C69", X"C71", X"C7A", X"C83", X"C8C", X"C94", X"C9C", X"CA5", 
X"CAE", X"CB7", X"CBF", X"CC8", X"CD1", X"CD9", X"CE1", X"CEA", 
X"CF3", X"CFC", X"D05", X"D0D", X"D16", X"D1E", X"D27", X"D2F", 
X"D38", X"D41", X"D4A", X"D52", X"D5B", X"D63", X"D6C", X"D74", 
X"D7D", X"D86", X"D8F", X"D98", X"DA0", X"DA8", X"DB1", X"DBA", 
X"DC2", X"DCB", X"DD4", X"DDD", X"DE5", X"DED", X"DF6", X"DFF", 
X"E08", X"E10", X"E19", X"E21", X"E2A", X"E32", X"E3B", X"E44", 
X"E4D", X"E55", X"E5E", X"E66", X"E6F", X"E77", X"E80", X"E89", 
X"E92", X"E9B", X"EA3", X"EAB", X"EB4", X"EBD", X"EC5", X"ECE", 
X"ED7", X"EE0", X"EE8", X"EF0", X"EF9", X"F02", X"F0B", X"F13", 
X"F1C", X"F25", X"F2D", X"F35", X"F3E", X"F47", X"F50", X"F58", 
X"F61", X"F6A", X"F72", X"F7A", X"F83", X"F8C", X"F95", X"F9E", 
X"FA6", X"FAF", X"FB7", X"FC0", X"FC8", X"FD1", X"FDA", X"FE3", 
X"FEB", X"FF4", X"FFC", X"005", X"00E", X"016", X"01F", X"028", 
X"030", X"038", X"041", X"04A", X"053", X"05B", X"064", X"06D", 
X"075", X"07D", X"086", X"08F", X"098", X"0A1", X"0A9", X"0B2", 
X"0BA", X"0C3", X"0CB", X"0D4", X"0DD", X"0E6", X"0EE", X"0F7", 
X"0FF", X"108", X"111", X"119", X"122", X"12B", X"134", X"13C", 
X"144", X"14D", X"156", X"15E", X"167", X"170", X"179", X"181", 
X"189", X"192", X"19B", X"1A4", X"1AC", X"1B5", X"1BD", X"1C6", 
X"1CE", X"1D7", X"1E0", X"1E9", X"1F1", X"1FA", X"202", X"20B", 
X"214", X"21C", X"225", X"22E", X"237", X"23F", X"247", X"250", 
X"259", X"261", X"26A", X"273", X"27C", X"284", X"28C", X"295", 
X"29E", X"2A7", X"2AF", X"2B8", X"2C1", X"2C9", X"2D1", X"2DA", 
X"2E3", X"2EC", X"2F4", X"2FD", X"306", X"30E", X"316", X"31F", 
X"328", X"331", X"33A", X"342", X"34B", X"353", X"35C", X"364", 
X"36D", X"376", X"37F", X"387", X"390", X"398", X"3A1", X"3AA", 
X"3B2", X"3BB", X"3C4", X"3CC", X"3D4", X"3DD", X"3E6", X"3EF", 
X"3F7", X"400", X"409", X"411", X"419", X"422", X"42B", X"434", 
X"43D", X"445", X"44E", X"456", X"45F", X"467", X"470", X"479", 
X"482", X"48A", X"493", X"49B", X"4A4", X"4AD", X"4B5", X"4BE", 
X"4C7", X"4D0", X"4D8", X"4E0", X"4E9", X"4F2", X"4FA", X"503", 
X"50C", X"515", X"51D", X"525", X"52E", X"537", X"540", X"548", 
X"551", X"55A", X"562", X"56A", X"573", X"57C", X"585", X"8EB", 
X"8F3", X"8FC", X"905", X"90E", X"916", X"91F", X"928", X"930", 
X"938", X"941", X"94A", X"953", X"95B", X"964", X"96D", X"975", 
X"97D", X"986", X"98F", X"998", X"9A1", X"9A9", X"9B1", X"9BA", 
X"9C3", X"9CB", X"9D4", X"9DD", X"9E6", X"9EE", X"9F6", X"9FF", 
X"A08", X"A11", X"A19", X"A22", X"A2B", X"A33", X"A3B", X"A44", 
X"A4D", X"A56", X"A5E", X"A67", X"A70", X"A78", X"A80", X"A89", 
X"A92", X"A9B", X"AA4", X"AAC", X"AB5", X"ABD", X"AC6", X"ACE", 
X"AD7", X"AE0", X"AE9", X"AF1", X"AFA", X"B02", X"B0B", X"B14", 
X"B1C", X"B25", X"B2E", X"B37", X"B3F", X"B47", X"B50", X"B59", 
X"B61", X"B6A", X"B73", X"B7B", X"B84", X"B8C", X"B95", X"B9E", 
X"BA7", X"BAF", X"BB8", X"BC0", X"BC9", X"BD1", X"BDA", X"BE3", 
X"BEC", X"BF4", X"BFD", X"C05", X"C0E", X"C17", X"C1F", X"C28", 
X"C31", X"C3A", X"C42", X"C4A", X"C53", X"C5C", X"C64", X"C6D", 
X"C76", X"C7F", X"C87", X"C8F", X"C98", X"CA1", X"CAA", X"CB2", 
X"CBB", X"CC4", X"CCC", X"CD4", X"626", X"62F", X"637", X"63F", 
X"648", X"651", X"65A", X"663", X"66B", X"674", X"67C", X"685", 
X"68D", X"696", X"69F", X"6A8", X"6B0", X"6B9", X"6C1", X"6CA", 
X"6D2", X"6DB", X"6E4", X"6ED", X"6F5", X"6FD", X"706", X"70F", 
X"718", X"720", X"729", X"732", X"73A", X"742", X"74B", X"754", 
X"75D", X"766", X"76E", X"777", X"77F", X"788", X"790", X"799", 
X"7A2", X"7AB", X"7B3", X"7BC", X"7C4", X"7CD", X"7D5", X"7DE", 
X"7E7", X"7F0", X"7F9", X"801", X"809", X"812", X"81B", X"823", 
X"82C", X"835", X"83E", X"846", X"84E", X"857", X"860", X"869", 
X"871", X"87A", X"883", X"88B", X"893", X"89C", X"8A5", X"8AE", 
X"8B6", X"8BF", X"8C7", X"8D0", X"8D8", X"8E1", X"8EA", X"8F3", 
X"8FC", X"904", X"90C", X"915", X"91E", X"926", X"92F", X"938", 
X"941", X"949", X"951", X"95A", X"963", X"96C", X"974", X"97D", 
X"986", X"98E", X"996", X"99F", X"9A8", X"9B1", X"9B9", X"9C2", 
X"9CB", X"9D3", X"9DB", X"9E4", X"9ED", X"9F6", X"9FF", X"A07", 
X"A10", X"A18", X"A21", X"A29", X"A32", X"A3B", X"A44", X"A4C", 
X"A55", X"A5D", X"A66", X"A6F", X"A77", X"A80", X"A89", X"A91", 
X"A99", X"AA2", X"AAB", X"AB4", X"ABC", X"AC5", X"ACE", X"AD6", 
X"ADE", X"AE7", X"AF0", X"AF9", X"B02", X"B0A", X"B13", X"B1B", 
X"B24", X"B2C", X"B35", X"B3E", X"B47", X"B4F", X"B58", X"B60", 
X"B69", X"B72", X"B7A", X"B83", X"B8C", X"B95", X"B9D", X"BA5", 
X"BAE", X"BB7", X"BBF", X"BC8", X"BD1", X"BDA", X"BE2", X"BEA", 
X"BF3", X"BFC", X"C05", X"C0D", X"C16", X"C1F", X"C27", X"C2F", 
X"C38", X"C41", X"C4A", X"C52", X"C5B", X"C63", X"C6C", X"C75", 
X"C7D", X"C86", X"C8F", X"C98", X"CA0", X"CA8", X"CB1", X"CBA", 
X"CC2", X"CCB", X"CD4", X"CDD", X"CE5", X"CED", X"CF6", X"CFF", 
X"D08", X"D10", X"D19", X"D22", X"D2A", X"D32", X"D3B", X"D44", 
X"D4D", X"D55", X"D5E", X"D67", X"D6F", X"D78", X"D80", X"D89", 
X"D92", X"D9B", X"DA3", X"DAC", X"DB4", X"DBD", X"DC5", X"DCE", 
X"DD7", X"DE0", X"DE8", X"DF1", X"DF9", X"E02", X"E0B", X"E13", 
X"E1C", X"E25", X"E2D", X"E36", X"E3E", X"E47", X"E50", X"E58", 
X"E61", X"E6A", X"E72", X"E7B", X"E83", X"E8C", X"E95", X"E9E", 
X"EA6", X"EAF", X"EB7", X"EC0", X"EC8", X"ED1", X"EDA", X"EE3", 
X"EEB", X"EF4", X"EFC", X"F05", X"F0E", X"F16", X"F1F", X"F28", 
X"F31", X"F39", X"F41", X"F4A", X"F53", X"F5B", X"F64", X"F6D", 
X"F76", X"F7E", X"F86", X"F8F", X"F98", X"FA1", X"FA9", X"FB2", 
X"FBB", X"FC3", X"FCB", X"FD4", X"FDD", X"FE6", X"FEE", X"FF7", 
X"000", X"008", X"011", X"019", X"022", X"02B", X"034", X"03C", 
X"044", X"04D", X"056", X"05E", X"067", X"070", X"079", X"081", 
X"089", X"092", X"09B", X"0A4", X"0AC", X"0B5", X"0BE", X"0C6", 
X"0CE", X"0D7", X"0E0", X"0E9", X"0F1", X"0FA", X"103", X"10B", 
X"114", X"11C", X"125", X"12E", X"137", X"13F", X"148", X"150", 
X"159", X"161", X"16A", X"173", X"17C", X"184", X"18D", X"195", 
X"19E", X"1A7", X"1AF", X"1B8", X"1C1", X"1C9", X"1D2", X"1DA", 
X"1E3", X"1EC", X"1F4", X"1FD", X"206", X"20E", X"217", X"21F", 
X"228", X"231", X"23A", X"242", X"24B", X"253", X"25C", X"264", 
X"26D", X"276", X"27F", X"287", X"290", X"298", X"2A1", X"2AA", 
X"2B2", X"2BB", X"2C4", X"2CD", X"2D5", X"2DD", X"2E6", X"2EF", 
X"2F7", X"300", X"309", X"312", X"31A", X"322", X"32B", X"334", 
X"33D", X"345", X"34E", X"357", X"35F", X"367", X"370", X"379", 
X"382", X"38A", X"393", X"39C", X"3A4", X"3AD", X"3B5", X"3BE", 
X"3C7", X"3D0", X"3D8", X"3E0", X"3E9", X"3F2", X"3FA", X"403", 
X"40C", X"415", X"41D", X"425", X"42E", X"437", X"440", X"448", 
X"451", X"45A", X"462", X"46A", X"473", X"47C", X"485", X"48D", 
X"496", X"49F", X"4A7", X"4B0", X"4B8", X"4C1", X"4CA", X"4D3", 
X"4DB", X"4E4", X"4EC", X"4F5", X"4FD", X"506", X"50F", X"518", 
X"521", X"529", X"531", X"53A", X"543", X"54B", X"554", X"55D", 
X"566", X"56E", X"576", X"57F", X"588", X"590", X"599", X"5A2", 
X"5AA", X"5B3", X"5BB", X"5C4", X"5CD", X"5D6", X"5DE", X"5E7", 
X"5EF", X"5F8", X"600", X"609", X"612", X"61B", X"624", X"62C", 
X"634", X"63D", X"646", X"64E", X"657", X"660", X"669", X"671", 
X"679", X"682", X"68B", X"693", X"69C", X"6A5", X"6AE", X"6B6", 
X"6BE", X"6C7", X"6D0", X"6D9", X"6E1", X"6EA", X"6F3", X"6FB", 
X"703", X"70C", X"715", X"71E", X"727", X"72F", X"738", X"740", 
X"749", X"751", X"75A", X"763", X"76C", X"774", X"77C", X"785", 
X"78E", X"796", X"79F", X"7A8", X"7B1", X"7B9", X"7C1", X"7CA", 
X"7D3", X"7DC", X"7E4", X"7ED", X"7F6", X"7FE", X"806", X"80F", 
X"818", X"821", X"82A", X"832", X"83B", X"843", X"84C", X"854", 
X"85D", X"866", X"86F", X"877", X"880", X"888", X"891", X"899", 
X"8A2", X"8AB", X"8B4", X"8BD", X"8C5", X"8CD", X"8D6", X"8DF", 
X"8E7", X"8F0", X"8F9", X"902", X"90A", X"912", X"91B", X"924", 
X"92D", X"935", X"93E", X"946", X"94F", X"957", X"960", X"969", 
X"972", X"97A", X"983", X"98B", X"994", X"99C", X"9A5", X"9AE", 
X"9B7", X"9C0", X"9C8", X"9D0", X"9D9", X"32B", X"333", X"33B", 
X"344", X"34D", X"355", X"35E", X"367", X"370", X"378", X"380", 
X"389", X"392", X"39B", X"3A3", X"3AC", X"3B5", X"3BD", X"3C5", 
X"3CE", X"3D7", X"3E0", X"3E8", X"3F1", X"3FA", X"402", X"40B", 
X"413", X"41C", X"425", X"42E", X"436", X"43F", X"447", X"450", 
X"458", X"461", X"46A", X"473", X"47B", X"484", X"48C", X"495", 
X"49E", X"4A6", X"4AF", X"4B8", X"4C0", X"4C8", X"4D1", X"4DA", 
X"4E3", X"4EB", X"4F4", X"4FD", X"505", X"50E", X"516", X"51F", 
X"528", X"531", X"539", X"542", X"54A", X"553", X"55B", X"564", 
X"56D", X"576", X"57F", X"587", X"58F", X"598", X"5A1", X"5A9", 
X"5B2", X"5BB", X"5C4", X"5CC", X"5D4", X"5DD", X"5E6", X"5EE", 
X"5F7", X"600", X"609", X"611", X"619", X"622", X"62B", X"634", 
X"63C", X"645", X"64E", X"656", X"65E", X"667", X"670", X"679", 
X"682", X"68A", X"692", X"69B", X"6A4", X"6AC", X"6B5", X"6BE", 
X"6C7", X"6CF", X"6D7", X"6E0", X"6E9", X"6F1", X"6FA", X"703", 
X"70C", X"714", X"A7A", X"A83", X"A8C", X"A95", X"A9D", X"AA5", 
X"AAE", X"AB7", X"ABF", X"AC8", X"AD1", X"ADA", X"AE2", X"AEA", 
X"AF3", X"AFC", X"B05", X"B0D", X"B16", X"B1F", X"B27", X"B2F", 
X"B38", X"B41", X"B4A", X"B52", X"B5B", X"B64", X"B6C", X"B75", 
X"B7D", X"B86", X"B8F", X"B98", X"BA0", X"BA9", X"BB1", X"BBA", 
X"BC2", X"BCB", X"BD4", X"BDD", X"BE6", X"BEE", X"BF6", X"BFF", 
X"C08", X"C10", X"C19", X"C22", X"C2B", X"C33", X"C3B", X"C44", 
X"C4D", X"C55", X"C5E", X"C67", X"C6F", X"C78", X"C80", X"C89", 
X"C92", X"C9B", X"CA3", X"CAC", X"CB4", X"CBD", X"CC5", X"CCE", 
X"CD7", X"CE0", X"CE9", X"CF1", X"CF9", X"D02", X"D0B", X"D13", 
X"D1C", X"D25", X"D2E", X"D36", X"D3E", X"D47", X"D50", X"D58", 
X"D61", X"D6A", X"D73", X"D7B", X"D83", X"D8C", X"D95", X"D9E", 
X"DA6", X"DAF", X"DB8", X"DC0", X"DC8", X"DD1", X"DDA", X"DE3", 
X"DEC", X"DF4", X"DFD", X"E05", X"E0E", X"E16", X"E1F", X"E28", 
X"E31", X"E39", X"E42", X"E4A", X"E53", X"E5B", X"E64", X"E6D", 
X"E76", X"E7E", X"E86", X"E8F", X"E98", X"EA1", X"EA9", X"EB2", 
X"EBB", X"EC3", X"ECB", X"ED4", X"EDD", X"EE6", X"EEE", X"EF7", 
X"F00", X"F08", X"F11", X"F19", X"F22", X"F2B", X"F34", X"F3C", 
X"F45", X"F4D", X"F56", X"F5E", X"F67", X"F70", X"F79", X"F82", 
X"F8A", X"F92", X"F9B", X"FA4", X"FAC", X"FB5", X"FBE", X"FC7", 
X"FCF", X"FD7", X"FE0", X"FE9", X"FF1", X"FFA", X"003", X"00B", 
X"014", X"01C", X"025", X"02E", X"037", X"03F", X"048", X"050", 
X"059", X"061", X"06A", X"073", X"07C", X"085", X"08D", X"095", 
X"09E", X"0A7", X"0AF", X"0B8", X"0C1", X"0CA", X"0D2", X"0DA", 
X"0E3", X"0EC", X"0F4", X"0FD", X"106", X"10F", X"117", X"11F", 
X"128", X"131", X"13A", X"142", X"14B", X"154", X"15C", X"164", 
X"16D", X"176", X"17F", X"188", X"190", X"199", X"1A1", X"1AA", 
X"1B2", X"1BB", X"1C4", X"1CD", X"1D5", X"1DE", X"1E6", X"1EF", 
X"1F7", X"200", X"209", X"212", X"21A", X"222", X"22B", X"234", 
X"23D", X"245", X"24E", X"257", X"25F", X"267", X"270", X"279", 
X"282", X"28B", X"293", X"29C", X"2A4", X"2AD", X"2B5", X"2BE", 
X"2C7", X"2D0", X"2D8", X"2E1", X"2E9", X"2F2", X"2FA", X"303", 
X"30C", X"315", X"31E", X"326", X"32E", X"337", X"340", X"348", 
X"351", X"35A", X"363", X"36B", X"373", X"37C", X"385", X"38E", 
X"396", X"39F", X"3A8", X"FB1", X"FB9", X"FC2", X"FCA", X"FD3", 
X"FDB", X"FE4", X"FED", X"FF6", X"FFE", X"007", X"00F", X"018", 
X"021", X"029", X"032", X"03B", X"044", X"04C", X"054", X"05D", 
X"066", X"06E", X"077", X"080", X"089", X"091", X"099", X"0A2", 
X"0AB", X"0B4", X"0BC", X"0C5", X"0CE", X"0D6", X"0DE", X"0E7", 
X"0F0", X"0F9", X"101", X"10A", X"113", X"11B", X"124", X"12C", 
X"135", X"13E", X"147", X"14F", X"158", X"160", X"169", X"171", 
X"17A", X"183", X"18C", X"194", X"19D", X"1A5", X"1AE", X"1B7", 
X"1BF", X"1C8", X"1D1", X"1D9", X"1E1", X"1EA", X"1F3", X"1FC", 
X"204", X"20D", X"216", X"21E", X"227", X"22F", X"238", X"241", 
X"24A", X"252", X"25B", X"263", X"26C", X"274", X"27D", X"286", 
X"28F", X"298", X"2A0", X"2A8", X"2B1", X"2BA", X"2C2", X"2CB", 
X"2D4", X"2DD", X"2E5", X"2ED", X"2F6", X"2FF", X"307", X"310", 
X"319", X"322", X"32A", X"332", X"33B", X"344", X"34D", X"355", 
X"35E", X"367", X"36F", X"377", X"380", X"389", X"392", X"39B", 
X"3A3", X"3AB", X"3B4", X"3BD", X"3C5", X"3CE", X"3D7", X"3E0", 
X"3E8", X"3F0", X"3F9", X"402", X"40A", X"413", X"41C", X"425", 
X"42D", X"435", X"43E", X"447", X"450", X"458", X"461", X"46A", 
X"472", X"47A", X"483", X"48C", X"495", X"49E", X"4A6", X"4AF", 
X"4B7", X"4C0", X"4C8", X"4D1", X"4DA", X"4E3", X"4EB", X"4F4", 
X"4FC", X"505", X"50D", X"516", X"51F", X"528", X"530", X"539", 
X"541", X"54A", X"553", X"55B", X"564", X"56D", X"575", X"57D", 
X"586", X"58F", X"598", X"5A1", X"5A9", X"5B2", X"5BA", X"5C3", 
X"5CB", X"5D4", X"5DD", X"5E6", X"5EE", X"5F7", X"5FF", X"608", 
X"610", X"619", X"622", X"62B", X"634", X"63C", X"F8D", X"F96", 
X"F9F", X"FA7", X"FAF", X"FB8", X"FC1", X"FC9", X"FD2", X"FDB", 
X"FE4", X"FEC", X"FF4", X"FFD", X"006", X"00F", X"017", X"020", 
X"029", X"031", X"039", X"042", X"04B", X"054", X"05C", X"065", 
X"06E", X"076", X"07F", X"087", X"090", X"099", X"0A2", X"0AA", 
X"0B2", X"0BB", X"0C4", X"0CC", X"0D5", X"0DE", X"0E7", X"0EF", 
X"0F7", X"100", X"109", X"112", X"11A", X"123", X"12C", X"134", 
X"13C", X"145", X"14E", X"157", X"15F", X"168", X"171", X"179", 
X"182", X"18A", X"193", X"19C", X"1A5", X"1AD", X"1B6", X"1BE", 
X"1C7", X"1CF", X"1D8", X"1E1", X"1EA", X"1F3", X"1FB", X"203", 
X"20C", X"215", X"21D", X"226", X"22F", X"238", X"240", X"248", 
X"251", X"25A", X"262", X"26B", X"274", X"27C", X"285", X"28D", 
X"296", X"29F", X"2A8", X"2B0", X"2B9", X"2C1", X"2CA", X"2D2", 
X"2DB", X"2E4", X"2ED", X"2F6", X"2FE", X"306", X"30F", X"318", 
X"320", X"329", X"332", X"33B", X"343", X"34B", X"354", X"35D", 
X"365", X"36E", X"377", X"380", X"388", X"390", X"399", X"3A2", 
X"3AB", X"3B3", X"3BC", X"3C5", X"3CD", X"3D5", X"3DE", X"3E7", 
X"3F0", X"3F9", X"401", X"40A", X"412", X"41B", X"423", X"42C", 
X"435", X"43E", X"446", X"44F", X"457", X"460", X"468", X"471", 
X"47A", X"483", X"48B", X"493", X"49C", X"4A5", X"4AE", X"4B6", 
X"4BF", X"4C8", X"4D0", X"4D8", X"4E1", X"4EA", X"4F3", X"4FB", 
X"504", X"50D", X"515", X"51E", X"526", X"52F", X"538", X"541", 
X"549", X"552", X"55A", X"563", X"56B", X"574", X"57D", X"586", 
X"58F", X"597", X"59F", X"5A8", X"5B1", X"5B9", X"5C2", X"5CB", 
X"5D4", X"5DC", X"5E4", X"5ED", X"5F6", X"5FE", X"607", X"610", 
X"619", X"621", X"629", X"632", X"63B", X"644", X"64C", X"655", 
X"65D", X"666", X"66E", X"677", X"680", X"689", X"692", X"69A", 
X"6A2", X"6AB", X"6B4", X"6BC", X"6C5", X"6CE", X"6D7", X"6DF", 
X"6E7", X"6F0", X"6F9", X"701", X"70A", X"713", X"71C", X"724", 
X"72C", X"735", X"73E", X"747", X"74F", X"758", X"761", X"769", 
X"771", X"77A", X"783", X"78C", X"795", X"79D", X"7A6", X"7AE", 
X"7B7", X"7BF", X"7C8", X"7D1", X"7DA", X"7E2", X"7EB", X"7F3", 
X"7FC", X"804", X"80D", X"816", X"81F", X"827", X"82F", X"838", 
X"841", X"84A", X"852", X"85B", X"864", X"86C", X"874", X"87D", 
X"886", X"88F", X"898", X"8A0", X"8A9", X"8B1", X"8BA", X"8C2", 
X"8CB", X"8D4", X"8DD", X"8E5", X"8EE", X"8F6", X"8FF", X"907", 
X"910", X"919", X"922", X"92B", X"933", X"93B", X"944", X"94D", 
X"955", X"95E", X"967", X"970", X"978", X"980", X"989", X"992", 
X"99B", X"9A3", X"9AC", X"9B5", X"9BD", X"9C5", X"9CE", X"9D7", 
X"9E0", X"9E8", X"9F1", X"9F9", X"A02", X"A0A", X"A13", X"A1C", 
X"A25", X"A2E", X"A36", X"A3E", X"A47", X"A50", X"A58", X"A61", 
X"A6A", X"A73", X"A7B", X"A83", X"A8C", X"A95", X"A9E", X"AA6", 
X"AAF", X"AB8", X"AC0", X"AC8", X"AD1", X"ADA", X"AE3", X"AEB", 
X"AF4", X"AFD", X"B05", X"B0D", X"B16", X"B1F", X"B28", X"B31", 
X"B39", X"B42", X"B4A", X"B53", X"B5B", X"EC2", X"ECB", X"ED3", 
X"EDB", X"EE4", X"EED", X"EF6", X"EFF", X"F07", X"F10", X"F18", 
X"F21", X"F29", X"F32", X"F3B", X"F44", X"F4C", X"F55", X"F5D", 
X"F66", X"F6E", X"F77", X"F80", X"F89", X"F92", X"F9A", X"FA2", 
X"FAB", X"FB4", X"FBC", X"FC5", X"FCE", X"FD6", X"FDF", X"FE7", 
X"FF0", X"FF9", X"002", X"00A", X"013", X"01B", X"024", X"02C", 
X"035", X"03E", X"047", X"04F", X"058", X"060", X"069", X"071", 
X"07A", X"083", X"08C", X"095", X"09D", X"0A5", X"0AE", X"0B7", 
X"0BF", X"0C8", X"0D1", X"0DA", X"0E2", X"0EA", X"0F3", X"0FC", 
X"105", X"10D", X"116", X"11F", X"127", X"12F", X"138", X"141", 
X"14A", X"152", X"15B", X"164", X"16C", X"174", X"17D", X"186", 
X"18F", X"198", X"1A0", X"1A9", X"1B1", X"1BA", X"1C2", X"1CB", 
X"1D4", X"1DD", X"1E5", X"1ED", X"1F6", X"1FF", X"208", X"210", 
X"219", X"222", X"22A", X"232", X"23B", X"244", X"24D", X"255", 
X"25E", X"267", X"26F", X"277", X"280", X"289", X"292", X"29B", 
X"2A3", X"2AC", X"2B4", X"2BD", X"2C5", X"2CE", X"2D7", X"2E0", 
X"2E8", X"2F1", X"2F9", X"302", X"30B", X"313", X"31C", X"325", 
X"32E", X"336", X"33E", X"347", X"350", X"358", X"361", X"36A", 
X"373", X"37B", X"383", X"38C", X"395", X"39E", X"3A6", X"3AF", 
X"3B7", X"3C0", X"3C8", X"3D1", X"3DA", X"3E3", X"3EB", X"3F4", 
X"3FC", X"405", X"40E", X"416", X"41F", X"428", X"431", X"439", 
X"441", X"44A", X"453", X"45B", X"464", X"46D", X"476", X"47E", 
X"486", X"48F", X"498", X"4A1", X"4A9", X"4B2", X"4BB", X"4C3", 
X"4CB", X"4D4", X"4DD", X"4E6", X"4EE", X"4F7", X"500", X"508", 
X"511", X"519", X"522", X"52B", X"534", X"53C", X"545", X"54D", 
X"556", X"55E", X"567", X"570", X"579", X"581", X"589", X"592", 
X"59B", X"5A4", X"5AC", X"5B5", X"5BE", X"5C6", X"5CE", X"5D7", 
X"5E0", X"5E9", X"5F1", X"5FA", X"603", X"60B", X"614", X"61C", 
X"625", X"62E", X"637", X"63F", X"648", X"650", X"659", X"661", 
X"66A", X"673", X"67C", X"684", X"68D", X"695", X"69E", X"FF0", 
X"FF8", X"000", X"009", X"012", X"01A", X"023", X"02C", X"035", 
X"03D", X"045", X"04E", X"057", X"060", X"068", X"071", X"07A", 
X"082", X"08A", X"093", X"09C", X"0A5", X"0AD", X"0B6", X"0BE", 
X"0C7", X"0CF", X"0D8", X"0E1", X"0EA", X"0F3", X"0FB", X"103", 
X"10C", X"115", X"11D", X"126", X"12F", X"138", X"140", X"148", 
X"151", X"15A", X"163", X"16B", X"174", X"17D", X"185", X"18D", 
X"196", X"19F", X"1A8", X"1B0", X"1B9", X"1C2", X"1CA", X"1D2", 
X"1DB", X"1E4", X"1ED", X"1F6", X"1FE", X"207", X"20F", X"218", 
X"220", X"229", X"232", X"23B", X"243", X"24C", X"254", X"25D", 
X"266", X"26E", X"277", X"280", X"288", X"291", X"299", X"2A2", 
X"2AB", X"2B3", X"2BC", X"2C5", X"2CD", X"2D5", X"2DE", X"2E7", 
X"2F0", X"2F9", X"301", X"30A", X"312", X"31B", X"323", X"32C", 
X"335", X"33E", X"346", X"34F", X"357", X"360", X"368", X"371", 
X"37A", X"383", X"38C", X"394", X"39C", X"3A5", X"3AE", X"3B6", 
X"3BF", X"3C8", X"3D1", X"3D9", X"3E1", X"3EA", X"3F3", X"3FC", 
X"404", X"40D", X"416", X"41E", X"426", X"42F", X"438", X"441", 
X"449", X"452", X"45B", X"463", X"46B", X"474", X"47D", X"486", 
X"48F", X"497", X"49F", X"4A8", X"4B1", X"4B9", X"4C2", X"4CB", 
X"4D4", X"4DC", X"4E4", X"4ED", X"4F6", X"4FF", X"507", X"510", 
X"519", X"521", X"529", X"532", X"53B", X"544", X"54C", X"555", 
X"55E", X"566", X"56E", X"577", X"580", X"589", X"592", X"59A", 
X"5A3", X"5AB", X"5B4", X"5BC", X"5C5", X"5CE", X"5D7", X"5DF", 
X"5E8", X"5F0", X"5F9", X"602", X"60A", X"613", X"61C", X"624", 
X"62D", X"635", X"63E", X"647", X"64F", X"658", X"661", X"669", 
X"671", X"67A", X"683", X"68C", X"695", X"69D", X"6A6", X"6AE", 
X"6B7", X"6BF", X"6C8", X"6D1", X"6DA", X"6E2", X"6EB", X"6F3", 
X"6FC", X"705", X"70D", X"716", X"71F", X"728", X"730", X"738", 
X"741", X"74A", X"752", X"75B", X"764", X"76D", X"775", X"77D", 
X"786", X"78F", X"798", X"7A0", X"7A9", X"7B2", X"7BA", X"7C2", 
X"7CB", X"7D4", X"7DD", X"7E5", X"7EE", X"7F7", X"7FF", X"808", 
X"810", X"819", X"822", X"82B", X"833", X"83B", X"844", X"84D", 
X"855", X"85E", X"867", X"870", X"878", X"880", X"889", X"892", 
X"89B", X"8A3", X"8AC", X"8B5", X"8BD", X"8C5", X"8CE", X"8D7", 
X"8E0", X"8E8", X"8F1", X"8FA", X"902", X"90B", X"913", X"91C", 
X"925", X"92E", X"936", X"93F", X"947", X"950", X"958", X"961", 
X"96A", X"973", X"97B", X"984", X"98C", X"995", X"99E", X"9A6", 
X"9AF", X"9B8", X"9C1", X"9C9", X"9D1", X"9DA", X"9E3", X"9EB", 
X"9F4", X"9FD", X"A05", X"A0E", X"A16", X"A1F", X"A28", X"A31", 
X"A39", X"A42", X"A4A", X"A53", X"A5B", X"A64", X"A6D", X"A76", 
X"A7E", X"A87", X"A8F", X"A98", X"AA1", X"AA9", X"AB2", X"ABB", 
X"AC4", X"ACC", X"AD4", X"ADD", X"AE6", X"AEE", X"AF7", X"B00", 
X"B09", X"B11", X"B19", X"B22", X"B2B", X"B34", X"B3C", X"B45", 
X"B4E", X"B56", X"B5E", X"B67", X"B70", X"B79", X"B81", X"B8A", 
X"B93", X"B9B", X"BA4", X"BAC", X"BB5", X"BBE", X"BC7", X"BCF", 
X"BD7", X"BE0", X"BE9", X"BF1", X"BFA", X"C03", X"C0C", X"C14", 
X"C1C", X"C25", X"C2E", X"C37", X"C3F", X"C48", X"C51", X"C59", 
X"C61", X"C6A", X"C73", X"C7C", X"C84", X"C8D", X"C96", X"C9E", 
X"CA7", X"CAF", X"CB8", X"CC1", X"CCA", X"CD2", X"CDB", X"CE3", 
X"CEC", X"CF4", X"CFD", X"D06", X"D0F", X"D18", X"D20", X"D28", 
X"D31", X"D3A", X"D42", X"D4B", X"D54", X"D5D", X"D65", X"D6D", 
X"D76", X"D7F", X"D87", X"D90", X"D99", X"DA1", X"DAA", X"DB2", 
X"DBB", X"DC4", X"DCD", X"DD5", X"DDE", X"DE6", X"DEF", X"DF7", 
X"E00", X"E09", X"E12", X"E1B", X"E23", X"E2B", X"E34", X"E3D", 
X"E45", X"E4E", X"E57", X"E60", X"E68", X"E70", X"E79", X"E82", 
X"E8A", X"E93", X"E9C", X"EA5", X"EAD", X"EB5", X"EBE", X"EC7", 
X"ED0", X"ED8", X"EE1", X"EEA", X"EF2", X"EFA", X"F03", X"F0C", 
X"F15", X"F1E", X"F26", X"F2F", X"F37", X"F40", X"F48", X"F51", 
X"F5A", X"F63", X"F6B", X"F74", X"F7C", X"F85", X"F8D", X"F96", 
X"F9F", X"FA8", X"FB0", X"FB8", X"FC1", X"FCA", X"FD3", X"FDB", 
X"FE4", X"FED", X"FF5", X"FFD", X"006", X"00F", X"018", X"021", 
X"029", X"032", X"03A", X"043", X"04B", X"054", X"05D", X"066", 
X"06E", X"077", X"07F", X"088", X"090", X"099", X"0A2", X"0AB", 
X"0B4", X"0BC", X"0C4", X"0CD", X"0D6", X"0DE", X"0E7", X"0F0", 
X"0F9", X"101", X"109", X"112", X"11B", X"124", X"12C", X"135", 
X"13E", X"146", X"14E", X"157", X"160", X"169", X"171", X"17A", 
X"182", X"18B", X"193", X"19C", X"1A5", X"1AE", X"1B7", X"1BF", 
X"1C7", X"1D0", X"1D9", X"1E1", X"1EA", X"1F3", X"1FC", X"204", 
X"20C", X"215", X"21E", X"227", X"22F", X"238", X"241", X"249", 
X"251", X"25A", X"263", X"26C", X"274", X"27D", X"286", X"28E", 
X"296", X"29F", X"2A8", X"2B1", X"2BA", X"2C2", X"2CB", X"2D3", 
X"2DC", X"2E4", X"2ED", X"2F6", X"2FF", X"307", X"310", X"318", 
X"321", X"32A", X"332", X"33B", X"344", X"34C", X"354", X"35D", 
X"366", X"36F", X"377", X"380", X"389", X"391", X"399", X"3A2"
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
