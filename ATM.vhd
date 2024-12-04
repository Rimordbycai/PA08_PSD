library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ATM is
    port (
        ATM_INSIDE : IN STD_LOGIC;
        ACCOUNT_ID : IN STD_LOGIC_VECTOR(3 downto 0);
        ACCOUNT_PIN : IN STD_LOGIC_VECTOR(3 downto 0)   ;

        OPTION_WS : STD_LOGIC; -- 0 untuk withdraw, 1 untuk store
    );
end entity ATM;


architecture rtl of ATM is
    type StateType is (IDLE, LOGIN, CHOOSE_OPTION, WITHDRAW, STORE, SUCCESS);
    SIGNAL STATE : StateType;
begin
    
    
    
end architecture rtl;