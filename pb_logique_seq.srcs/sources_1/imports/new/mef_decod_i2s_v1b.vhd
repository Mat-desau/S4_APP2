---------------------------------------------------------------------------------------------
-- circuit mef_decod_i2s_v1b.vhd                   Version mise en oeuvre avec des compteurs
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- Version         : 1.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 7 mai 2019
-- Auteur(s)       : Daniel Dalle
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2019.1
---------------------------------------------------------------------------------------------
-- Description:
-- MEF pour decodeur I2S version 1b
-- La MEF est substituee par un compteur
--
-- notes
-- frequences (peuvent varier un peu selon les contraintes de mise en oeuvre)
-- i_lrc        ~ 48.    KHz    (~ 20.8    us)
-- d_ac_mclk,   ~ 12.288 MHz    (~ 80,715  ns) (non utilisee dans le codeur)
-- i_bclk       ~ 3,10   MHz    (~ 322,857 ns) freq mclk/4
-- La durée d'une période reclrc est de 64,5 périodes de bclk ...
--
-- Revision  
-- Revision 14 mai 2019 (version ..._v1b) composants dans entités et fichiers distincts
---------------------------------------------------------------------------------------------
-- À faire :
--
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

entity mef_decod_i2s_v1b is
   Port ( 
   i_bclk      : in std_logic;
   i_reset     : in    std_logic; 
   i_lrc       : in std_logic;
   i_cpt_bits  : in std_logic_vector(6 downto 0);
 --  
   o_bit_enable     : out std_logic ;  --
   o_load_left      : out std_logic ;  --
   o_load_right     : out std_logic ;  --
   o_str_dat        : out std_logic ;  --  
   o_cpt_bit_reset  : out std_logic   -- 
   
);
end mef_decod_i2s_v1b;

architecture Behavioral of mef_decod_i2s_v1b is
   
type fonction_etat is (
     initiale,
     attente_gauche,
     reset_gauche,
     attente_droite,
     reset_droite,
     confirmer
     );
     
    signal etat_present, etat_suivant : fonction_etat;    
      
begin

   -- Assignation du prochain état
process(i_bclk, i_reset)
    begin
       if (i_reset = '1') then
             etat_present <= initiale;
       else
           if rising_edge(i_bclk) then
                 etat_present <= etat_suivant;
           end if;
       end if;
end process;

process(etat_suivant, i_lrc, i_cpt_bits)
begin
    case etat_present is
        when initiale =>
            if (i_lrc = '0') then
                etat_suivant <= attente_gauche;
            --elsif (i_lrc = '1') then
                --etat_suivant <= attente_droite;
            else
                etat_suivant <= initiale;
            end if;
            
        when attente_gauche =>
            o_cpt_bit_reset <= '0';
            o_load_left <= '1';
            o_load_right <= '0';
            -- ajouter compteur qui monte
            if (i_cpt_bits = 23) then
                o_load_left <= '0';
                o_load_right <= '0';
                o_cpt_bit_reset <= '1';
                etat_suivant <= attente_droite;
            else 
                etat_suivant <= attente_gauche;
            end if;
            
        when attente_droite =>
            if (i_lrc = '1') then
                o_cpt_bit_reset <= '0';
                o_load_left <= '0';
                o_load_right <= '1';
                -- ajouetr compteur qui monte
                if (i_cpt_bits = 23) then
                    o_load_left <= '0';
                    o_load_right <= '0';
                    o_cpt_bit_reset <= '1';
                    etat_suivant <= confirmer;
                else 
                    etat_suivant <= attente_gauche;
                end if;
            end if;
            
                
        when others => etat_suivant <= etat_present;
    end case;
end process;
 

end Behavioral;