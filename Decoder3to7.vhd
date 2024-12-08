library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Decoder3to7 is
    Port (
        INPUT       : in  std_logic_vector(2 downto 0); -- 3-bit input
        OUTPUT      : out std_logic_vector(6 downto 0)  -- 7-bit output
    );
end entity Decoder3to7;

architecture Behavioral of Decoder3to7 is
begin
    process(INPUT)
    begin
        case INPUT is
            when "000" =>
                OUTPUT <= "0000000"; -- disimpan/reserved untuk not connected
            when "001" =>
                OUTPUT <= "1000000";
            when "010" =>
                OUTPUT <= "0100000";
            when "011" =>
                OUTPUT <= "0010000";
            when "100" =>
                OUTPUT <= "0001000";
            when "101" =>
                OUTPUT <= "0000100";
            when "110" =>
                OUTPUT <= "0000010";
            when "111" =>
                OUTPUT <= "0000001";
            when others =>
                OUTPUT <= "0000000"; -- case default
        end case;
    end process;
end Behavioral;