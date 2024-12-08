library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ATM_Server_System_tb is
end entity ATM_Server_System_tb;

architecture behavior of ATM_Server_System_tb is

    -- Component declarations
    component ATM_Server_System is
        port (
            CLK          : IN STD_LOGIC;
            RST          : IN STD_LOGIC;
            SDI          : IN STD_LOGIC;
            SDO          : OUT STD_LOGIC;
            SLAVE_SELECT : OUT STD_LOGIC_VECTOR(1 to 7)
        );
    end component;

    -- Signals for the clock, reset, and SPI bus
    signal CLK          : STD_LOGIC := '0';
    signal RST          : STD_LOGIC := '0';
    signal SDI          : STD_LOGIC := '1'; -- Default idle value
    signal SDO          : STD_LOGIC;
    signal SLAVE_SELECT : STD_LOGIC_VECTOR(1 to 7);

    -- Additional signals for checking outputs (optional)
    signal MESSAGE_OUT  : STD_LOGIC_VECTOR(15 downto 0);
    signal CURRENT_BALANCE : STD_LOGIC_VECTOR(15 downto 0);

    -- Clock generation process
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock

    begin

        -- Clock generation
        CLK_GEN : process
        begin
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end process;

        -- Testbench stimuli
        stimulus : process
        begin
            -- Reset the system
            RST <= '1';
            wait for 20 ns;
            RST <= '0';
            wait for 20 ns;

            -- Test ATM1 communication
            -- Select ATM 1 by setting SLAVE_SELECT(1) = '0'
            SLAVE_SELECT(1) <= '0';
            wait for 40 ns;
            -- Simulate sending a message to ATM 1
            SDI <= '1';  -- Send some data from the server to ATM1
            wait for 20 ns;
            SDI <= '0';  -- End transmission
            wait for 20 ns;

            -- Test ATM2 communication
            -- Select ATM 2 by setting SLAVE_SELECT(2) = '0'
            SLAVE_SELECT(2) <= '0';
            wait for 40 ns;
            -- Simulate sending a message to ATM 2
            SDI <= '1';  -- Send some data from the server to ATM2
            wait for 20 ns;
            SDI <= '0';  -- End transmission
            wait for 20 ns;

            -- Test ATM3 communication
            -- Select ATM 3 by setting SLAVE_SELECT(3) = '0'
            SLAVE_SELECT(3) <= '0';
            wait for 40 ns;
            -- Simulate sending a message to ATM 3
            SDI <= '1';  -- Send some data from the server to ATM3
            wait for 20 ns;
            SDI <= '0';  -- End transmission
            wait for 20 ns;

            wait;
        end process;

        -- Instantiate the ATM_Server_System design under test (DUT)
        DUT: ATM_Server_System
            port map (
                CLK => CLK,
                RST => RST,
                SDI => SDI,
                SDO => SDO,
                SLAVE_SELECT => SLAVE_SELECT
            );

end architecture behavior;
