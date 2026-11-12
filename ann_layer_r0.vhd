	-------------------------------------------------------------------------------
-- ECE 341 Fall 2026 - one-layer ANN project
-- ann_layer.vhd : top-level ENTITY (shared by behavioral, dataflow and
--                 structural architectures)
--
-- Computes y = ReLU(W.x + b) for N_OUT neurons with N_IN inputs each.
--   pixel  x : 8-bit unsigned (value p/256)
--   weight w : 16-bit signed Q4.12, bias b : 16-bit signed Q4.12
--   output y : 16-bit signed Q1.15, 0 <= y <= 32767 (ReLU, truncate, saturate)
--
-- Pins: inputs  clk, rst, start, mode, in_valid, din(15:0)          = 21
--       outputs out_valid, out_idx(3:0), dout(15:0), done           = 22
--       total                                                       = 43 (<= 96)
--
-- Protocol (all signals sampled on the rising clock edge, rst synchronous)
--   Initialization (load weights):
--     mode = '0', pulse start for one clock. Then send N_OUT*(N_IN+1) words
--     on din with in_valid = '1' (idle cycles with in_valid = '0' allowed),
--     in the order of weights.txt: neuron 0 weights 0..N_IN-1, neuron 0 bias,
--     neuron 1 weights ..., bias, ... . done = '1' after the last word.
--   Inference (one input vector):
--     mode = '1', pulse start for one clock. Then send N_IN pixels on
--     din(7 downto 0) with in_valid = '1' (din(15 downto 8) ignored).
--     The outputs come back one per clock: out_valid = '1', out_idx = j,
--     dout = y_j for j = 0 .. N_OUT-1. done = '1' together with the last
--     output and stays '1' until the next start.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ann_layer is
  generic (
    N_IN  : positive := 256;            -- inputs (pixels) per neuron
    N_OUT : positive := 10              -- neurons (max 16)
  );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    start     : in  std_logic;
    mode      : in  std_logic;          -- '0' = load weights, '1' = inference
    in_valid  : in  std_logic;
    din       : in  std_logic_vector(15 downto 0);
    out_valid : out std_logic;
    out_idx   : out std_logic_vector(3 downto 0);
    dout      : out std_logic_vector(15 downto 0);
    done      : out std_logic
  );
begin
  assert N_OUT <= 16 report "ann_layer: N_OUT must be <= 16" severity failure;
end entity ann_layer;
