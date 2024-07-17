----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/02/2023 09:16:39 AM
-- Design Name: 
-- Module Name: barrera - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;


entity barrera is
generic(L : integer:= 20;
        w : integer:= 10
        );
    Port ( xc : in STD_LOGIC_VECTOR (10 downto 0);
           yc : in STD_LOGIC_VECTOR (10 downto 0);
           hcout : in std_logic_vector(10 downto 0);
           vcout : in std_logic_vector(10 downto 0);
           paint : out std_logic
           );
end barrera;

architecture Behavioral of barrera is

COMPONENT ROM_B
	port(
    add : in std_logic_vector(5 downto 0);
    data : out std_logic_vector(22 downto 0)
);
end component;
signal color : std_logic:='0';
signal address: std_logic_vector(5 downto 0);
signal dataout: std_logic_vector(22 downto 0);
signal input_1: integer;


begin
roM: ROM_B
port map (
    add=>address,
    data=>dataout
);
 		
--paint <= '1' when ((Vcout >= yc) AND (Vcout <= yc+l) AND (Hcout>=xc) AND (Hcout <=xc+w)) else '0' ;
process(hcout,vcout)
    begin
        if ((Vcout >= yc) AND (Vcout <= yc+l) AND (Hcout>=xc) AND (Hcout <=xc+w)) then
            input_1  <=  TO_INTEGER(unsigned(l-Vcout+yc));
            address<= std_logic_vector(to_unsigned(input_1, address'length));
            paint<=(dataout(to_integer(unsigned(w-(Hcout-xc)))));
        else
            paint <= '0';
        end if;
end process;
end Behavioral;

