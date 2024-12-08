library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Account_Record.all;

entity Account_Database is
    generic (
        LENGTH : INTEGER := 32
    );
    port (
        ADDRESS_IN  : IN STD_LOGIC_VECTOR(4 downto 0) := "00000";
        
        ACCOUNT_IN  : IN ACCOUNT;
        WRITE_EN    : IN STD_LOGIC := '0'; 
        
        ACCOUNT_OUT : OUT ACCOUNT
    );
end entity Account_Database;

architecture rtl of Account_Database is
    
    type Account_Array is array (0 to LENGTH - 1) of Account;
    SIGNAL Accounts : Account_Array := (others => EmptyAccount);

begin
    
    ACCOUNT_OUT <= Accounts(to_integer(unsigned(ADDRESS_IN)));

    ACCOUNT_WRITE: process(WRITE_EN)
    begin
        if rising_edge(WRITE_EN) then
            Accounts(to_integer(unsigned(ADDRESS_IN))) <= ACCOUNT_IN;
        end if;
    end process ACCOUNT_WRITE;
    
end architecture rtl;