library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Account_Record.all;

entity Account_Database is
    generic (
        LENGTH : INTEGER := 32
    );
    port (
        CLK         : IN STD_LOGIC; -- Clock signal
        RST         : IN STD_LOGIC := '0'; -- Reset signal

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
    
    -- Account out is based on the address in.
    ACCOUNT_OUT <= Accounts(to_integer(unsigned(ADDRESS_IN)));

    PROCESS(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                -- Reset all accounts
                for i in 0 to LENGTH - 1 loop
                    Accounts(i).ID <= STD_LOGIC_VECTOR(to_unsigned(i, Accounts(i).ID'length));
                    Accounts(i).PIN <= (others => '0');
                    Accounts(i).ATM <= (others => '0');
                    Accounts(i).MONEY <= (others => '0');
                end loop;
            elsif WRITE_EN = '1' then
                Accounts(to_integer(unsigned(ADDRESS_IN))).PIN <= ACCOUNT_IN.PIN;
                Accounts(to_integer(unsigned(ADDRESS_IN))).ATM <= ACCOUNT_IN.ATM;
                Accounts(to_integer(unsigned(ADDRESS_IN))).MONEY <= ACCOUNT_IN.MONEY;
            end if;
        end if;
    end process;

end architecture rtl;
