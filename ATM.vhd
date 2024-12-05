library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ATM is

    generic (
        ATM_ID : STD_LOGIC_VECTOR(2 downto 0) := '001';
    )

    port (
        CLK : IN STD_LOGIC;
        ATM_INSIDE : IN STD_LOGIC;
        ACCOUNT_ID : IN STD_LOGIC_VECTOR(4 downto 0);
        ACCOUNT_PIN : IN STD_LOGIC_VECTOR(3 downto 0);

        OPTION_WS : STD_LOGIC; -- 0 untuk withdraw, 1 untuk store
    );
end entity ATM;


architecture rtl of ATM is
    type StateType is (IDLE, LOGIN, CHOOSE_OPTION, WITHDRAW, STORE, SUCCESS);
    SIGNAL STATE : StateType;

    signal SPI_ACTIVE : STD_LOGIC;

    signal MESSAGE_OUT : STD_LOGIC_VECTOR(15 downto 0);
    signal MESSAGE_IN : STD_LOGIC_VECTOR(15 downto 0);

begin
    TRANSITION : PROCESS(CLK)
    begin
        if rising_edge(CLK) and SPI_ACTIVE = '0' then
            case STATE is

                when IDLE =>
                if ATM_INSIDE = '1' then
                    STATE <= LOGIN
                end if;

                when LOGIN => 
                    MESSAGE_OUT <= '11' & ATM_ID & ACCOUNT_ID & ACCOUNT_PIN & '000';
                    SPI_ACTIVE <= '1';
                    STATE <= CHOOSE_OPTION;
                
                when CHOOSE_OPTION =>
                    

            end case;
        end if;
    end process TRANSITION;
    
    
end architecture rtl;