library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
----use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use STD.textio.all;
--use IEEE.std_logic_textio.all;
--library UNISIM;
--use UNISIM.VComponents.all;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM_CH is
port(

add : in std_logic_vector (5 downto 0);
data: out std_logic_vector (39 downto 0);
clk : in std_logic
);
end ROM_CH;

architecture Behavioral of ROM_CH is
--constant ADDR_WIDTH: integer :=11; 
--constant DATA_WIDTH: integer:=8; 
type rom_type is array (0 to 22) of std_logic_vector(39 downto 0);

CONSTANT cat:rom_type:=(
--"1111111111111111111111111111111111111111",
--"1111111111111100000000000000000000111111",
--"1111111111111100111111111111111100111111",
--"1111111111111011111111111111111110011111",
--"1111111111111011111111111111111111011111",
--"1111111111111011111111111111111111011111",
--"1111111111111011111111111100111111010011",
--"1111111111111011111111111010111111000001",
--"1111111111111011111111110011001111011101",
--"1111111000011011111111110011100000011101",
--"1111110000000011111111110011110001111101",
--"1111110011000011111111110111111111111101",
--"1111110000110011111111100111111111111110",
--"1111111100000011111111100111001111100110",
--"1111111111100011111111100111001110100110",
--"1111111111111011111111100111111111111110",
--"1111111111111011111111110111101101101110",
--"1111111111110001111111110011100000001101",
--"1111111111100000111111111001111111111011",
--"1111111111011100000000000000000000000111",
--"1111111111011010010111111101001010011111",
--"1111111111000111000111111110001100011111",
--"1111111111111111111111111111111111111111"

"1111111111111111111111111111111111111111",
"1111111111000111000111111110001100011111",
"1111111111011010010111111101001010011111",
"1111111111011100000000000000000000000111",
"1111111111100000111111111001111111111011",
"1111111111110001111111110011100000001101",
"1111111111111011111111110111101101101110",
"1111111111111011111111100111111111111110",
"1111111111100011111111100111001110100110",
"1111111100000011111111100111001111100110",
"1111110000110011111111100111111111111110",
"1111110011000011111111110111111111111101",
"1111110000000011111111110011110001111101",
"1111111000011011111111110011100000011101",
"1111111111111011111111110011001111011101",
"1111111111111011111111111010111111000001",
"1111111111111011111111111100111111010011",
"1111111111111011111111111111111111011111",
"1111111111111011111111111111111111011111",
"1111111111111011111111111111111110011111",
"1111111111111100111111111111111100111111",
"1111111111111100000000000000000000111111",
"1111111111111111111111111111111111111111"
);

type rom2_type is array (0 to 22) of std_logic_vector(39 downto 0);

CONSTANT cat2:rom2_type:=(



"1111111111111111111111111111111111111111",
"1111111111000111000111111110001100011111",
"1111111111011010010111111101001010011111",
"1111111111011100000000000000000000000111",
"1111111111100000111111111001111111111011",
"1111111111110001111111110011100000001101",
"1110000001100011111111110111101101101110",
"1111111111111011111111100111111111111110",
"1111111111100011111111100111001110100110",
"1000001100000011111111100111001111100110",
"1111110000110011111111100111111111111110",
"1111110011000011111111110111111111111101",
"1111110000000011111111110011110001111101",
"0000111000011011111111110011100000011101",
"1111111111111011111111110011001111011101",
"1111111111111011111111111010111111000001",
"1110000000011011111111111100111111010011",
"1111111111111011111111111111111111011111",
"1111111111111011111111111111111111011111",
"1110000000011011111111111111111110011111",
"1111111111111100111111111111111100111111",
"1111111111111100000000000000000000111111",
"1111111111111111111111111111111111111111"
);



begin
--data <= (CAT(to_integer(unsigned(add))));
process(clk)
begin 
    if(clk='1') then 
    data <= (CAT(to_integer(unsigned(add))));
    else
    data <= (CAT2(to_integer(unsigned(add))));
    end if;
end process;


end Behavioral;