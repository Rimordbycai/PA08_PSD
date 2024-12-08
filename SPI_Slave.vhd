library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SPI_Slave is
    generic (
        DATA_LENGTH : INTEGER := 16
    );   

    port (
        SCK : IN  STD_LOGIC;

        DATA_SEND       : IN STD_LOGIC_VECTOR(DATA_LENGTH - 1 downto 0) := (others => '0');
        SEND_MESSAGE    : IN STD_LOGIC;

        LINE_BUSY       : INOUT STD_LOGIC := '0';  -- When SDO line is used by other slaves.
        SDO             : OUT STD_LOGIC := '1';
        SENDING         : OUT STD_LOGIC := '0';

        SLAVE_SELECT    : IN STD_LOGIC := '1';
        SDI : IN  STD_LOGIC := '1';
        DATA_RECEIVE    : OUT STD_LOGIC_VECTOR(DATA_LENGTH - 1 downto 0) := (others => '0');
        RECEIVED        : OUT STD_LOGIC := '0'
    );
end entity SPI_Slave;

architecture rtl of SPI_Slave is
    type StateType is (IDLE, PULL_DOWN, PROCESSING);

    signal SEND_STATE : StateType := IDLE;
    signal SEND_COUNTER : INTEGER range 0 to DATA_LENGTH := 0;

    signal RECEIVE_STATE : StateType := IDLE;
    signal RECEIVE_COUNTER : INTEGER range 0 to DATA_LENGTH := 0;
begin
    
    SEND: process(SCK)
    begin
        if rising_edge(SCK) then
            case SEND_STATE is
                when IDLE =>
                    SDO <= '1';
                    if SEND_MESSAGE = '1' then
                        SEND_STATE <= PULL_DOWN;
                    end if;
                
                when PULL_DOWN =>
                    if LINE_BUSY /= '1' then 
                        SDO <= '0';
                        SENDING <= '1';
                        SEND_STATE <= PROCESSING;
                        LINE_BUSY <= '1';
                    end if;

                when PROCESSING =>
                    if SEND_COUNTER >= DATA_LENGTH then
                        SEND_COUNTER <= 0;
                        SENDING <= '0';
                        LINE_BUSY <= '0';
                        SEND_STATE <= IDLE;
                    else
                        SDO <= DATA_SEND(SEND_COUNTER);
                        SEND_COUNTER <= SEND_COUNTER + 1;
                    end if;
            end case;
        end if; 
    end process;

    RECEIVE: process(SCK)
    begin
        if rising_edge(SCK) then
            case RECEIVE_STATE is 
                when IDLE =>
                    if SDI = '0' and SLAVE_SELECT = '0' then -- SDI is pulled down, slave is selected.
                        RECEIVE_STATE <= PROCESSING;
                    end if;
                
                when PROCESSING =>
                    if RECEIVE_COUNTER >= DATA_LENGTH then
                        RECEIVE_COUNTER <= 0;
                        RECEIVED <= '1';
                        RECEIVE_STATE <= PULL_DOWN;
                    else
                        DATA_RECEIVE(RECEIVE_COUNTER) <= SDI;
                        RECEIVE_COUNTER <= RECEIVE_COUNTER + 1;
                    end if;
                
                when PULL_DOWN =>
                    RECEIVED <= '0';
                    RECEIVE_STATE <= IDLE;
                
            end case;
        end if;
    end process;
    
end architecture rtl;