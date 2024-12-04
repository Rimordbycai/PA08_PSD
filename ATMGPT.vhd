library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ServerGPT is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        spi_in    : in  STD_LOGIC_VECTOR(7 downto 0);
        spi_ready : in  STD_LOGIC;
        ack_out   : out STD_LOGIC;
        balance   : out INTEGER
    );
end ServerGPT;

architecture Behavioral of ServerGPT is
    type state_type is (IDLE, PROCESS, RESPOND);
    signal current_state, next_state : state_type;
    signal account_db : array (0 to 9) of INTEGER := (1000, 2000, 1500, 3000, 500, 700, 900, 1200, 2500, 1800);
    signal balance_internal : INTEGER := 0;
begin
    process (clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process (current_state, spi_in, spi_ready)
    begin
        case current_state is
            when IDLE =>
                ack_out <= '0';
                if spi_ready = '1' then
                    next_state <= PROCESS;
                else
                    next_state <= IDLE;
                end if;

            when PROCESS =>
                case spi_in is
                    when "00000001" => -- LOGIN
                        ack_out <= '1'; -- Assume login always succeeds
                        next_state <= RESPOND;

                    when "00000010" => -- DEPOSIT
                        account_db(0) <= account_db(0) + 100; -- Example deposit amount
                        balance_internal <= account_db(0);
                        ack_out <= '1';
                        next_state <= RESPOND;

                    when "00000011" => -- WITHDRAW
                        if account_db(0) >= 100 then -- Example withdrawal amount
                            account_db(0) <= account_db(0) - 100;
                            balance_internal <= account_db(0);
                            ack_out <= '1';
                        else
                            ack_out <= '0'; -- Insufficient funds
                        end if;
                        next_state <= RESPOND;

                    when "00000100" => -- LOGOUT
                        ack_out <= '1';
                        next_state <= IDLE;

                    when others =>
                        next_state <= IDLE;
                end case;

            when RESPOND =>
                balance <= balance_internal;
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;
end Behavioral;
