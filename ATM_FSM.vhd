library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ATM_FSM is

    generic (
        ATM_ID : STD_LOGIC_VECTOR(2 downto 0) := "001"
    );

    port (
        CLK : IN STD_LOGIC;
        FSM_EN : IN STD_LOGIC;
        
        ATM_INSIDE : IN STD_LOGIC;
        ACCOUNT_ID : IN STD_LOGIC_VECTOR(4 downto 0);
        ACCOUNT_PIN : IN STD_LOGIC_VECTOR(3 downto 0);

        NOMINAL : IN INTEGER RANGE 0 to 255;
        MESSAGE_IN : IN STD_LOGIC_VECTOR(15 downto 0);

        OPTION_WS : STD_LOGIC -- 0 untuk withdraw, 1 untuk store
        
        MESSAGE_OUT : OUT STD_LOGIC_VECTOR(15 downto 0);
    );
end entity ATM_FSM;


architecture rtl of ATM_FSM is
    type StateType is (IDLE, LOGIN, CHOOSE_OPTION, WITHDRAW, STORE, CHECK, SUCCESS);
    SIGNAL STATE : StateType;

begin
    TRANSITION : PROCESS(CLK)
    begin
        if rising_edge(CLK) and FSM_EN = '1' then
            case STATE is

                when IDLE =>
                if ATM_INSIDE = '1' then
                    STATE <= LOGIN;
                end if;

                when LOGIN => 
                    MESSAGE_OUT <= "11" & ATM_ID & ACCOUNT_ID & ACCOUNT_PIN & "00";
                    -- SPI_ACTIVE <= '1';
                    STATE <= CHOOSE_OPTION;
                
                when CHOOSE_OPTION =>
                    if MESSAGE_IN(0) = '0' then
                        STATE <= IDLE;
                    else
                        if OPTION_WS = '0' then
                            STATE <= WITHDRAW;
                        else
                            STATE <= STORE;
                        end if;
                    end if;

                when WITHDRAW =>
                    MESSAGE_OUT <= "01" & ATM_ID & STD_LOGIC_VECTOR(TO_UNSIGNED(NOMINAL, 8)) & "000";
                    -- SPI_ACTIVE <= '1';
                    STATE <= CHECK;

                when STORE =>
                    MESSAGE_OUT <= "10" & ATM_ID & STD_LOGIC_VECTOR(TO_UNSIGNED(NOMINAL, 8)) & "000";
                    -- SPI_ACTIVE <= '1';
                    STATE <= CHECK;

                when CHECK =>
                    if MESSAGE_IN(15) = '0' then
                        STATE <= IDLE;
                    else
                        STATE <= SUCCESS;
                    end if;

                when SUCCESS => 
                    STATE <= IDLE;

            end case;
        end if;
    end process TRANSITION;
    
    
end architecture rtl;