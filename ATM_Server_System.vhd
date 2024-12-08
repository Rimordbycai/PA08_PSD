library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ATM_Server_System is
    port (
        CLK          : IN STD_LOGIC;
        RST          : IN STD_LOGIC;
        
        -- Shared SPI Bus
        SDI          : IN STD_LOGIC;
        SDO          : OUT STD_LOGIC;
        SLAVE_SELECT : OUT STD_LOGIC_VECTOR(1 to 7) -- Active LOW
    );
end entity ATM_Server_System;

architecture rtl of ATM_Server_System is
    -- Server signals
    signal SERVER_SDO, SERVER_SDI : STD_LOGIC;
    signal SERVER_SLAVE_SELECT    : STD_LOGIC_VECTOR(1 to 7);
    
    -- ATM signals
    signal ATM_SDO  : STD_LOGIC_VECTOR(1 to 3);
    signal ATM_SDI  : STD_LOGIC_VECTOR(1 to 3);
    signal LINE_BUSY: STD_LOGIC_VECTOR(1 to 3) := (others => '0');
    signal SENDING  : STD_LOGIC_VECTOR(1 to 3);
begin

    -- Instantiate Server
    SERVER: entity work.Server
        port map (
            CLK          => CLK,
            RST          => RST,
            SDI          => SERVER_SDI,
            SDO          => SERVER_SDO,
            SLAVE_SELECT => SERVER_SLAVE_SELECT
        );

    -- Connect Server's SPI signals to each ATM
    ATM1: entity work.ATM
        generic map (
            ATM_CONTROL_ID => "001"
        )
        port map (
            CLK           => CLK,
            INPUT_ID      => "00001", -- Example ID
            INPUT_PIN     => "1010",  -- Example PIN
            INPUT_NOMINAL => "00101010", -- Example nominal
            OPTION_WS     => '0',  -- Example withdraw/store option
            CURRENT_BALANCE => open, -- Example output

            -- SPI Signals
            SLAVE_SELECT => SERVER_SLAVE_SELECT(1),
            SDI          => SERVER_SDO, -- Data out from server
            SDO          => ATM_SDO(1), -- Data to server
            LINE_BUSY    => LINE_BUSY(1)
        );

    ATM2: entity work.ATM
        generic map (
            ATM_CONTROL_ID => "010"
        )
        port map (
            CLK           => CLK,
            INPUT_ID      => "00010", -- Example ID
            INPUT_PIN     => "1100",  -- Example PIN
            INPUT_NOMINAL => "01010101", -- Example nominal
            OPTION_WS     => '1',  -- Example withdraw/store option
            CURRENT_BALANCE => open, -- Example output

            -- SPI Signals
            SLAVE_SELECT => SERVER_SLAVE_SELECT(2),
            SDI          => SERVER_SDO, -- Data out from server
            SDO          => ATM_SDO(2), -- Data to server
            LINE_BUSY    => LINE_BUSY(2)
        );

    ATM3: entity work.ATM
        generic map (
            ATM_CONTROL_ID => "011"
        )
        port map (
            CLK           => CLK,
            INPUT_ID      => "00011", -- Example ID
            INPUT_PIN     => "1111",  -- Example PIN
            INPUT_NOMINAL => "01111011", -- Example nominal
            OPTION_WS     => '0',  -- Example withdraw/store option
            CURRENT_BALANCE => open, -- Example output

            -- SPI Signals
            SLAVE_SELECT => SERVER_SLAVE_SELECT(3),
            SDI          => SERVER_SDO, -- Data out from server
            SDO          => ATM_SDO(3), -- Data to server
            LINE_BUSY    => LINE_BUSY(3)
        );

    -- Combine ATM SDO lines into a single input for the Server
    SERVER_SDI <= ATM_SDO(1) or ATM_SDO(2) or ATM_SDO(3);

end architecture rtl;
