
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;


entity cohete is
generic(L : integer:= 20;
        w : integer:= 10
        );
    Port ( xc : in STD_LOGIC_VECTOR (10 downto 0);
           yc : in STD_LOGIC_VECTOR (10 downto 0);
           hcout : in std_logic_vector(10 downto 0);
           vcout : in std_logic_vector(10 downto 0);
           paint : out std_logic;
           clkat : in std_logic
           );
end cohete;

architecture Behavioral of cohete is

COMPONENT ROM_CH
	port(
    add : in std_logic_vector(5 downto 0);
    data : out std_logic_vector(39 downto 0);
    clk : in std_logic
);
end component;
signal color : std_logic:='0';
signal address: std_logic_vector(5 downto 0);
signal dataout: std_logic_vector(39 downto 0);
signal input_1: integer;


begin
roMB: ROM_CH
port map (
    add=>address,
    data=>dataout,
    clk=>clkat
);
 		
--paint <= '1' when ((Vcout >= yc) AND (Vcout <= yc+l) AND (Hcout>=xc) AND (Hcout <=xc+w)) else '0' ;
process(hcout,vcout)
    begin
        if ((Vcout >= yc) AND (Vcout <= yc+l) AND (Hcout>=xc) AND (Hcout <=xc+w)) then
            input_1  <=  TO_INTEGER(unsigned(l-Vcout+yc));
            address<= std_logic_vector(to_unsigned(input_1, address'length));
            paint<=not(dataout(to_integer(unsigned(w-(Hcout-xc)))));
        else
            paint <= '0';
        end if;
end process;
end Behavioral;
