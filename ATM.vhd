library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Account_Record.all;

entity ATM is
    generic (
        ATM_CONTROL_ID : STD_LOGIC_VECTOR(2 downto 0) := "001"
    );

    port (
        CLK : IN STD_LOGIC;

        -- Input USER
        INPUT_ID : IN STD_LOGIC_VECTOR(4 downto 0);
        INPUT_PIN : IN STD_LOGIC_VECTOR(3 downto 0);
        INPUT_NOMINAL : IN STD_LOGIC_VECTOR(7 downto 0);
        OPTION_WS : IN STD_LOGIC; -- 0 untuk withdraw, 1 untuk store

        -- Output USER
        CURRENT_BALANCE : OUT STD_LOGIC_VECTOR(15 downto 0);

        -- Input SPI
        SLAVE_SELECT    : IN STD_LOGIC := '1';
        SDI             : IN  STD_LOGIC := '1';

        -- Output SPI
        LINE_BUSY       : INOUT STD_LOGIC := '0';  -- When SDO line is used by other slaves.
        SDO             : OUT STD_LOGIC := '1'
    );
end entity ATM;

architecture rtl of ATM is
    component ATM_FSM is
        generic (
            ATM_CONTROL_ID : STD_LOGIC_VECTOR(2 downto 0) := "001"
        );

        port (
            CLK : IN STD_LOGIC;
            FSM_EN : IN STD_LOGIC;
            
            INPUT_ID : IN STD_LOGIC_VECTOR(4 downto 0);
            INPUT_PIN : IN STD_LOGIC_VECTOR(3 downto 0);
            INPUT_NOMINAL : IN STD_LOGIC_VECTOR(7 downto 0);

            OPTION_WS : IN STD_LOGIC; -- 0 untuk withdraw, 1 untuk store
            
            MESSAGE_IN : IN STD_LOGIC_VECTOR(15 downto 0);
            
            MESSAGE_OUT : OUT STD_LOGIC_VECTOR(15 downto 0);
            MESSAGE_SEND : OUT STD_LOGIC;

            CURRENT_BALANCE : OUT STD_LOGIC_VECTOR(15 downto 0)
        );
    end component ATM_FSM;

    component SPI_Slave is
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
    end component SPI_Slave;

    signal FSM_EN_S, MESSAGE_SEND_S, SENDING_S, RECEIVED_S : STD_LOGIC := '1';
    signal MESSAGE_IN_S : STD_LOGIC_VECTOR(15 downto 0);
    signal MESSAGE_OUT_S : STD_LOGIC_VECTOR(15 downto 0);
begin

    EN_TRIGGER : PROCESS(SENDING_S, RECEIVED_S)
    begin
        if rising_edge(SENDING_S) then
            FSM_EN_S <= '0';
        end if;

        if rising_edge(RECEIVED_S) then
            FSM_EN_S <= '1';
        end if;
    end process;

    FSM: ATM_FSM
    generic map (
        ATM_CONTROL_ID
    )
    port map (
        CLK => CLK,
        FSM_EN => FSM_EN_S,
        INPUT_ID => INPUT_ID,
        INPUT_PIN => INPUT_PIN,
        INPUT_NOMINAL => INPUT_NOMINAL,
        OPTION_WS => OPTION_WS,
        MESSAGE_IN => MESSAGE_IN_S,
        MESSAGE_OUT => MESSAGE_OUT_S,
        MESSAGE_SEND => MESSAGE_SEND_S,
        CURRENT_BALANCE => CURRENT_BALANCE
    );

    SPI: SPI_Slave
    generic map (
        DATA_LENGTH => 16
    )
    port map (
        SCK             => CLK,
        DATA_SEND       => MESSAGE_OUT_S,
        SEND_MESSAGE    => MESSAGE_SEND_S,
        LINE_BUSY       => LINE_BUSY,
        SDO             => SDO,
        SENDING         => SENDING_S,
        SLAVE_SELECT    => SLAVE_SELECT,
        SDI             => SDI,
        DATA_RECEIVE    => MESSAGE_IN_S,
        RECEIVED        => RECEIVED_S
    );
    
end architecture rtl;