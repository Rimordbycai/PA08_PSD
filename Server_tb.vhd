library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Server_tb is
end entity Server_tb;

architecture sim of Server_tb is
    -- Clock period
    constant CLOCK_PERIOD : time := 100 ps;

    -- Signals for Server
    signal CLK              : std_logic := '0';
    signal RST              : std_logic := '0';
    signal SDI              : std_logic := '1';
    signal SDO              : std_logic;
    signal SLAVE_SELECT     : std_logic_vector(1 to 7) := (others => '1'); -- Active LOW

    -- SPI Signals for Communication
    signal MESSAGE_SEND     : std_logic := '0';
    signal MESSAGE_RECEIVE  : std_logic := '0';
    signal DATA_SEND        : std_logic_vector(15 downto 0) := (others => '0');
    signal DATA_RECEIVE     : std_logic_vector(15 downto 0) := (others => '0');
    signal RECEIVED         : std_logic := '0';
    signal SENDING          : std_logic := '0';

    -- Constants for Test
    signal TEST_MESSAGE    : std_logic_vector(15 downto 0);

    -- Server component instantiation
    component Server
        port (
            CLK             : in std_logic;
            RST             : in std_logic;
            SDI             : in std_logic;
            SDO             : out std_logic;
            SLAVE_SELECT    : out std_logic_vector(1 to 7)
        );
    end component;

begin
    -- Clock generation
    clk_gen : process
    begin
        while true loop
            CLK <= '0';
            wait for CLOCK_PERIOD / 2;
            CLK <= '1';
            wait for CLOCK_PERIOD / 2;
        end loop;
    end process;

    -- Instantiate Server
    UUT_Server : Server
        port map (
            CLK => CLK,
            RST => RST,
            SDI => SDI,
            SDO => SDO,
            SLAVE_SELECT => SLAVE_SELECT
        );

    -- Simulate SPI Communication
    spi_simulation : process
    begin
        RST <= '1';
        wait for CLOCK_PERIOD;
        RST <= '0';

        -- Simulate sending a message from the ATM to the server
        SDI <= '0'; -- Simulate start bit
        wait for CLOCK_PERIOD;

        TEST_MESSAGE <= "1100100010010100"; -- LOGIN
        for i in 0 to 15 loop
            SDI <= TEST_MESSAGE(i);
            wait for CLOCK_PERIOD; -- Simulate data transmission
        end loop;

        -- Server processes the message
        wait for CLOCK_PERIOD * 5;
        
        -- Simulate sending a message from the ATM to the server
        SDI <= '0'; -- Simulate start bit
        wait for CLOCK_PERIOD;
        
        TEST_MESSAGE <= "1000100001010000"; -- STORE 10
        for i in 0 to 15 loop
            SDI <= TEST_MESSAGE(i);
            wait for CLOCK_PERIOD; -- Simulate data transmission
        end loop;

        wait;
    end process;

end architecture sim;
