library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SPI_Master is
    generic (
        SLAVE_COUNT : INTEGER := 8;
        DATA_LENGTH : INTEGER := 16
    );   

    port (
        SCK : IN  STD_LOGIC;
        CSB : OUT STD_LOGIC_VECTOR(1 to SLAVE_COUNT);

        SDI : IN  STD_LOGIC;
        SDO : OUT STD_LOGIC
    );
end entity SPI_Master;