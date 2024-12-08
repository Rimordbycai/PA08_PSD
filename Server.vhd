library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Account_Record.all;

entity Server is
    port (
        CLK             : IN STD_LOGIC;
        RST             : IN STD_LOGIC;

        SDI             : IN STD_LOGIC;
        SDO             : OUT STD_LOGIC;
        SLAVE_SELECT    : OUT STD_LOGIC_VECTOR(1 to 7) := (others => '1') -- Active LOW
    );
end entity Server;

architecture rtl of Server is
    component Server_FSM is
        port (
            CLK : IN STD_LOGIC;
            FSM_EN : IN STD_LOGIC;
            
            ACCOUNT_DATA : IN ACCOUNT;
            MESSAGE_IN : IN STD_LOGIC_VECTOR(15 downto 0);        
    
            ACCOUNT_ADDRESS_ID : OUT STD_LOGIC_VECTOR(4 downto 0);
            ACCOUNT_UPDATE : OUT ACCOUNT;
            ACCOUNT_WRITE : OUT STD_LOGIC;

            ATM_ADDRESS : OUT STD_LOGIC_VECTOR(2 downto 0);
            
            MESSAGE_OUT : OUT STD_LOGIC_VECTOR(15 downto 0);
            SEND_MESSAGE : OUT STD_LOGIC := '0' 
        );
    end component Server_FSM;

    component SPI_Master is
        generic (
            SLAVE_COUNT : INTEGER := 8;
            DATA_LENGTH : INTEGER := 16
        );   
    
        port (
            SCK : IN  STD_LOGIC;
    
            DATA_SEND       : IN STD_LOGIC_VECTOR(DATA_LENGTH - 1 downto 0) := (others => '0');
            SEND_MESSAGE    : IN STD_LOGIC;
            SDO             : OUT STD_LOGIC := '1';
            SENDING         : OUT STD_LOGIC := '0';
    
            SEND_ADDRESS    : IN STD_LOGIC_VECTOR(2 downto 0);
            SLAVE_SELECT    : OUT STD_LOGIC_VECTOR(1 to SLAVE_COUNT - 1) := (others => '1'); -- Active LOW
    
            DATA_RECEIVE    : OUT STD_LOGIC_VECTOR(DATA_LENGTH - 1 downto 0) := (others => '0');
            SDI : IN  STD_LOGIC := '1';
            RECEIVED        : OUT STD_LOGIC := '0'
        );
    end component SPI_Master;

    component Account_Database is
        generic (
            LENGTH : INTEGER := 32
        );
        port (
            CLK         : IN STD_LOGIC; -- Clock signal
            RST         : IN STD_LOGIC := '0'; -- Reset signal
    
            ADDRESS_IN  : IN STD_LOGIC_VECTOR(4 downto 0) := "00000";
            
            ACCOUNT_IN  : IN ACCOUNT;
            WRITE_EN    : IN STD_LOGIC := '0'; 
            
            ACCOUNT_OUT : OUT ACCOUNT
        );
    end component Account_Database;

    signal FSM_EN_S, ACCOUNT_UPDATE_S, ACCOUNT_WRITE_TRIGGER, SEND_MESSAGE_TRIGGER : STD_LOGIC := '1';
    signal ACCOUNT_READ, ACCOUNT_WRITE : ACCOUNT;
    signal SENDING_S, RECEIVED_S : STD_LOGIC := '1';
    signal ATM_SELECT_ADDRESS : STD_LOGIC_VECTOR(2 downto 0);
    signal MESSAGE_IN_S : STD_LOGIC_VECTOR(15 downto 0);
    signal MESSAGE_OUT_S : STD_LOGIC_VECTOR(15 downto 0);
    signal ACCOUNT_ADDRESS : STD_LOGIC_VECTOR(4 downto 0);
begin

    EN_TRIGGER : PROCESS(SENDING_S, RECEIVED_S)
    begin
        if rising_edge(SENDING_S) then
            FSM_EN_S <= '0';
        end if;

        if rising_edge(RECEIVED_S) OR falling_edge(SENDING_S) then
            FSM_EN_S <= '1';
        end if;
    end process;
    
    FSM: Server_FSM
    port map (
        CLK                 => CLK,
        FSM_EN              => FSM_EN_S,

        ACCOUNT_DATA        => ACCOUNT_READ,
        MESSAGE_IN          => MESSAGE_IN_S,

        ACCOUNT_ADDRESS_ID  => ACCOUNT_ADDRESS,
        ACCOUNT_UPDATE      => ACCOUNT_WRITE,
        ACCOUNT_WRITE       => ACCOUNT_WRITE_TRIGGER,

        ATM_ADDRESS         => ATM_SELECT_ADDRESS,

        MESSAGE_OUT         => MESSAGE_OUT_S,
        SEND_MESSAGE        => SEND_MESSAGE_TRIGGER
    );

    DATABASE: Account_Database
    generic map (
        LENGTH => 32
    )
    port map (
        CLK => CLK,
        RST => RST,

        ADDRESS_IN => ACCOUNT_ADDRESS,

        ACCOUNT_IN => ACCOUNT_WRITE,
        WRITE_EN => ACCOUNT_WRITE_TRIGGER,

        ACCOUNT_OUT => ACCOUNT_READ
    );

    SPI: SPI_Master
    generic map (
        SLAVE_COUNT => 8,
        DATA_LENGTH => 16
    )
    port map (
        SCK          => CLK,

        DATA_SEND    => MESSAGE_OUT_S,
        SEND_MESSAGE => SEND_MESSAGE_TRIGGER,
        SDO          => SDO,
        SENDING      => SENDING_S,

        SEND_ADDRESS  => ATM_SELECT_ADDRESS,
        SLAVE_SELECT => SLAVE_SELECT,

        DATA_RECEIVE => MESSAGE_IN_S,
        SDI          => SDI,
        RECEIVED     => RECEIVED_S
    );
    
    
end architecture rtl;