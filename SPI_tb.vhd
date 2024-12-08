library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SPI_tb is
end entity SPI_tb;

architecture sim of SPI_tb is
    -- Constants
    constant SLAVE_COUNT : INTEGER := 8;
    constant DATA_LENGTH : INTEGER := 16;
    constant CLOCK_PERIOD : time := 100 ps;

    -- Signals for the SPI_Master
    signal SCK           : std_logic := '0';
    signal MASTER_DATA_SEND : std_logic_vector(DATA_LENGTH - 1 downto 0) := (others => '0');
    signal MASTER_SEND_MESSAGE : std_logic := '0';
    signal MASTER_SDO    : std_logic;
    signal MASTER_SENDING : std_logic;
    signal MASTER_SEND_ADDRESS : std_logic_vector(2 downto 0) := "001";
    signal MASTER_SLAVE_SELECT : std_logic_vector(1 to SLAVE_COUNT - 1);
    signal MASTER_DATA_RECEIVE : std_logic_vector(DATA_LENGTH - 1 downto 0);
    signal MASTER_RECEIVED : std_logic;

    -- Signals for the SPI_Slave
    signal SLAVE_SDO     : std_logic;
    signal SLAVE_DATA_SEND : std_logic_vector(DATA_LENGTH - 1 downto 0) := (others => '0');
    signal SLAVE_SEND_MESSAGE : std_logic := '0';
    signal SLAVE_SENDING : std_logic;
    signal SLAVE_SELECT  : std_logic := '1';
    signal SLAVE_SDI     : std_logic := '1';
    signal SLAVE_DATA_RECEIVE : std_logic_vector(DATA_LENGTH - 1 downto 0);
    signal SLAVE_RECEIVED : std_logic;
    signal LINE_BUSY     : std_logic := '0';

    -- Interconnect signals
    signal SDO_BUS : std_logic := '1'; -- Shared bus for SDO lines

    -- Components
    component SPI_Master
        generic (
            SLAVE_COUNT : INTEGER := 8;
            DATA_LENGTH : INTEGER := 16
        );
        port (
            SCK            : IN  std_logic;
            DATA_SEND      : IN  std_logic_vector(DATA_LENGTH - 1 downto 0);
            SEND_MESSAGE   : IN  std_logic;
            SDO            : OUT std_logic;
            SENDING        : OUT std_logic;
            SEND_ADDRESS   : IN  std_logic_vector(2 downto 0);
            SLAVE_SELECT   : OUT std_logic_vector(1 to SLAVE_COUNT - 1);
            DATA_RECEIVE   : OUT std_logic_vector(DATA_LENGTH - 1 downto 0);
            SDI            : IN  std_logic;
            RECEIVED       : OUT std_logic
        );
    end component;

    component SPI_Slave
        generic (
            SLAVE_COUNT : INTEGER := 8;
            DATA_LENGTH : INTEGER := 16
        );
        port (
            SCK            : IN  std_logic;
            DATA_SEND      : IN  std_logic_vector(DATA_LENGTH - 1 downto 0);
            SEND_MESSAGE   : IN  std_logic;
            LINE_BUSY      : INOUT std_logic;
            SDO            : OUT std_logic;
            SENDING        : OUT std_logic;
            SLAVE_SELECT   : IN  std_logic;
            SDI            : IN  std_logic;
            DATA_RECEIVE   : OUT std_logic_vector(DATA_LENGTH - 1 downto 0);
            RECEIVED       : OUT std_logic
        );
    end component;

begin
    -- Clock generation
    clock_process : process
    begin
        while true loop
            SCK <= '0';
            wait for CLOCK_PERIOD / 2;
            SCK <= '1';
            wait for CLOCK_PERIOD / 2;
        end loop;
    end process;

    -- Instantiate SPI_Master
    UUT_MASTER: SPI_Master
        generic map (
            SLAVE_COUNT => SLAVE_COUNT,
            DATA_LENGTH => DATA_LENGTH
        )
        port map (
            SCK            => SCK,
            DATA_SEND      => MASTER_DATA_SEND,
            SEND_MESSAGE   => MASTER_SEND_MESSAGE,
            SDO            => MASTER_SDO,
            SENDING        => MASTER_SENDING,
            SEND_ADDRESS   => MASTER_SEND_ADDRESS,
            SLAVE_SELECT   => MASTER_SLAVE_SELECT,
            DATA_RECEIVE   => MASTER_DATA_RECEIVE,
            SDI            => SDO_BUS,
            RECEIVED       => MASTER_RECEIVED
        );

    -- Instantiate SPI_Slave
    UUT_SLAVE: SPI_Slave
        generic map (
            SLAVE_COUNT => SLAVE_COUNT,
            DATA_LENGTH => DATA_LENGTH
        )
        port map (
            SCK            => SCK,
            DATA_SEND      => SLAVE_DATA_SEND,
            SEND_MESSAGE   => SLAVE_SEND_MESSAGE,
            LINE_BUSY      => LINE_BUSY,
            SDO            => SLAVE_SDO,
            SENDING        => SLAVE_SENDING,
            SLAVE_SELECT   => '0', -- Slave is selected by the master
            SDI            => MASTER_SDO,
            DATA_RECEIVE   => SLAVE_DATA_RECEIVE,
            RECEIVED       => SLAVE_RECEIVED
        );

    -- Connect the SDO bus
    SDO_BUS <= SLAVE_SDO;

    -- Test process
    test_process : process
    begin
        -- Initialize master and slave
        SLAVE_DATA_SEND <= "1100100010000100"; -- Slave sends
        MASTER_DATA_SEND <= "0101010101000000"; -- Master responds 

        -- Start communication
        SLAVE_SEND_MESSAGE <= '1';
        wait for CLOCK_PERIOD * 2; -- Allow the master to start sending
        SLAVE_SEND_MESSAGE <= '0';

        wait for CLOCK_PERIOD * DATA_LENGTH;

        MASTER_SEND_MESSAGE <= '1';
        wait for CLOCK_PERIOD * 2; -- Allow the master to start sending
        MASTER_SEND_MESSAGE <= '0';

        wait for CLOCK_PERIOD * DATA_LENGTH;

        -- Assert received data
        assert MASTER_DATA_RECEIVE = "1100100010000100"
            report "Master did not receive the correct data from the slave!" severity error;
        assert SLAVE_DATA_RECEIVE = "0101010101000000"
            report "Slave did not receive the correct data from the master!" severity error;

        wait;
    end process;

end architecture sim;
