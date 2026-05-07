/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module Motor_PWM(
    input wire clk,             
    input wire rst_n,           
    input wire [7:0] duty_l,    
    input wire [7:0] duty_r,    
    input Clip_Near,
    output reg EnL,           
    output reg EnR            
);

    reg [7:0] counter;

    
    always @(posedge clk) begin
        if (!rst_n)begin
            counter <= 8'd0;
            EnL <= 0;
            EnR <= 0;
        end else begin
            counter <= counter + 1'b1;
            EnL <= ((counter < duty_l) ? 1'b1 : 1'b0) & ~Clip_Near;
            EnR <= ((counter < duty_r) ? 1'b1 : 1'b0) & ~Clip_Near;
        end
    end
endmodule
module PID(
    
    input clk,
    input rst_n,
    input [4:0] S,
    input Clip_Near,
    input RW,
    input  [7:0] uio_in,   // IOs: Input path
    output [7:0] uio_out,  // IOs: Output path
    output [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    output EnL,
    output DirL,
    output Out1L,
    output Out2L,
    output EnR,
    output DirR,
    output Out1R,
    output Out2R
    );
    
    reg signed [8:0] error;
    reg signed [8:0] integral;
    reg signed [8:0] Corr, Rduty_l, Rduty_r;
    reg [7:0] duty_l, duty_r;
    reg [3:0] Kp;
    reg [2:0] Ki;
    reg S_Ki;
        
    assign uio_oe = RW? 8'b11111111 : 8'b00000000;  //oe = 0 input, oe=1 output
    assign uio_out[3:0] = Kp;
    assign uio_out[6:4] = Ki;
    assign uio_out[7] = S_Ki;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            integral <= 9'd0;
            Corr <= 9'd0;
            Rduty_l <= 9'd0;
            Rduty_r <= 9'd0;
            duty_l <= 8'd0;
            duty_r <= 8'd0;
        end else begin
           case (S)
            5'b11110: error <=  4; // Extreme Left
            5'b11100: error <=  3;
            5'b11101: error <=  2;
            5'b11001: error <=  1;
            5'b11011: error <=  0; // Line Centered
            5'b10011: error <= -1;
            5'b10111: error <= -2;
            5'b00111: error <= -3;
            5'b01111: error <= -4; // Extreme Right
            default:  error <=  0;
           endcase
           if(RW) begin
            Kp <= uio_in[3:0];
            Ki <= uio_in[6:4];
            S_Ki <= uio_in[7];
            integral <= 9'd0;
           end else begin
            integral <= integral + error;
               if (S_Ki) begin
                   Corr <= integral << Ki;
                end else begin
                    Corr <= integral >>> Ki;
                end
            Corr <= Corr + (error << Kp);
            Rduty_l <= 8'd127 + Corr;
            Rduty_r <= 8'd127 - Corr;
            duty_l <= (Rduty_l[8])? -Rduty_l[7:0] : Rduty_l[7:0];
            duty_r <= (Rduty_r[8])? -Rduty_r[7:0] : Rduty_r[7:0];
           end
        end
    end
    assign DirL = ~Rduty_l[8];
    assign DirR = ~Rduty_r[8];
    Motor_PWM MotorlR(
        .clk (clk),
        .rst_n (rst_n),
        .duty_l (duty_l),
        .duty_r (duty_r),
        .Clip_Near (Clip_Near),
        .EnL (EnL),
        .EnR (EnR)
    );
    
    assign Out1L = EnL & ~DirL;
    assign Out2L = EnL & DirL;
    assign Out1R = EnR & ~DirR;
    assign Out2R = EnR & DirR;
endmodule

module Combinatory(
    input clk,
    input rst_n,
    input [4:0] S,
    input Clip_Near,
    input PWM,
    output reg EnL,
    output reg DirL,
    output Out1L,
    output Out2L,
    output reg EnR,
    output reg DirR,
    output Out1R,
    output Out2R
    );
    
    wire s1, s2, s3, s4, s5;
    assign s1 = S[0];
    assign s2 = S[1];
    assign s3 = S[2];
    assign s4 = S[3];
    assign s5 = S[4];

    assign Out1L = EnL & ~DirL;
    assign Out2L = EnL & DirL;
    assign Out1R = EnR & ~DirR;
    assign Out2R = EnR & DirR;
    
    always @(posedge clk) begin
       if(!rst_n)begin
            EnL<= 0;
            EnR<= 0;
            DirL <= 0;
            DirR <= 0;
       end
       else begin
            EnL <= ((s1&s2&s3&~s4)|(s1&s2&s3&~s5)|(s1&s2&~s3&s5)|(s1&s2&~s4&s5)|(~s1&~s2&~s3&~s4&~s5)|(~s1&s3&s4&s5)) & ~Clip_Near & PWM;
            DirL <= (s1&s2&s3&~s4)|(s1&s2&s3&~s5)|(s1&s2&~s3&s5)|(s1&s2&~s4&s5)|(~s1&~s2&~s3&~s4&~s5);
            EnR <= ((s1&s2&s3&~s5)|(s1&~s2&s4&s5)|(s1&~s3&s4&s5)|(~s1&~s2&~s3&~s4&~s5)|(~s1&s3&s4&s5)|(~s2&s3&s4&s5)) & ~Clip_Near & PWM;
            DirR <= (s1&~s2&s4&s5)|(s1&~s3&s4&s5)|(~s1&~s2&~s3&~s4&~s5)|(~s1&s3&s4&s5)|(~s2&s3&s4&s5);
        end
    end
 endmodule

module tt_um_BFD100_Logic(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire [7:0] C_out;
    wire [7:0] PID_out;
    assign uo_out = (ui_in[7])? C_out : PID_out;
    
    PID U1(
      .clk (clk),
      .rst_n (rst_n),
      .S (ui_in[4:0]),
      .Clip_Near (ui_in[5]),
      .RW (ui_in[6]),
      .uio_in (uio_in),   // IOs: Input path
      .uio_out (uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .EnL (PID_out[0]),
      .DirL (PID_out[1]),
      .Out1L (PID_out[2]),
      .Out2L (PID_out[3]),
      .EnR (PID_out[4]),
      .DirR (PID_out[5]),
      .Out1R (PID_out[6]),
      .Out2R (PID_out[7])
    );
    
Combinatory U2(
      .clk (clk),
      .rst_n (rst_n),
      .S (ui_in[4:0]),
      .Clip_Near (ui_in[5]),
      .PWM (ui_in[6]),
      .EnL (C_out[0]),
      .DirL (C_out[1]),
      .Out1L (C_out[2]),
      .Out2L (C_out[3]),
      .EnR (C_out[4]),
      .DirR (C_out[5]),
      .Out1R (C_out[6]),
      .Out2R (C_out[7])
    );

    
    
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule
