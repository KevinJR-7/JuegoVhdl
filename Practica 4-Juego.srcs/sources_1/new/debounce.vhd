
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--use STD.textio.all;
--use IEEE.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;

entity debouncing is
  generic( COUNT_MAX: integer := 255; 
           COUNT_WIDTH: integer := 8);
 port( clk : in std_logic;
       I :in std_logic;
       O : out std_logic);
end debouncing;

architecture behave of debouncing is

signal count: std_logic_vector(COUNT_WIDTH-1 downto 0);
signal Iv: std_logic := '0';
begin
 process(clk)
   begin
   
    if(rising_edge(clk)) then
       if ( I = Iv) then
           if (count = COUNT_MAX) then
                 O <= I;
           else
               count <= count +1;
           end if;
        else
            count <= (others => '0');
            Iv <= I;
       end if;
    end if;
  end process;

end behave;


