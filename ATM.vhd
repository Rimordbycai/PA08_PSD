library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Account_Record.all;

entity ATM is
    port (
        ACC : IN ACCOUNT
    );
end entity ATM;