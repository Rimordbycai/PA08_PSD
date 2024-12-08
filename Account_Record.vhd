library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Account_Record is
    
    type Account is record
        ID : STD_LOGIC_VECTOR(4 downto 0);
        PIN : STD_LOGIC_VECTOR(3 downto 0);
        ATM : STD_LOGIC_VECTOR(2 downto 0);
        MONEY : STD_LOGIC_VECTOR(15 downto 0);
    end record;

    function EmptyAccount return Account;
    
end package Account_Record;

package body Account_Record is
    
    function EmptyAccount return Account is
        variable ACC_EMPTY : ACCOUNT := (
            (others => '0'),
            (others => '0'),
            (others => '0'),
            (others => '0')
        );
    begin
        return ACC_EMPTY;
    end function;
    
end package body Account_Record;